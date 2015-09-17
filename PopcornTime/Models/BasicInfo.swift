//
//  BasicInfo.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/19/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import Foundation

protocol ContainsEpisodes {
    func episodeFor(seasonIndex seasonIndex: Int, episodeIndex: Int) -> Episode
    func episodesFor(seasonIndex seasonIndex: Int) -> [Episode]
}

protocol BasicInfoProtocol {
    var identifier: String! {get}
    var title: String? {get}
    var year: String? {get}
    var images: [Image]! {get}
    var smallImage: Image? {get}
    var bigImage: Image? {get}
    var isFavorite: Bool {get}
 
    init(dictionary: NSDictionary)
    func update(dictionary: NSDictionary)
}

class BasicInfo: NSObject, BasicInfoProtocol, NSCoding {
    var identifier: String!
    var title: String?
    var year: String?
    var images: [Image]!
    var smallImage: Image?
    var bigImage: Image?
    var synopsis: String?

    var isFavorite : Bool {
        get {
            return DataManager.sharedManager().isFavorite(self)
        }
        set {
            if (isFavorite == true) {
                return DataManager.sharedManager().addToFavorites(self)
            } else {
                return DataManager.sharedManager().removeFromFavorites(self)
            }
        }
    }
    
    required init(dictionary: NSDictionary) {
//        fatalError("init(dictionary:) has not been implemented")
    }

    func update(dictionary: NSDictionary) {
        fatalError("update(dictionary:) has not been implemented")
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        identifier = aDecoder.decodeObjectForKey("identifier") as! String
        title = aDecoder.decodeObjectForKey("title") as? String
        year = aDecoder.decodeObjectForKey("year") as? String
        smallImage = aDecoder.decodeObjectForKey("smallImage") as? Image
        bigImage = aDecoder.decodeObjectForKey("bigImage") as? Image
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(identifier, forKey: "identifier")
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(year, forKey: "year")
        aCoder.encodeObject(smallImage, forKey: "smallImage")
        aCoder.encodeObject(bigImage, forKey: "bigImage")
    }
}