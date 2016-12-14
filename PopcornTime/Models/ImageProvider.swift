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

    func imageFromURL(URL: Foundation.URL?, completionBlock: @escaping (_ downloadedImage: UIImage?)->()) {
        guard let URL = URL else { return }
        
        SDWebImageDownloader.shared().downloadImage(with: URL, options: [SDWebImageDownloaderOptions.useNSURLCache], progress: nil) {
            (image, data, error, finished) -> Void in
            if let _ = error { NSLog("\(#function): \(error)") }

            DispatchQueue.main.async(execute: {
                completionBlock(image)
            })
        }
    }
    
}
