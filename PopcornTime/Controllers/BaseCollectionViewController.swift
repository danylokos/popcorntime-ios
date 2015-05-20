//
//  ShowsCollectionViewController.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/8/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

let reuseIdentifierShow = "ShowCell"
let reuseIdentifierMore = "MoreShowsCell"

///Base class for displaying collection of shows, subclass MUST override reloadData() and set self.shows in it
class BaseCollectionViewController: BarHidingViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private struct Constants{
        static let desirediPadCellWidth = 160
        static let desirediPadCellHeight = 205
        static let numberOfLinesiPhonePortrait = 2
        static let numberOfItemsiPhonePortrait = 2
        static let numberOfLinesiPhoneLandscape = 2
        static let numberOfItemsiPhoneLandscape = 5
    }
    
    var items = [BasicInfo]()
    var showLoadMoreCell = false
    
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.alwaysBounceVertical = true
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.registerNib(UINib(nibName: "ShowCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierShow)
        self.collectionView!.registerNib(UINib(nibName: "MoreShowsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierMore)
        self.collectionView?.delegate = self
        self.collectionView?.collectionViewLayout.invalidateLayout()
        
        self.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let additionalCellsCount = self.showLoadMoreCell ? 1 : 0
        return (items.count + additionalCellsCount)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if (self.showLoadMoreCell && indexPath.row == items.count) {
            //Last cell
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierMore, forIndexPath: indexPath) as! MoreShowsCollectionViewCell
            return cell
        }else{
            //Ordinary show cell
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierShow, forIndexPath: indexPath) as! ShowCollectionViewCell
            
            let item = items[indexPath.row]
            cell.title = item.title
            
            if let imageItem = item.smallImage {
                if let image = imageItem.image {
                    cell.image = image
                } else {
                    ImageProvider.sharedInstance.imageFromURL(URL: imageItem.URL) { (image) -> () in
                        imageItem.image = image
                        collectionView.reloadItemsAtIndexPaths([indexPath])
                    }
                }
            }
            return cell
        }
    }

    // MARK: UICollectionViewDelegateFlowLayout & UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let visibleAreaHeight = collectionView.bounds.height - navigationController!.navigationBar.bounds.height - UIApplication.sharedApplication().statusBarFrame.height - self.tabBarController!.tabBar.bounds.height
        let visibleAreaWidth = collectionView.bounds.width
        
        //Set cell size based on size class.
        let sizeClass = (horizontal: self.view.traitCollection.horizontalSizeClass, vertical: self.view.traitCollection.verticalSizeClass)
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout{
            switch sizeClass{
            case (.Compact,.Regular):
                //iPhone portrait
                let cellWidth = ((visibleAreaWidth - CGFloat(Constants.numberOfItemsiPhonePortrait - 1)*flowLayout.minimumInteritemSpacing - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom)/CGFloat(Constants.numberOfItemsiPhonePortrait))
                let cellHeight = ((visibleAreaHeight - CGFloat(Constants.numberOfLinesiPhonePortrait - 1)*flowLayout.minimumLineSpacing - flowLayout.sectionInset.left - flowLayout.sectionInset.right)/CGFloat(Constants.numberOfLinesiPhonePortrait))
                return CGSizeMake(cellWidth, cellHeight)
            case (_,.Compact):
                //iPhone landscape
                let cellWidth = ((collectionView.bounds.width - CGFloat(Constants.numberOfItemsiPhoneLandscape - 1)*flowLayout.minimumInteritemSpacing - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom)/CGFloat(Constants.numberOfItemsiPhoneLandscape))
                let cellHeight = ((collectionView.bounds.height - CGFloat(Constants.numberOfLinesiPhoneLandscape - 1)*flowLayout.minimumLineSpacing - flowLayout.sectionInset.left - flowLayout.sectionInset.right)/CGFloat(Constants.numberOfLinesiPhoneLandscape))
                return CGSizeMake(cellWidth, cellHeight)
            case (_,_):
                // iPad. Calculate cell size based on desired size
                let numberOfLines = Int(visibleAreaHeight) / Constants.desirediPadCellHeight
                let betweenLinesSpaceSum = CGFloat(numberOfLines - 1) * flowLayout.minimumLineSpacing
                let sectionInsetsVerticalSum = flowLayout.sectionInset.top + flowLayout.sectionInset.bottom
                
                let adjustedHeight = (visibleAreaHeight - betweenLinesSpaceSum  - sectionInsetsVerticalSum)/CGFloat(numberOfLines)
                let adjustedWidth = adjustedHeight * CGFloat(Constants.desirediPadCellWidth) / CGFloat(Constants.desirediPadCellHeight)
                
                return CGSizeMake(adjustedWidth, adjustedHeight)
            default: return CGSizeMake(50, 50)
            }
        }
        
        return CGSizeMake(50, 50)
    }
    
    // MARK: - ShowsCollectionViewController
    func reloadData(){
        assert(true, "Sublcass MUST override this method")
    }
}
