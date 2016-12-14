//
//  MoviesViewController.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/19/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class MoviesViewController: PagedViewController {
    
    override var showType: PTItemType {
        get {
            return .movie
        }
    }

    override func map(_ response: [AnyObject]) -> [BasicInfo] {
        let items = response.map({ Movie(dictionary: $0 as! [AnyHashable: Any]) }) as [BasicInfo]
        return items
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath){
            //Check if cell is MoreShowsCell
            if let _ = cell as? MoreShowsCollectionViewCell{
                loadMore()
            } else {
                performSegue(withIdentifier: "showDetails", sender: cell)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showDetails"{
            if let episodesVC = segue.destination as? MovieDetailsViewController{
                if let senderCell = sender as? UICollectionViewCell{
                    if let indexPath = collectionView!.indexPath(for: senderCell) {
                        var item: BasicInfo!
                        if (searchController!.isActive) {
                            item = searchResults[indexPath.row]
                        } else {
                            item = items[indexPath.row]
                        }
                        episodesVC.item = item as! Movie
                    }
                }
            }
        }
    }
}
