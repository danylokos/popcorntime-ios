//
//  BasicInfo.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/19/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import Foundation

protocol ContainsEpisodes {
    func episodeFor(seasonIndex: Int, episodeIndex: Int) -> Episode
    func episodesFor(seasonIndex: Int) -> [Episode]
}

protocol BasicInfoProtocol {
    var identifier: String! {get}
    var title: String? {get}
    var year: String? {get}
    var images: [Image]! {get}
    var smallImage: Image? {get}
    var bigImage: Image? {get}
    var isFavorite: Bool {get}
 
    init(dictionary: [AnyHashable: Any])
    func update(_ dictionary: [AnyHashable: Any])
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
    
    required init(dictionary: [AnyHashable: Any]) {
//        fatalError("init(dictionary:) has not been implemented")
    }

    func update(_ dictionary: [AnyHashable: Any]) {
        fatalError("update(dictionary:) has not been implemented")
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        guard
            let identifier = aDecoder.decodeObject(forKey: "identifier") as? String
            else { return nil }
        
        self.identifier = identifier
        self.title = aDecoder.decodeObject(forKey: "title") as? String
        self.year = aDecoder.decodeObject(forKey: "year") as? String
        self.smallImage = aDecoder.decodeObject(forKey: "smallImage") as? Image
        self.bigImage = aDecoder.decodeObject(forKey: "bigImage") as? Image
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(year, forKey: "year")
        aCoder.encode(smallImage, forKey: "smallImage")
        aCoder.encode(bigImage, forKey: "bigImage")
    }
}
