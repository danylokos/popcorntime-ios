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

    lazy var ramCache = NSCache()
    lazy var cacheQueue = dispatch_queue_create("com.popcorntime.imageprovider.cachequeue", DISPATCH_QUEUE_CONCURRENT)
    lazy var downloadQueue = dispatch_queue_create("com.popcorntime.imageprovider.downloadqueue", DISPATCH_QUEUE_SERIAL)
    
    ///Method to get image with specific type, will give a cached image if it was cached. Completion block is called in main queue.
    func imageFromURL(#URL: NSURL, completionBlock: (image: UIImage?)->()) {
        let fileName = CocoaSecurity.md5(URL.absoluteString).hexLower
        
        //Check if image is in ram cache
        dispatch_sync(self.cacheQueue, {
            if let cachedImage = self.ramCache.objectForKey(fileName) as? UIImage {
                dispatch_async(dispatch_get_main_queue(), {
                    completionBlock(image: cachedImage)
                    return
                })
            }
        })
        
        //Check if image is cached to disk
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as! String
        let filePath = cachesDirectory.stringByAppendingPathComponent(fileName)
        
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            //Use cached image
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                if let imageData = NSData(contentsOfFile: filePath), image = UIImage(data: imageData) {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionBlock(image: image)
                    })

                    //Add image to ram cache
                    dispatch_barrier_async(self.cacheQueue, {
                        self.ramCache.setObject(image, forKey: fileName)
                    })
                } else {
                    assert(false, "Cached image could not be read")
                }
            })
        } else {
            //File not cached
            dispatch_async(self.downloadQueue, {
                if let data = NSData(contentsOfURL: URL), image = UIImage(data: data) {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionBlock(image: image)
                    })
                    
                    //Add image to ram cache
                    dispatch_barrier_async(self.cacheQueue, {
                        self.ramCache.setObject(image, forKey: fileName)
                        UIImageJPEGRepresentation(image, 1.0).writeToFile(filePath, atomically: true)
                    })
                }
            })
        }
    }
}



