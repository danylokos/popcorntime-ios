//
//  File.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/21/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

enum ImageType: Int {
    case banner, poster, fanart
}

enum ImageStatus {
    case new, downloading, finished
}

class Image: NSObject, NSCoding {
    let URL: Foundation.URL
    var image: UIImage?
    let type: ImageType
    var status: ImageStatus = .new
    
    init(URL: Foundation.URL, type: ImageType) {
        self.URL = URL
        self.type = type
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        let typeRaw = aDecoder.decodeInteger(forKey: "type")
        guard
            let URL = aDecoder.decodeObject(forKey: "URL") as? Foundation.URL,
            let type = ImageType(rawValue: typeRaw)
            else { return nil }
        
        self.URL = URL
        self.type = type
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(URL, forKey: "URL")
        aCoder.encode(type.rawValue, forKey: "type")
    }
}
