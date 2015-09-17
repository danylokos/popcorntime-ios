//
//  PagedViewController.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/19/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class PagedViewController: BaseCollectionViewController, UISearchBarDelegate, UISearchResultsUpdating  {
   
    private var contentPage: UInt = 0

    var searchResults = [BasicInfo]()
    var searchController: UISearchController?
    var searchTimer: NSTimer?

    var showType: PTItemType {
        get {
            assert(false, "this must be overriden by subclass")
            return .Movie
        }
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearch()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        collectionViewLayout?.invalidateLayout()
    }
    
    private func setupSearch() {
        
        self.definesPresentationContext = true
        
        searchController = UISearchController(searchResultsController: nil)
        searchController!.searchResultsUpdater = self
        searchController!.hidesNavigationBarDuringPresentation = false
        searchController!.dimsBackgroundDuringPresentation = false
        
        let searchBar = searchController!.searchBar
        searchBar.delegate = self
        searchBar.barStyle = .Black
        searchBar.backgroundImage = UIImage()
        
        
        let searchBarContainer = UIView(frame: navigationController!.navigationBar.bounds)
        searchBarContainer.addSubview(searchBar)
        searchBar.setTranslatesAutoresizingMaskIntoConstraints(false)
        navigationItem.titleView = searchBarContainer
        
        let views = ["searchBar" : searchBar]
        searchBarContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[searchBar]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
        searchBarContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[searchBar]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    }

    // MARK:
    
    func map(response: [AnyObject]) -> [BasicInfo] {
        return [BasicInfo]()
    }
    
    override func reloadData() {
        PTAPIManager.sharedManager().topShowsWithType(showType, withPage: contentPage, success: { (items) -> Void in
            self.showLoadMoreCell = true
            if let items = items {
                self.items = self.map(items)
                self.collectionView?.reloadData()
            }
            }, failure: nil)
    }
    
    func loadMore() {
        PTAPIManager.sharedManager().topShowsWithType(showType, withPage: contentPage+1, success: { (items) -> Void in
            if let items = items {
                self.contentPage++
                let newItems = self.map(items)
                var counter = 0
                var newShowsIndexPathes = newItems.map({ item in NSIndexPath(forRow: (self.items.count + counter++), inSection: 0) } )
                self.items += newItems
                
                self.collectionView?.insertItemsAtIndexPaths(newShowsIndexPathes)
            }
            }, failure: nil)
    }
    
    func performSearch() {
        var text = searchController!.searchBar.text
        if count(text) > 0 {
            PTAPIManager.sharedManager().searchForShowWithType(showType, name: text, success: { (items) -> Void in
                self.showLoadMoreCell = false
                if let items = items {
                    self.searchResults = self.map(items)
                } else {
                    self.searchResults.removeAll(keepCapacity: false)
                }
                self.collectionView?.reloadData()
                }, failure: nil)
        }
    }

    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchController != nil && searchController!.active {
            return searchResults.count
        }
        return super.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if searchController != nil && searchController!.active {
            //Ordinary show cell
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierShow, forIndexPath: indexPath) as! ShowCollectionViewCell
            
            var item = searchResults[indexPath.row]
            cell.title = item.title
            
            if let image = item.smallImage?.image {
                cell.image = image
            } else {
                ImageProvider.sharedInstance.imageFromURL(URL: item.smallImage?.URL) { (downloadedImage) -> () in
                    item.smallImage?.image = downloadedImage
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                }
            }

            return cell
        }
        return super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == items.count {
            loadMore()
        }
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchTimer?.invalidate()
        self.searchTimer = nil
        performSearch()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        self.showLoadMoreCell = true
        
        self.searchTimer?.invalidate()
        self.searchTimer = nil
        
        searchResults.removeAll(keepCapacity: false)
        self.collectionView.reloadData()
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.searchTimer?.invalidate()
        self.collectionView.reloadData()
        self.searchTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "performSearch", userInfo: nil, repeats: false)
    }
}
