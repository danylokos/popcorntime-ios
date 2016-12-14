//
//  ShowDetailsViewController.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/13/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class MovieDetailsViewController: BaseDetailsViewController {
    
    var movie: Movie! {
        get {
            return self.item as! Movie
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferedOtherHeadersHeight = 0.0
    }
    
    // MARK: - BaseDetailsViewController
    
    override func reloadData() {
        PTAPIManager.shared().showInfo(with: .movie, withId: item.identifier, success: { (item) -> Void in
            guard let item = item else { return }
            self.movie.update(item)
            self.collectionView?.reloadData()
            }, failure: nil)
    }
    
    // MARK: - DetailViewControllerDataSource
    override func numberOfSeasons() -> Int {
        return 1
    }
    
    override func numberOfEpisodesInSeason(_ seasonsIndex: Int) -> Int {
        return movie.videos.count
    }
    
    override func setupCell(_ cell: EpisodeCell, seasonIndex: Int, episodeIndex: Int) {
        let video = movie.videos[episodeIndex]
        var title = ""
        if let quality = video.quality {
            title += quality + " "
        }
        if let name = video.name {
            title += name
        }
        cell.titleLabel.text = title
    }
    
    override func setupSeasonHeader(_ header: SeasonHeader, seasonIndex: Int) {
    }
    
    override func cellWasPressed(_ cell: UICollectionViewCell, seasonIndex: Int, episodeIndex: Int) {
        let video = movie.videos[episodeIndex]
        let magnetLink = video.magnetLink
        let title = movie.title ?? ""
        let fakeEpisode = Episode(title: title, desc: "", seasonNumber: 0, episodeNumber: 0, videos: [Video]())
        startPlayback(fakeEpisode, basicInfo: movie, magnetLink: magnetLink, loadingTitle: title)
    }
    
}
