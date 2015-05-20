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

        identifier = dictionary["ImdbCode"] as! String
        title = dictionary["MovieTitleClean"] as? String
        year = dictionary["MovieYear"] as? String
        
        if let cover = dictionary["CoverImage"] as? String {
            images = [Image]()

            var URL = NSURL(string: cover)
            var image = Image(URL: URL!, type: .Poster)
            images.append(image)
        }
        
        smallImage = self.images.filter({$0.type == ImageType.Poster}).first
        bigImage = smallImage
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func update(dictionary: NSDictionary) {
        videos.removeAll(keepCapacity: true)
        
        let movieList = dictionary["MovieList"] as! NSArray
        for movieDict in movieList  {
            let quality = movieDict["Quality"] as! String
            let title = movieDict["MovieTitleClean"]as! String
            let magnetLink = movieDict["TorrentMagnetUrl"]as! String

            var video = Video(name: title, quality: quality, size: 0, duration: 0, subGroup: nil, magnetLink: magnetLink)
            videos.append(video)
        }
    }
}