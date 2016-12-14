//
//  DataManager.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/24/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import Foundation

struct Notifications {
    static let FavoritesDidChangeNotification = "FavoritesDidChangeNotification"
}

class DataManager {
    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
    let fileName = "Favorites.plist"
    var filePath: String {
        get {
            return fileURL.path
        }
    }
    var fileURL: URL {
        let url = URL(fileURLWithPath: documentsDirectory, isDirectory: true)
        return url.appendingPathComponent(fileName)
    }
    var favorites: [BasicInfo]?

    init() {
        loadFavorites()
    }
    
    class func sharedManager() -> DataManager {
        struct Static { static let instance: DataManager = DataManager() }
        return Static.instance
    }

    fileprivate func loadFavorites() -> [BasicInfo]? {
        if FileManager.default.fileExists(atPath: filePath) {
            let data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
            if let data = data {
                self.favorites = NSKeyedUnarchiver.unarchiveObject(with: data) as! [BasicInfo]?
                return self.favorites
            }
        }
        return nil
    }
    
    fileprivate func saveFavorites(_ items: [BasicInfo]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: items)
        try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
        self.favorites = items
    }
    
    // MARK: -
    
    func isFavorite(_ item: BasicInfo) -> Bool {
        let favoriteItem = self.favorites?.filter({ $0.identifier == item.identifier }).first
        if favoriteItem != nil {
            return true
        }
        return false
    }
    
    func addToFavorites(_ item: BasicInfo) {
        var items = [BasicInfo]()
        if let favorites = loadFavorites() {
            items += favorites
        }
        items.append(item)
        saveFavorites(items)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.FavoritesDidChangeNotification), object: nil)
    }
    
    func removeFromFavorites(_ item: BasicInfo) {
        let items = loadFavorites()
            if var items = items {
            let favoriteItem = items.filter({ $0.identifier == item.identifier }).first
            if let favoriteItem = favoriteItem {
                let idx = items.index(of: favoriteItem)
                items.remove(at: idx!)
                saveFavorites(items)

                NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.FavoritesDidChangeNotification), object: nil)
            }
        }
    }
}

    
