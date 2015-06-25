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

    required init(dictionary: NSDictionary) {
        super.init(dictionary: dictionary)

        let id = dictionary["id"] as! Int
        identifier = "\(id)"
        title = dictionary["title"] as? String
        year = dictionary["year"] as? String
        
        images = [Image]()
        if let cover = dictionary["medium_cover_image"] as? String {
            var image = Image(URL: NSURL(string: cover)!, type: .Poster)
            images.append(image)
        }
        
        if let cover = dictionary["background_image"] as? String {
            var image = Image(URL: NSURL(string: cover)!, type: .Banner)
            images.append(image)
        }

        smallImage = self.images.filter({$0.type == ImageType.Poster}).first
        bigImage = self.images.filter({$0.type == ImageType.Banner}).first
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func update(dictionary: NSDictionary) {
        videos.removeAll(keepCapacity: true)
        
        let title = dictionary["title"] as! String
//        let runtime = dictionary["runtime"] as! UInt
        
        if let movieList = dictionary["torrents"] as? NSArray {
            for movieDict in movieList {
                let quality = movieDict["quality"] as! String
                let hash = movieDict["hash"] as! String
                let magnetLink = "magnet:?xt=urn:btih:\(hash)&tr=udp://open.demonii.com:1337&tr=udp://tracker.coppersurfer.tk:6969"
//                let size = movieDict["size_bytes"] as! UInt
                
                var video = Video(name: title, quality: quality, size: 0, duration: 0, subGroup: nil, magnetLink: magnetLink)
                videos.append(video)
            }
        }
    }
}