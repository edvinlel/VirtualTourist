//
//  FlickrCache.swift
//  VirtualTourist
//
//  Created by Edvin Lellhame on 26/05/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

/**
I was having problems with getting the image from Core Data without lagging the interface. I got stuck for a while so I went to my mentor
at codementor.io and he walked me through this problem using a cache.
*/

import Foundation
import UIKit
import CoreData

class FlickrCache {
    
    static fileprivate let shared: NSCache = { () -> NSCache<AnyObject, AnyObject> in
        let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "cache"
        cache.countLimit = 200 // Max number of items in memory.
        cache.totalCostLimit = (cache.countLimit / 2) * 1024 * 1024 // Max Mb can be used (500 Kb per items).
        return cache
    }()
    
    // Getter for images
    static func get(_ forKey: String?) -> UIImage? {
        guard let forKey = forKey else { return nil }
        return shared.object(forKey: forKey as AnyObject) as? UIImage
    }
    
    // Setter for images
    static func set(_ data: UIImage, forKey: String?) {
        guard let forKey = forKey else { return }
        shared.setObject(data, forKey: forKey as AnyObject, cost: (UIImageJPEGRepresentation(data, 0)?.count) ?? 0)
    }
    
    // Remover
    static func remove(_ forKey: String?) {
        print("\n\nThe Key =",forKey ?? "\n\n\tNO KEY FOUND\n\n")
        guard let forKey = forKey else { return }
        shared.removeObject(forKey: forKey as AnyObject)
    }
}

extension UIImageView {
    typealias DownloadImageBlock = ( Data? , String? , Int?) -> Void
    typealias DownloadImageErrorBlock = ( Error , Int ) -> Void
	
    func setPhoto(_ photo:Photo) {
        DispatchQueue.global().async {
            if let img = FlickrCache.get(photo.media_url) {
                DispatchQueue.main.async {
                    self.image = img
                }
            }else {
                if let imgData = photo.image {
                    guard let img = UIImage(data: imgData as Data) else {
                        DispatchQueue.main.async {
                            self.image = nil
                        }
                        return
                    }
                    FlickrCache.set(img, forKey: photo.media_url)
                    DispatchQueue.main.async {
                        self.image = img
                    }
                }else {
                    DispatchQueue.main.async {
                        self.image = nil
                    }
                }
            }
        }
    }
    
    func setImageWith(_ photo:Photo,_ index:Int,completionHandler block:DownloadImageBlock?,errorHandlerBlock errorBlock:DownloadImageErrorBlock?) {
        DispatchQueue.global().async {
            guard let media_url = photo.media_url else {
                DispatchQueue.main.async {
                    if let block = block {
                        block(nil, nil, nil)
                    }
                    self.image = nil
                }
                return
            }
            if let img = FlickrCache.get(media_url) {
                DispatchQueue.main.async {
                    self.image = img
                }
             }else if let imgData = photo.image {
                guard let img = UIImage(data: imgData as Data) else{
					self.image = nil
					return
				}
                DispatchQueue.main.async {
                    self.image = img
                    FlickrCache.set(img, forKey: media_url)
                }
            } else {
                guard let url = URL(string: media_url) else {
                    DispatchQueue.main.async {
                        self.image = nil
                    }
                    return
                }
                do {
                    let data = try Data.init(contentsOf: url)
                    if let img = UIImage(data: data) {
                        FlickrCache.set(img, forKey: media_url)
                        DispatchQueue.main.async {
                            self.image = img
                            if let block = block {
                                block(data, media_url, index)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.image = nil
                        }
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        if let errorBlock = errorBlock {
                            errorBlock(error, index)
                        }
                        self.image = nil
                    }
                }
                
            }
        }
    }
}






