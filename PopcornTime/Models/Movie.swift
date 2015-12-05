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

        let id = (dictionary["id"] as! NSString).intValue
        identifier = "\(id)"
        title = dictionary["title"] as? String
        year = String(dictionary["year"])
        
        images = [Image]()
        if let cover = dictionary["poster_med"] as? String {
            let image = Image(URL: NSURL(string: cover)!, type: .Poster)
            images.append(image)
        }
        
        if let cover = dictionary["poster_big"] as? String {
            let image = Image(URL: NSURL(string: cover)!, type: .Banner)
            images.append(image)
        }

        smallImage = self.images.filter({$0.type == ImageType.Poster}).first
        bigImage = self.images.filter({$0.type == ImageType.Banner}).first
        synopsis = dictionary["description"] as? String
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func update(dictionary: NSDictionary) {
        videos.removeAll(keepCapacity: true)
        
        let title = dictionary["title"] as! String
//        let runtime = dictionary["runtime"] as! UInt
        
        if let movieList = dictionary["items"] as? NSArray {
            for movieDict in movieList {
                let quality = movieDict["quality"] as! String
                //let hash = movieDict["hash"] as! String
                let magnetLink = movieDict["torrent_magnet"] as! String
/*                let magnetLink = "magnet:?xt=urn:btih:\(hash)&tr=udp://open.demonii.com:1337&tr=udp://tracker.coppersurfer.tk:6969"
*/
                let size = movieDict["size_bytes"] as! UInt
                
                let video = Video(name: title, quality: quality, size: size, duration: 0, subGroup: nil, magnetLink: magnetLink)
                videos.append(video)
            }
        }
    }
}