//
//  ShowDetailsViewController.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/13/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class AnimeDetailsViewController: BaseDetailsViewController {
    
    var anime: Anime! {
        get {
            return self.item as! Anime
        }
    }
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferedOtherHeadersHeight = 0.0
    }
    
    // MARK: - BaseDetailsViewController
    
    override func reloadData() {
        PTAPIManager.shared().showInfo(with: .anime, withId: item.identifier, success: { (item) -> Void in
            guard let item = item else { return }
            self.anime.update(item)
            self.collectionView?.reloadData()
            }, failure: nil)
    }
    
    // MARK: - DetailViewControllerDataSource
    override func numberOfSeasons() -> Int {
        return anime.seasons.count
    }
    
    override func numberOfEpisodesInSeason(_ seasonsIndex: Int) -> Int {
        return anime.seasons[seasonsIndex].episodes.count
    }
    
    override func setupCell(_ cell: EpisodeCell, seasonIndex: Int, episodeIndex: Int) {
        let episode = anime.seasons[seasonIndex].episodes[episodeIndex]
        cell.titleLabel.text = "\(episode.episodeNumber)"
    }
    
    override func setupSeasonHeader(_ header: SeasonHeader, seasonIndex: Int) {
        
    }
    
    override func cellWasPressed(_ cell: UICollectionViewCell, seasonIndex: Int, episodeIndex: Int) {
        let episode = anime.seasons[seasonIndex].episodes[episodeIndex]
        showVideoPickerPopupForEpisode(episode, basicInfo: self.item, fromView: cell)
    }
    
    override func cellWasLongPressed(_ cell: UICollectionViewCell, seasonIndex: Int, episodeIndex: Int) {
//        let episode = anime.episodeFor(seasonIndex: seasonIndex, episodeIndex: episodeIndex)
//        let seasonEpisodes = anime.episodesFor(seasonIndex: seasonIndex)
    }
}
