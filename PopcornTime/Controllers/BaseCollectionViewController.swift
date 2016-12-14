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
    
    fileprivate struct Constants{
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
        
        self.collectionView!.register(UINib(nibName: "ShowCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierShow)
        self.collectionView!.register(UINib(nibName: "MoreShowsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierMore)
        self.collectionView?.delegate = self
        self.collectionView?.collectionViewLayout.invalidateLayout()
        
        self.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let additionalCellsCount = self.showLoadMoreCell ? 1 : 0
        return (items.count + additionalCellsCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (self.showLoadMoreCell && indexPath.row == items.count) {
            //Last cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierMore, for: indexPath) as! MoreShowsCollectionViewCell
            return cell
        } else {
            //Ordinary show cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierShow, for: indexPath) as! ShowCollectionViewCell
            
            let item = items[indexPath.row]
            cell.title = item.title
            
            let imageItem = item.smallImage
            switch imageItem?.status {
            case .new?:
                imageItem?.status = .downloading
                ImageProvider.sharedInstance.imageFromURL(URL: imageItem?.URL) { (downloadedImage) -> () in
                    imageItem?.image = downloadedImage
                    imageItem?.status = .finished
                    
                    collectionView.reloadItems(at: [indexPath])
                }
            case .finished?:
                cell.image = imageItem?.image
            default: break
            }

            return cell
        }
    }

    // MARK: UICollectionViewDelegateFlowLayout & UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let visibleAreaHeight = collectionView.bounds.height - navigationController!.navigationBar.bounds.height - UIApplication.shared.statusBarFrame.height - self.tabBarController!.tabBar.bounds.height
        let visibleAreaWidth = collectionView.bounds.width
        
        //Set cell size based on size class.
        let sizeClass = (horizontal: self.view.traitCollection.horizontalSizeClass, vertical: self.view.traitCollection.verticalSizeClass)
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout{
            switch sizeClass{
            case (.compact,.regular):
                //iPhone portrait
                let cellWidth = ((visibleAreaWidth - CGFloat(Constants.numberOfItemsiPhonePortrait - 1)*flowLayout.minimumInteritemSpacing - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom)/CGFloat(Constants.numberOfItemsiPhonePortrait))
                let cellHeight = ((visibleAreaHeight - CGFloat(Constants.numberOfLinesiPhonePortrait - 1)*flowLayout.minimumLineSpacing - flowLayout.sectionInset.left - flowLayout.sectionInset.right)/CGFloat(Constants.numberOfLinesiPhonePortrait))
                return CGSize(width: cellWidth, height: cellHeight)
            case (_,.compact):
                //iPhone landscape
                let cellWidth = ((collectionView.bounds.width - CGFloat(Constants.numberOfItemsiPhoneLandscape - 1)*flowLayout.minimumInteritemSpacing - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom)/CGFloat(Constants.numberOfItemsiPhoneLandscape))
                let cellHeight = ((collectionView.bounds.height - CGFloat(Constants.numberOfLinesiPhoneLandscape - 1)*flowLayout.minimumLineSpacing - flowLayout.sectionInset.left - flowLayout.sectionInset.right)/CGFloat(Constants.numberOfLinesiPhoneLandscape))
                return CGSize(width: cellWidth, height: cellHeight)
            case (_,_):
                // iPad. Calculate cell size based on desired size
                let numberOfLines = Int(visibleAreaHeight) / Constants.desirediPadCellHeight
                let betweenLinesSpaceSum = CGFloat(numberOfLines - 1) * flowLayout.minimumLineSpacing
                let sectionInsetsVerticalSum = flowLayout.sectionInset.top + flowLayout.sectionInset.bottom
                
                let adjustedHeight = (visibleAreaHeight - betweenLinesSpaceSum  - sectionInsetsVerticalSum)/CGFloat(numberOfLines)
                let adjustedWidth = adjustedHeight * CGFloat(Constants.desirediPadCellWidth) / CGFloat(Constants.desirediPadCellHeight)
                
                return CGSize(width: adjustedWidth, height: adjustedHeight)
            }
        }
        
        return CGSize(width: 50, height: 50)
    }
    
    // MARK: - ShowsCollectionViewController
    func reloadData(){
        assert(true, "Sublcass MUST override this method")
    }
}
