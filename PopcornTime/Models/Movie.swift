//
//  Movie.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/19/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import Foundation

class Movie: BasicInfo {
    var videos = [Video]()

    required init(dictionary: [AnyHashable: Any]) {
        super.init(dictionary: dictionary)

        let id = (dictionary["id"] as! NSString).intValue
        identifier = "\(id)"
        title = dictionary["title"] as? String
        year = String(describing: dictionary["year"])
        
        images = [Image]()
        if let cover = dictionary["poster_med"] as? String {
            let image = Image(URL: URL(string: cover)!, type: .poster)
            images.append(image)
        }
        
        if let cover = dictionary["poster_big"] as? String {
            let image = Image(URL: URL(string: cover)!, type: .banner)
            images.append(image)
        }

        smallImage = self.images.filter({$0.type == ImageType.poster}).first
        bigImage = self.images.filter({$0.type == ImageType.banner}).first
        synopsis = dictionary["description"] as? String
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func update(_ dictionary: [AnyHashable: Any]) {
        videos.removeAll(keepingCapacity: true)
        
        let title = dictionary["title"] as! String
        
        guard let movieList = dictionary["items"] as? [[AnyHashable: Any]] else { return }
        for movieDict in movieList {
            let quality = movieDict["quality"] as! String
            let magnetLink = movieDict["torrent_magnet"] as! String
            let size = movieDict["size_bytes"] as! UInt

            let video = Video(name: title, quality: quality, size: size, duration: 0, subGroup: nil, magnetLink: magnetLink)
            videos.append(video)
        }
    }
}
