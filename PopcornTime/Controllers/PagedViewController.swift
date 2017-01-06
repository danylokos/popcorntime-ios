//
//  PagedViewController.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/19/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class PagedViewController: BaseCollectionViewController, UISearchBarDelegate, UISearchResultsUpdating  {
   
    fileprivate var contentPage: UInt = 0

    var searchResults = [BasicInfo]()
    var searchController: UISearchController?
    var searchTimer: Timer?

    var showType: PTItemType {
        get {
            assert(false, "this must be overriden by subclass")
            return .movie
        }
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearch()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionViewLayout?.invalidateLayout()
    }
    
    fileprivate func setupSearch() {
        
        self.definesPresentationContext = true
        
        searchController = UISearchController(searchResultsController: nil)
        searchController!.searchResultsUpdater = self
        searchController!.hidesNavigationBarDuringPresentation = false
        searchController!.dimsBackgroundDuringPresentation = false
        
        let searchBar = searchController!.searchBar
        searchBar.delegate = self
        searchBar.barStyle = .black
        searchBar.backgroundImage = UIImage()
        searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        
        let searchBarContainer = UIView(frame: navigationController!.navigationBar.bounds)
        searchBarContainer.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = searchBarContainer
        
        let views = ["searchBar" : searchBar]
        searchBarContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[searchBar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        searchBarContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[searchBar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }

    // MARK:
    
    func map(_ response: [AnyObject]) -> [BasicInfo] {
        return [BasicInfo]()
    }
    
    override func reloadData() {
        PTAPIManager.shared().topShows(with: showType, withPage: contentPage, success: { (items) -> Void in
            self.showLoadMoreCell = true
            if let items = items {
                self.items = self.map(items as [AnyObject])
                self.collectionView?.reloadData()
            }
            }, failure: nil)
    }
    
    func loadMore() {
        PTAPIManager.shared().topShows(with: showType, withPage: contentPage+1, success: { (items) -> Void in
            if let items = items {
                self.contentPage += 1
                let newItems = self.map(items as [AnyObject])
                let newShowsIndexPathes = newItems.enumerated().map({ (index, item) in
                    return IndexPath(row: (self.items.count + index), section: 0)
                })
                self.items += newItems
                
                self.collectionView?.insertItems(at: newShowsIndexPathes)
            }
            }, failure: nil)
    }
    
    func performSearch() {
        let text = searchController!.searchBar.text
        if text!.characters.count > 0 {
            PTAPIManager.shared().searchForShow(with: showType, name: text, success: { (items) -> Void in
                self.showLoadMoreCell = false
                if let items = items {
                    self.searchResults = self.map(items as [AnyObject])
                } else {
                    self.searchResults.removeAll(keepingCapacity: false)
                }
                self.collectionView?.reloadData()
                }, failure: nil)
        }
    }

    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchController != nil && searchController!.isActive {
            return searchResults.count
        }
        return super.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if searchController != nil && searchController!.isActive {
            //Ordinary show cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierShow, for: indexPath) as! ShowCollectionViewCell
            
            let item = searchResults[indexPath.row]
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
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: IndexPath) {
        if indexPath.row == items.count {
            loadMore()
        }
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchTimer?.invalidate()
        self.searchTimer = nil
        performSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.showLoadMoreCell = true
        
        self.searchTimer?.invalidate()
        self.searchTimer = nil
        
        searchResults.removeAll(keepingCapacity: false)
        self.collectionView.reloadData()
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        self.searchTimer?.invalidate()
        self.collectionView.reloadData()
        self.searchTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PagedViewController.performSearch), userInfo: nil, repeats: false)
    }
}
