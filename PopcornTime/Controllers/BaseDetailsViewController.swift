//
//  BaseDetailsViewController.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/21/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

/// With this protocol we encapsulate calls of collectionView indexPathes. For now we have one extra section at the top (empty one with stratchy header), this way if anything changes here we will change all logic here, and all users of this protocol will not have to hcange anything. So it's a good idea to use seasonIndex, episodeIndex instead of indexPathes.
protocol DetailViewControllerDataSource {
    func numberOfSeasons() -> Int
    func numberOfEpisodesInSeason(_ seasonsIndex: Int) -> Int
    func setupCell(_ cell: EpisodeCell, seasonIndex: Int, episodeIndex: Int)
    func setupSeasonHeader(_ header: SeasonHeader, seasonIndex: Int)
    func cellWasPressed(_ cell: UICollectionViewCell, seasonIndex: Int, episodeIndex: Int)
    func cellWasLongPressed(_ cell: UICollectionViewCell, seasonIndex: Int, episodeIndex: Int)
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
            collectionView.register(UINib(nibName: "StratchyHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: firstHeaderReuseIdentifier)
            collectionView.register(UINib(nibName: "SeasonHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: otherHeadersReuseIdentifier)
            collectionView.register(UINib(nibName: "EpisodeCell", bundle: nil), forCellWithReuseIdentifier: episodeCellReuseIdentifier)
            layout = collectionView.collectionViewLayout as? StratchyHeaderLayout
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFavoriteBarButton()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(BaseDetailsViewController.longPress(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.delaysTouchesBegan = true
        collectionView.addGestureRecognizer(longPress)
    }
    
    final func longPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            return
        }
        let p = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: p) {
            if let cell = collectionView.cellForItem(at: indexPath) {
                cellWasLongPressed(cell, seasonIndex: indexPath.section - 1, episodeIndex: indexPath.item)
            }
        }
    }
    
    func configureFavoriteBarButton() {
        if (item.isFavorite) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.removeFromFavoritesImage(),
                style: .done, target: self, action: #selector(BaseDetailsViewController.removeFromFavorites))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.addToFavoritesImage(),
                style: .done, target: self, action: #selector(BaseDetailsViewController.addToFavorites))
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
    
    func startPlayback(_ episode: Episode, basicInfo: BasicInfo, magnetLink: String, loadingTitle: String) {
            
        let loadingVC = self.storyboard?.instantiateViewController(withIdentifier: "loadingViewController") as! LoadingViewController
        loadingVC.delegate = self
        loadingVC.status = "Downloading..."
        loadingVC.loadingTitle = loadingTitle
        loadingVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.tabBarController?.present(loadingVC, animated: true, completion: nil)
        
        PTTorrentStreamer.shared().startStreaming(fromFileOrMagnetLink: magnetLink, progress: { (status) -> Void in
            
            loadingVC.progress = status.bufferingProgress
            loadingVC.speed = Int(status.downloadSpeed)
            loadingVC.seeds = Int(status.seeds)
            loadingVC.peers = Int(status.peers)
            
            }, readyToPlay: { (url) -> Void in
                loadingVC.dismiss(animated: false, completion: nil)
                
                let vdl = VDLPlaybackViewController(nibName: "VDLPlaybackViewController", bundle: nil)
                vdl.delegate = self
                self.navigationController?.present(vdl, animated: true, completion: nil)
                vdl.playMedia(from: url)
                
            }, failure: { (error) -> Void in
                loadingVC.dismiss(animated: true, completion: nil)
        })
    }

    // MARK: - VDLPlaybackViewControllerDelegate
    
    func playbackControllerDidFinishPlayback(_ playbackController: VDLPlaybackViewController!) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        PTTorrentStreamer.shared().cancelStreaming()
    }
    
    // MARK: - LoadingViewControllerDelegate
    
    func didCancelLoading(_ controller: LoadingViewController) {
        PTTorrentStreamer.shared().cancelStreaming()
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    
    final func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 0
        default:
            let seasonIndex = section - 1
            return self.numberOfEpisodesInSeason(seasonIndex)
        }
    }
    
    final func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.numberOfSeasons() + 1 // extra section for header
    }
    
    final func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let seasonIndex = indexPath.section - 1
        let episode = indexPath.item
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! EpisodeCell
        self.setupCell(cell, seasonIndex: seasonIndex, episodeIndex: episode)
        return cell
    }
    
    final func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0: return headerSize
        default : return CGSize(width: collectionView.bounds.width, height: preferedOtherHeadersHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 0 {
            if (header == nil){
                header = (collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: firstHeaderReuseIdentifier, for: indexPath) as! StratchyHeader)
                header?.delegate = layout

                if let image = item.bigImage?.image {
                    header?.image = image
                } else {
                    ImageProvider.sharedInstance.imageFromURL(URL: item.bigImage?.URL) { (downloadedImage) -> () in
                        self.item.bigImage?.image = downloadedImage
                        self.header?.image = downloadedImage
                    }
                }
                
                if let image = item.smallImage?.image {
                    header?.foregroundImage.image = image
                } else {
                    ImageProvider.sharedInstance.imageFromURL(URL: item.smallImage?.URL) { (downloadedImage) -> () in
                        self.item.smallImage?.image = downloadedImage
                        self.header?.foregroundImage.image = downloadedImage
                    }
                }
            }
            header!.synopsisTextView.text = item.synopsis
            return header!
        } else {
            let otherHeader = (collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: otherHeadersReuseIdentifier, for: indexPath) as! SeasonHeader)
            let seasonIndex = (indexPath.section - 1)
            self.setupSeasonHeader(otherHeader, seasonIndex: seasonIndex)
            return otherHeader
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    final func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cellWasPressed(cell, seasonIndex: indexPath.section - 1, episodeIndex: indexPath.item)
        }
    }
    
    func showVideoPickerPopupForEpisode(_ episode: Episode, basicInfo: BasicInfo, fromView view: UIView) {
        let videos = episode.videos
        if (videos.count > 0) {
            
            let actionSheetController = UIAlertController(title: episode.title, message: episode.desc, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            actionSheetController.addAction(cancelAction)
            
            for video in videos {
                var title = ""
                if let subGroup = video.subGroup {
                    title += "[\(subGroup)] "
                }
                if let quality = video.quality {
                    title += quality
                }
                
                let action = UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    let magnetLink = video.magnetLink
                    let episodeTitle = episode.title ?? ""
                    let loadingTitle = "\(episodeTitle) - \(title)"
                    self.startPlayback(episode, basicInfo: basicInfo , magnetLink: magnetLink, loadingTitle: loadingTitle)
                })
                
                actionSheetController.addAction(action)
            }
            
            let popOver = actionSheetController.popoverPresentationController
            popOver?.sourceView  = view
            popOver?.sourceRect = view.bounds
            popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
          
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    // MARK: - DetailViewControllerDataSource
    func numberOfSeasons() -> Int {
        assertionFailure("Should be overriden by subclass")
        return 0
    }
    
    func numberOfEpisodesInSeason(_ seasonsIndex: Int) -> Int {
        assertionFailure("Should be overriden by subclass")
        return 0
    }
    
    func setupCell(_ cell: EpisodeCell, seasonIndex: Int, episodeIndex: Int) {
        assertionFailure("Should be overriden by subclass")
    }
    
    func setupSeasonHeader(_ header: SeasonHeader, seasonIndex: Int) {
        assertionFailure("Should be overriden by subclass")
    }
    
    func cellWasPressed(_ cell: UICollectionViewCell, seasonIndex: Int, episodeIndex: Int) {
        assertionFailure("Should be overriden by subclass")
    }
    
    func cellWasLongPressed(_ cell: UICollectionViewCell, seasonIndex: Int, episodeIndex: Int) {
        
    }
}
