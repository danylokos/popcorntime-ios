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
        guard let URL = URL else { return }
        
        SDWebImageDownloader.sharedDownloader().downloadImageWithURL(URL, options: [SDWebImageDownloaderOptions.UseNSURLCache], progress: nil) {
            (image, data, error, finished) -> Void in
            if let _ = error { NSLog("\(__FUNCTION__): \(error)") }

            dispatch_async(dispatch_get_main_queue(), {
                completionBlock(downloadedImage: image)
            })
        }
    }
    
}
