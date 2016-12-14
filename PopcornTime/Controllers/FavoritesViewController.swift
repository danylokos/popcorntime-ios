//
//  FavoritesViewController.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/13/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class FavoritesViewController: PagedViewController {

    override func reloadData() {
        if let favoriteItems = DataManager.sharedManager().favorites {
            self.items = favoriteItems
            self.collectionView?.reloadData()
        }
        
    }
    
    override func loadMore() {

    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // No search in favorites
        self.searchController = nil
        self.navigationItem.titleView = nil

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(FavoritesViewController.favoritesDidChange(_:)),
            name: NSNotification.Name(rawValue: Notifications.FavoritesDidChangeNotification),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let item = sender as? BasicInfo {
            
            if let episodesVC = segue.destination as? BaseDetailsViewController {
                switch item {
                case item as Anime:
                    episodesVC.item = item as! Anime
                case item as Show:
                    episodesVC.item = item as! Show
                case item as Movie:
                    episodesVC.item = item as! Movie
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Notifications
    
    func favoritesDidChange(_ notification: Notification) {
        self.reloadData()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        
        let item = self.items[indexPath.row]
        
        switch item {
        case item as Anime:
            performSegue(withIdentifier: "showDetailsForFavoriteAnime", sender: item)
        case item as Show:
            performSegue(withIdentifier: "showDetailsForFavoriteShow", sender: item)
        case item as Movie:
            performSegue(withIdentifier: "showDetailsForFavoriteMovie", sender: item)
        default:
            break
        }
    }
}
