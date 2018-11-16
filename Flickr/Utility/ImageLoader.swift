//
//  ImageLoader.swift
//  Flickr
//
//  Created by Vino (Vinodha) Sundaramoorthy on 11/15/18.
//  Copyright © 2018 Flickr. All rights reserved.
//

import Foundation
import UIKit

class ImageLoader {
    
    //Image is loaded asynchronously , without blocking the UI
    //If the image url is found in cache , the image data is fetched from the cache , this saves us some time
    
    private static let cache = NSCache<NSString, NSData>()
    class func image(for url: URL, completionHandler: @escaping(_ image: UIImage?) -> ()) {
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            
            if let data = self.cache.object(forKey: url.absoluteString as NSString) {
                DispatchQueue.main.async { completionHandler(UIImage(data: data as Data)) }
                return
            }
            
            guard let data = NSData(contentsOf: url) else {
                DispatchQueue.main.async { completionHandler(nil) }
                return
            }
            
            self.cache.setObject(data, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async { completionHandler(UIImage(data: data as Data)) }
        }
    }
}
