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
                self.collectionView?.reloadData()
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
        if let parseData = parseData {
            cell.watchedEpisode = parseData.isEpisodeWatched(Int(episode.seasonNumber), episode: Int(episode.episodeNumber))
        }
    }
    
    override func setupSeasonHeader(header: SeasonHeader, seasonIndex: Int) {
        let seasonNumber = self.show.seasons[seasonIndex].seasonNumber
        header.titleLabel.text = "Season \(seasonNumber)"
    }
    
    override func cellWasPressed(cell: UICollectionViewCell, seasonIndex: Int, episodeIndex: Int) {
        let episode = show.episodeFor(seasonIndex: seasonIndex, episodeIndex: episodeIndex)
        showVideoPickerPopupForEpisode(episode, basicInfo: self.item, fromView: cell)
    }
    
    override func cellWasLongPressed(cell: UICollectionViewCell, seasonIndex: Int, episodeIndex: Int) {
        let episode = show.episodeFor(seasonIndex: seasonIndex, episodeIndex: episodeIndex)
        let seasonEpisodes = show.episodesFor(seasonIndex: seasonIndex)
        
        promptToMarkEpisodesWatched(lastEpisodeToMarked: episode, basicInfo: show, allSeasonEpisodes: seasonEpisodes, popoverView: cell)
    }
}
