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

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "favoritesDidChange:",
            name: Notifications.FavoritesDidChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let item = sender as? BasicInfo {
            
            if let episodesVC = segue.destinationViewController as? BaseDetailsViewController {
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
    
    func favoritesDidChange(notification: NSNotification) {
        self.reloadData()
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let item = self.items[indexPath.row]
        
        switch item {
        case item as Anime:
            performSegueWithIdentifier("showDetailsForFavoriteAnime", sender: item)
        case item as Show:
            performSegueWithIdentifier("showDetailsForFavoriteShow", sender: item)
        case item as Movie:
            performSegueWithIdentifier("showDetailsForFavoriteMovie", sender: item)
        default:
            break
        }
    }
}
