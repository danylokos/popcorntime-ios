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
        PTAPIManager.sharedManager().showInfoWithType(.Show, withId: show.identifier, success: { (item) -> Void in
            if let item = item {
                self.show.update(item)
                self.collectionView.reloadData()
            }
            }, failure: nil)
    }
    
    // MARK: - DetailViewControllerDataSource
    override func numberOfSeasons() -> Int {
        return show.seasons.count
    }
    
    override func numberOfEpisodesInSeason(seasonsIndex: Int) -> Int {
        return show.seasons[seasonsIndex].episodes.count
    }
    
    override func setupCell(cell: EpisodeCell, seasonIndex: Int, episodeIndex: Int) {
        let episode = show.seasons[seasonIndex].episodes[episodeIndex]
        if let title = episode.title {
            cell.titleLabel.text = "S\(episode.seasonNumber)E\(episode.episodeNumber):  \(title)"
        } else {
            cell.titleLabel.text = "S\(episode.seasonNumber)E\(episode.episodeNumber)"
        }
      if (parseData?.isEpisodeWatched(Int(episode.seasonNumber), episode: Int(episode.episodeNumber)) == true) {
        cell.alpha = 0.5
      } else {
        cell.alpha = 1.0
      }
    }
    
    override func setupSeasonHeader(header: SeasonHeader, seasonIndex: Int) {
        let seasonNumber = self.show.seasons[seasonIndex].seasonNumber
        header.titleLabel.text = "Season \(seasonNumber)"
    }
    
    override func userSelectedEpisode(cell: UICollectionViewCell, episodeIndex: Int, fromSeason seasonIndex: Int) {
        let episode = show.seasons[seasonIndex].episodes[episodeIndex]
        let videos = episode.videos
        
        showVideoPickerPopupForEpisode(episode, fromView: cell)
      ParseManager.sharedInstance.markEpisode(episode, basicInfo: self.item)
    }
}
