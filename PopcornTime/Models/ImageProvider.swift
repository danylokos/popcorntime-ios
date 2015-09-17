//
//  ImageProvider.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/10/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class ImageProvider: NSObject {
    
    static let sharedInstance = ImageProvider()

    func imageFromURL(URL URL: NSURL?, completionBlock: (downloadedImage: UIImage?)->()) {
        if URL == nil {
            return
        }
        
        SDWebImageDownloader.sharedDownloader().downloadImageWithURL(URL, options: [], progress: nil)
            { (image, data, error, finished) -> Void in
                if let _ = error { print("\(error)") }
                dispatch_async(dispatch_get_main_queue(), {
                    completionBlock(downloadedImage: image)
                })
        }
    }
    
}
