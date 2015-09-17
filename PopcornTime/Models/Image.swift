//
//  File.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/21/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

enum ImageType: Int {
    case Banner, Poster, Fanart
}

//enum ImageStatus {
//    case New, Downloading, Finished
//}

class Image: NSObject, NSCoding {
    let URL: NSURL
    var image: UIImage?
    let type: ImageType
//    var status: ImageStatus = .New
    
    init(URL: NSURL, type: ImageType) {
        self.URL = URL
        self.type = type
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        URL = aDecoder.decodeObjectForKey("URL") as! NSURL
        let typeRaw = aDecoder.decodeObjectForKey("type") as! Int
        type = ImageType(rawValue: typeRaw)!
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(URL, forKey: "URL")
        aCoder.encodeObject(type.rawValue, forKey: "type")
    }
}
