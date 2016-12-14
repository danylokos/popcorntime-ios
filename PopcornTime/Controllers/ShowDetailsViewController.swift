//
//  ShowDetailsViewController.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/13/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class ShowDetailsViewController: BaseDetailsViewController {
    
    var show: Show! {
        get {
            return self.item as! Show
        }
    }
    
    // MARK: - BaseDetailsViewController
    
    override func reloadData() {
        PTAPIManager.shared().showInfo(with: .show, withId: show.identifier, success: { (item) -> Void in
            guard let item = item else { return }
            self.show.update(item)
            self.collectionView?.reloadData()
            }, failure: nil)
    }
    
    // MARK: - DetailViewControllerDataSource
    override func numberOfSeasons() -> Int {
        return show.seasons.count
    }
    
    override func numberOfEpisodesInSeason(_ seasonsIndex: Int) -> Int {
        return show.seasons[seasonsIndex].episodes.count
    }
    
    override func setupCell(_ cell: EpisodeCell, seasonIndex: Int, episodeIndex: Int) {
        let episode = show.seasons[seasonIndex].episodes[episodeIndex]
        if let title = episode.title {
            cell.titleLabel.text = "S\(episode.seasonNumber)E\(episode.episodeNumber):  \(title)"
        } else {
            cell.titleLabel.text = "S\(episode.seasonNumber)E\(episode.episodeNumber)"
        }
    }
    
    override func setupSeasonHeader(_ header: SeasonHeader, seasonIndex: Int) {
        let seasonNumber = self.show.seasons[seasonIndex].seasonNumber
        header.titleLabel.text = "Season \(seasonNumber)"
    }
    
    override func cellWasPressed(_ cell: UICollectionViewCell, seasonIndex: Int, episodeIndex: Int) {
        let episode = show.episodeFor(seasonIndex: seasonIndex, episodeIndex: episodeIndex)
        showVideoPickerPopupForEpisode(episode, basicInfo: self.item, fromView: cell)
    }
    
    override func cellWasLongPressed(_ cell: UICollectionViewCell, seasonIndex: Int, episodeIndex: Int) {
//        let episode = show.episodeFor(seasonIndex: seasonIndex, episodeIndex: episodeIndex)
//        let seasonEpisodes = show.episodesFor(seasonIndex: seasonIndex)
    }
}
