//
//  PTTorrentStreamer.h
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 2/23/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    float bufferingProgress;
    float totalProgreess;
    int downloadSpeed;
    int upoadSpeed;
    int seeds;
    int peers;
} PTTorrentStatus;

typedef void (^PTTorrentStreamerProgress)(PTTorrentStatus status);
typedef void (^PTTorrentStreamerReadyToPlay)(NSURL *videoFileURL);
typedef void (^PTTorrentStreamerFailure)(NSError *error);

@interface PTTorrentStreamer : NSObject

+ (instancetype)sharedStreamer;

- (void)startStreamingFromFileOrMagnetLink:(NSString *)filePathOrMagnetLink
                                  progress:(PTTorrentStreamerProgress)progreess
                               readyToPlay:(PTTorrentStreamerReadyToPlay)readyToPlay
                                   failure:(PTTorrentStreamerFailure)failure;

- (void)cancelStreaming;

@end
