//
//  PTTorrentStreamer.m
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 2/23/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

#import "PTTorrentStreamer.h"

#import <UIKit/UIKit.h>

#import <string>
#import <libtorrent/session.hpp>
#import <libtorrent/alert.hpp>
#import <libtorrent/alert_types.hpp>

#import <CocoaSecurity/CocoaSecurity.h>

using namespace libtorrent;

@interface PTTorrentStreamer()
@property (nonatomic, strong) dispatch_queue_t alertsQueue;
@property (nonatomic, getter=isAlertsLoopActive) BOOL alertsLoopActive;
@property (nonatomic, strong) NSString *savePath;
@property (nonatomic, getter=isDownloading) BOOL downloading;
@property (nonatomic, getter=isStreaming) BOOL streaming;

@property (nonatomic, copy) PTTorrentStreamerProgress progressBlock;
@property (nonatomic, copy) PTTorrentStreamerReadyToPlay readyToPlayBlock;
@property (nonatomic, copy) PTTorrentStreamerFailure failureBlock;
@end

@implementation PTTorrentStreamer
{
    session *_session;
    std::vector<int> required_pieces;
}

+ (instancetype)sharedStreamer
{
    static dispatch_once_t onceToken;
    static PTTorrentStreamer *sharedStreamer;
    dispatch_once(&onceToken, ^{
        sharedStreamer = [[PTTorrentStreamer alloc] init];
    });
    return sharedStreamer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSession];
    }
    return self;
}

#pragma mark - 

+ (NSString *)downloadsDirectory
{
    NSString *downloadsDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Downloads"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadsDirectoryPath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadsDirectoryPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            NSLog(@"%@", error);
            return nil;
        }
    }
    return downloadsDirectoryPath;
}

- (void)setupSession
{
//    _session = new session(fingerprint("PopcornTime", 1, 0, 0, 0),
//                           std::make_pair(6881, 6889),
//                           0,
//                           session::start_default_features | session::add_default_plugins,
//                           alert::all_categories);

    error_code ec;

    _session = new session();
    _session->set_alert_mask(alert::all_categories);
    _session->listen_on(std::make_pair(6881, 6889), ec);
    if (ec) {
        NSLog(@"failed to open listen socket: %s", ec.message().c_str());
    }
    
    session_settings settings = _session->settings();
    settings.announce_to_all_tiers = true;
    settings.announce_to_all_trackers = true;
    settings.prefer_udp_trackers = false;
    settings.max_peerlist_size = 0;
    _session->set_settings(settings);
}

- (void)startStreamingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink
                                  progress:(PTTorrentStreamerProgress)progreess
                               readyToPlay:(PTTorrentStreamerReadyToPlay)readyToPlay
                                   failure:(PTTorrentStreamerFailure)failure;
{
    self.progressBlock = progreess;
    self.readyToPlayBlock = readyToPlay;
    self.failureBlock = failure;

    self.alertsQueue = dispatch_queue_create("com.popcorntime.ios.torrentstreamer.alerts", DISPATCH_QUEUE_SERIAL);
    self.alertsLoopActive = YES;
    dispatch_async(self.alertsQueue, ^{
        [self alertsLoop];
    });
    
    error_code ec;
    add_torrent_params tp;
    
    NSString *MD5String = nil;
    
    if ([filePathOrMagnetLink hasPrefix:@"magnet"]) {
        NSString *magnetLink = filePathOrMagnetLink;
        magnetLink = [magnetLink stringByAppendingString:@"&tr=udp://open.demonii.com:1337"
                                                          "&tr=udp://tracker.coppersurfer.tk:6969"];
        tp.url = std::string([magnetLink UTF8String]);
        
        MD5String = [CocoaSecurity md5:magnetLink].hexLower;
    } else {
        NSString *filePath = filePathOrMagnetLink;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            MD5String = [CocoaSecurity md5WithData:fileData].hexLower;
            
            tp.ti = new torrent_info([filePathOrMagnetLink UTF8String], ec);
            if (ec) {
                NSLog(@"%s", ec.message().c_str());
                return;
            }
        } else {
            NSLog(@"File doesn't exists at path: %@", filePath);
            return;
        }
    }

    NSString *halfMD5String = [MD5String substringToIndex:16];
    self.savePath = [[PTTorrentStreamer downloadsDirectory] stringByAppendingPathComponent:halfMD5String];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:self.savePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error) {
        NSLog(@"Can't create directory at path: %@", self.savePath);
        return;
    }

    tp.save_path = std::string([self.savePath UTF8String]);
    tp.storage_mode = storage_mode_allocate;
    
    torrent_handle th = _session->add_torrent(tp, ec);
    th.set_sequential_download(true);
    
    if (ec) {
        NSLog(@"%s", ec.message().c_str());
        return;
    }
    
    self.downloading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)cancelStreaming
{
    if ([self isDownloading]) {
        self.alertsQueue = nil;
        self.alertsLoopActive = NO;

        std::vector<torrent_handle> ths = _session->get_torrents();
        for(std::vector<torrent_handle>::size_type i = 0; i != ths.size(); i++) {
            _session->remove_torrent(ths[i], session::delete_files);
        }
        
        required_pieces.clear();
        
        self.progressBlock = nil;
        self.readyToPlayBlock = nil;
        self.failureBlock = nil;

        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:self.savePath error:&error];
        if (error) NSLog(@"%@", error);
        
        self.savePath = nil;
        
        self.streaming = NO;
        self.downloading = NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

#pragma mark - Alerts Loop

#define ALERTS_LOOP_WAIT_MILLIS 500
#define MIN_PIECES 15
#define PIECE_DEADLINE_MILLIS 100
#define LIBTORRENT_PRIORITY_SKIP 0
#define LIBTORRENT_PRIORITY_MAXIMUM 7

- (void)alertsLoop
{
    std::deque<alert *> deque;
    time_duration max_wait = milliseconds(ALERTS_LOOP_WAIT_MILLIS);
    
    while ([self isAlertsLoopActive])
    {
        const alert *ptr = _session->wait_for_alert(max_wait);
        if (ptr != nullptr) {
            _session->pop_alerts(&deque);
            for (std::deque<alert *>::iterator it=deque.begin(); it != deque.end(); ++it) {
                std::unique_ptr<alert> alert(*it);
//                NSLog(@"type:%d msg:%s", alert->type(), alert->message().c_str());
                switch (alert->type()) {
                    case metadata_received_alert::alert_type:
                        [self metadataReceivedAlert:(metadata_received_alert *)alert.get()];
                        break;
                    case block_finished_alert::alert_type:
                        [self pieceFinishedAlert:(piece_finished_alert *)alert.get()];
                        break;
                    // In case the video file is already fully downloaded
                    case torrent_finished_alert::alert_type:
                        [self torrentFinishedAlert:(torrent_finished_alert *)alert.get()];
                        break;
                    default: break;
                }
            }
            deque.clear();
        }
    }
}

- (void)prioritizeNextPieces:(torrent_handle)th
{
    int next_required_piece = required_pieces[MIN_PIECES-1]+1;
    required_pieces.clear();
    
    boost::intrusive_ptr<const torrent_info> ti = th.torrent_file();
    
    for (int i=next_required_piece; i<next_required_piece+MIN_PIECES; i++) {
        if (i < ti->num_pieces()) {
            th.piece_priority(i, LIBTORRENT_PRIORITY_MAXIMUM);
            th.set_piece_deadline(i, PIECE_DEADLINE_MILLIS, torrent_handle::alert_when_available);
            required_pieces.push_back(i);
        }
    }
}

- (void)processTorrent:(torrent_handle)th
{
    if (![self isStreaming]) {
        self.streaming = YES;
        if (self.readyToPlayBlock) {
            boost::intrusive_ptr<const torrent_info> ti = th.torrent_file();
            int file_index = [self indexOfLargestFileInTorrent:th];
            file_entry fe = ti->file_at(file_index);
            std::string path = fe.path;
            
            NSString *fileName = [NSString stringWithCString:path.c_str() encoding:NSUTF8StringEncoding];
            NSURL *fileURL = [NSURL fileURLWithPath:[self.savePath stringByAppendingPathComponent:fileName]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.readyToPlayBlock(fileURL);
            });
        }
    }
}

- (int)indexOfLargestFileInTorrent:(torrent_handle)th
{
    boost::intrusive_ptr<const torrent_info> ti = th.torrent_file();
    int files_count = ti->num_files();
    if (files_count > 1) {
        size_type largest_size = -1;
        int largest_file_index = -1;
        for (int i=0; i<files_count; i++) {
            file_entry fe = ti->file_at(i);
            if (fe.size > largest_size) {
                largest_size = fe.size;
                largest_file_index = i;
            }
        }
        return largest_file_index;
    }
    return 0;
}

#pragma mark - Logging

- (void)logPiecesStatus:(torrent_handle)th
{
    NSString *pieceStatus = @"";
    boost::intrusive_ptr<const torrent_info> ti = th.torrent_file();
    for(std::vector<int>::size_type i=0; i!=required_pieces.size(); i++) {
        int piece = required_pieces[i];
        pieceStatus = [pieceStatus stringByAppendingFormat:@"%d:%d ", piece, th.have_piece(piece)];
    }
    NSLog(@"%@", pieceStatus);
}

- (void)logTorrentStatus:(PTTorrentStatus)status
{
    NSString *speedString = [NSByteCountFormatter stringFromByteCount:status.downloadSpeed
                                                           countStyle:NSByteCountFormatterCountStyleBinary];
    NSLog(@"%.0f%%, %.0f%%, %@/s, %d, %d",
          status.bufferingProgress*100, status.totalProgreess*100,
          speedString, status.seeds, status.peers);
}

#pragma mark - Alerts

- (void)metadataReceivedAlert:(metadata_received_alert *)alert
{
    torrent_handle th = alert->handle;
    int file_index = [self indexOfLargestFileInTorrent:th];

    std::vector<int> file_priorities = th.file_priorities();
    std::fill(file_priorities.begin(), file_priorities.end(), LIBTORRENT_PRIORITY_SKIP);
    file_priorities[file_index] = LIBTORRENT_PRIORITY_MAXIMUM;
    th.prioritize_files(file_priorities);
    
    boost::intrusive_ptr<const torrent_info> ti = th.torrent_file();
    int first_piece = ti->map_file(file_index, 0, 0).piece;
    for (int i=first_piece; i<first_piece+MIN_PIECES; i++) {
        required_pieces.push_back(i);
    }

    size_type file_size = ti->file_at(file_index).size;
    int last_piece = ti->map_file(file_index, file_size-1, 0).piece;
    required_pieces.push_back(last_piece);
    
    for (int i=1; i<10; i++) {
        required_pieces.push_back(last_piece-i);
    }
    
    for(std::vector<int>::size_type i=0; i!=required_pieces.size(); i++) {
        int piece = required_pieces[i];
        th.piece_priority(piece, LIBTORRENT_PRIORITY_MAXIMUM);
        th.set_piece_deadline(piece, PIECE_DEADLINE_MILLIS, torrent_handle::alert_when_available);
    }
}

- (void)pieceFinishedAlert:(piece_finished_alert *)alert
{
    torrent_handle th = alert->handle;
    torrent_status status = th.status();
    
    int requiredPiecesDownloaded = 0;
    BOOL allRequiredPiecesDownloaded = YES;
    for(std::vector<int>::size_type i=0; i!=required_pieces.size(); i++) {
        int piece = required_pieces[i];
        if (th.have_piece(piece)) {
            requiredPiecesDownloaded++;
        } else {
            allRequiredPiecesDownloaded = NO;            
        }
    }
    
    [self logPiecesStatus:th];
    
    int requiredPieces = (int)required_pieces.size();
    float bufferingProgress = 1.0 - (requiredPieces-requiredPiecesDownloaded)/(float)requiredPieces;
    
    PTTorrentStatus torrentStatus = {bufferingProgress,
                                    status.progress,
                                    status.download_rate,
                                    status.upload_rate,
                                    status.num_seeds,
                                    status.num_peers};
    [self logTorrentStatus:torrentStatus];
    
    if (self.progressBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressBlock(torrentStatus);
        });
    }
    
    if (allRequiredPiecesDownloaded) {
        [self prioritizeNextPieces:th];
        [self processTorrent:th];
    }
}

- (void)torrentFinishedAlert:(torrent_finished_alert *)alert
{
    [self processTorrent:alert->handle];
}

@end
