//
//  MoviesViewController.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/15/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class AnimeViewController: PagedViewController {

    override var showType: PTItemType {
        get {
            return .Anime
        }
    }

    override func map(response: [AnyObject]) -> [BasicInfo] {
        return response.map({ Anime(dictionary: $0 as! NSDictionary) })
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath){
            //Check if cell is MoreShowsCell
            if let _ = cell as? MoreShowsCollectionViewCell{
                loadMore()
            } else {
                performSegueWithIdentifier("showDetails", sender: cell)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "showDetails"{
            if let episodesVC = segue.destinationViewController as? AnimeDetailsViewController{
                if let senderCell = sender as? UICollectionViewCell{
                    if let indexPath = collectionView!.indexPathForCell(senderCell){
                        var item: BasicInfo!
                        if (searchController!.active) {
                            item = searchResults[indexPath.row]
                        } else {
                            item = items[indexPath.row]
                        }
                        episodesVC.item = item as! Anime
                    }
                }
            }
        }
    }
}
