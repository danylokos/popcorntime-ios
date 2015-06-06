//
//  BaseDetailsViewController.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/21/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

protocol DetailViewControllerDataSource {
    func numberOfSeasons() -> Int
    func numberOfEpisodesInSeason(seasonsIndex: Int) -> Int
    func setupCell(cell: EpisodeCell, seasonIndex: Int, episodeIndex: Int)
    func setupSeasonHeader(header: SeasonHeader, seasonIndex: Int)
    func userSelectedEpisode(cell: UICollectionViewCell, episodeIndex: Int, fromSeason seasonIndex: Int)
}

class BaseDetailsViewController: BarHidingViewController, VDLPlaybackViewControllerDelegate, LoadingViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DetailViewControllerDataSource {
    
    // MARK: - Header related
    let headerMinAspectRatio: CGFloat = 0.4
    let headerWidthToCollectionWidthKoef: CGFloat = 0.3
    var header: StratchyHeader?
    
    var preferedOtherHeadersHeight: CGFloat = 35
    
    var headerSize: CGSize {
        let width = collectionView.bounds.size.width
        let minHeight = width * headerMinAspectRatio
        var height = collectionView.bounds.size.height * headerWidthToCollectionWidthKoef
        height = max(height, minHeight)
        return CGSize(width: width, height: height)
    }
    
    // MARK: -
    let cellReuseIdentifier = "EpisodeCell"
    let firstHeaderReuseIdentifier = "StratchyHeader"
    let otherHeadersReuseIdentifier = "OtherHeader"
    let episodeCellReuseIdentifier = "EpisodeCell"
    
    var layout: StratchyHeaderLayout?
    
    var item: BasicInfo! {
        didSet {
            navigationItem.title = item.title
            reloadData()
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.alwaysBounceVertical = true
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.registerNib(UINib(nibName: "StratchyHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: firstHeaderReuseIdentifier)
            collectionView.registerNib(UINib(nibName: "SeasonHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: otherHeadersReuseIdentifier)
            collectionView.registerNib(UINib(nibName: "EpisodeCell", bundle: nil), forCellWithReuseIdentifier: episodeCellReuseIdentifier)
            layout = collectionView.collectionViewLayout as? StratchyHeaderLayout
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFavoriteBarButton()
    }
    
    func configureFavoriteBarButton() {
        if (item.isFavorite) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.removeFromFavoritesImage(),
                style: .Done, target: self, action: "removeFromFavorites")
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.addToFavoritesImage(),
                style: .Done, target: self, action: "addToFavorites")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // update header size
        header?.headerSize = headerSize
        layout?.headerSize = headerSize
    }
    
    // MARK: - Favorites
    func addToFavorites() {
        DataManager.sharedManager().addToFavorites(item)
        configureFavoriteBarButton()
    }
    
    func removeFromFavorites() {
        DataManager.sharedManager().removeFromFavorites(item)
        configureFavoriteBarButton()
    }
    
    // MARK: - BaseDetailsViewController
    func reloadData() {
        
    }
    
    func startPlayback(magnetLink: String, loadingTitle: String) {
        let loadingVC = self.storyboard?.instantiateViewControllerWithIdentifier("loadingViewController") as! LoadingViewController
        loadingVC.delegate = self
        loadingVC.status = "Downloading..."
        loadingVC.loadingTitle = loadingTitle
        loadingVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        self.tabBarController?.presentViewController(loadingVC, animated: true, completion: nil)
        
        PTTorrentStreamer.sharedStreamer().startStreamingFromFileOrMagnetLink(magnetLink, progress: { (status) -> Void in
            
            loadingVC.progress = status.bufferingProgress
            loadingVC.speed = Int(status.downloadSpeed)
            loadingVC.seeds = Int(status.seeds)
            loadingVC.peers = Int(status.peers)
            
            }, readyToPlay: { (url) -> Void in
                loadingVC.dismissViewControllerAnimated(false, completion: nil)
                
                let vdl = VDLPlaybackViewController(nibName: "VDLPlaybackViewController", bundle: nil)
                vdl.delegate = self
                self.navigationController?.presentViewController(vdl, animated: true, completion: nil)
                vdl.playMediaFromURL(url)
                
            }, failure: { (error) -> Void in
                loadingVC.dismissViewControllerAnimated(true, completion: nil)
        })
    }

    // MARK: - VDLPlaybackViewControllerDelegate
    
    func playbackControllerDidFinishPlayback(playbackController: VDLPlaybackViewController!) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        PTTorrentStreamer.sharedStreamer().cancelStreaming()
    }
    
    // MARK: - LoadingViewControllerDelegate
    
    func didCancelLoading(controller: LoadingViewController) {
        PTTorrentStreamer.sharedStreamer().cancelStreaming()
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    
    final func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 0
        default:
            let seasonIndex = section - 1
            return self.numberOfEpisodesInSeason(seasonIndex)
        }
    }
    
    final func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.numberOfSeasons() + 1 // extra section for header
    }
    
    final func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let seasonIndex = indexPath.section - 1
        let episode = indexPath.item
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! EpisodeCell
        self.setupCell(cell, seasonIndex: seasonIndex, episodeIndex: episode)
        return cell
    }
    
    final func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0: return headerSize
        default : return CGSizeMake(collectionView.bounds.width, preferedOtherHeadersHeight)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            if (header == nil){
                header = (collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: firstHeaderReuseIdentifier, forIndexPath: indexPath) as! StratchyHeader)
                header?.delegate = layout

                if let header = header {
                    if let imageItem = item.bigImage {
                        if let image = imageItem.image {
                            header.image = image
                        } else {
                            ImageProvider.sharedInstance.imageFromURL(URL: imageItem.URL) { (image) -> () in
                                imageItem.image = image
                                header.image = image
                            }
                        }
                    }
                    //
                    if let imageItem = item.smallImage {
                        if let image = imageItem.image {
                            header.foregroundImage.image = image
                        } else {
                            ImageProvider.sharedInstance.imageFromURL(URL: imageItem.URL) { (image) -> () in
                                imageItem.image = image
                                header.foregroundImage.image = image
                            }
                        }
                    }
                }
            }
            header!.synopsisTextView.text = item.synopsis
            return header!
        } else {
            let otherHeader = (collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: otherHeadersReuseIdentifier, forIndexPath: indexPath) as! SeasonHeader)
            let seasonIndex = (indexPath.section - 1)
            self.setupSeasonHeader(otherHeader, seasonIndex: seasonIndex)
            return otherHeader
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    final func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            self.userSelectedEpisode(cell, episodeIndex: indexPath.row, fromSeason: indexPath.section - 1)
        }
    }
    
    func showVideoPickerPopupForEpisode(episode: Episode, fromView view: UIView) {
        let videos = episode.videos
        if (videos.count > 0) {
            
            let actionSheetController = UIAlertController(title: episode.title, message: episode.desc, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            actionSheetController.addAction(cancelAction)
            
            for video in videos {
                var title = ""
                if let subGroup = video.subGroup {
                    title += "[\(subGroup)] "
                }
                if let quality = video.quality {
                    title += quality
                }
                
                let action = UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    let magnetLink = video.magnetLink
                    let episodeTitle = episode.title ?? ""
                    self.startPlayback(magnetLink, loadingTitle: episodeTitle)
                })
                
                actionSheetController.addAction(action)
            }
            
            var popOver = actionSheetController.popoverPresentationController
            popOver?.sourceView  = view
            popOver?.sourceRect = view.bounds
            popOver?.permittedArrowDirections = UIPopoverArrowDirection.Any
            
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }
    
    // MARK: - DetailViewControllerDataSource
    func numberOfSeasons() -> Int {
        assertionFailure("Should be overriden by subclass")
        return 0
    }
    
    func numberOfEpisodesInSeason(seasonsIndex: Int) -> Int {
        assertionFailure("Should be overriden by subclass")
        return 0
    }
    
    func setupCell(cell: EpisodeCell, seasonIndex: Int, episodeIndex: Int) {
        assertionFailure("Should be overriden by subclass")
    }
    
    func setupSeasonHeader(header: SeasonHeader, seasonIndex: Int) {
        assertionFailure("Should be overriden by subclass")
    }
    
    func userSelectedEpisode(cell: UICollectionViewCell, episodeIndex: Int, fromSeason seasonIndex: Int) {
        assertionFailure("Should be overriden by subclass")
    }
    
}
