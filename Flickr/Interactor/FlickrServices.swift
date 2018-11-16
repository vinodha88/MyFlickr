//
//  FlickrServices.swift
//  Flickr
//
//  Created by Vino (Vinodha) Sundaramoorthy on 11/15/18.
//  Copyright © 2018 Flickr. All rights reserved.
//

import Foundation

let kBaseURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search"

class FlickrServices {
    typealias FlickrResponse = (NSError?, [FlickrModel]?) -> Void
    
    struct Keys {
        static let flickrAPIKey = "675894853ae8ec6c242fa4c077bcf4a0"
    }
    
    struct Errors {
        static let invalidAccessErrorCode = 100
    }
    
    class func getPhotosForText(_ searchText : String,onCompletion: @escaping FlickrResponse) -> Void {
        let searchText = searchText.addingPercentEncoding(withAllowedCharacters:.urlHostAllowed)!
        let urlString : String = String(format:"%@&api_key=%@&text=%@&extras=url_s&format=json&nojsoncallback=1",kBaseURL,Keys.flickrAPIKey,searchText)
        
        let url : NSURL = NSURL(string: urlString)!
        let searchTask = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                print("Error fetching photos: \(String(describing: error))")
                onCompletion(error as NSError?, nil)
                return
            }
            
            do {
                let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                guard let results = resultsDictionary else { return }
                
                if let statusCode = results["code"] as? Int {
                    if statusCode == Errors.invalidAccessErrorCode {
                        let invalidAccessError = NSError(domain: "com.flickr.api", code: statusCode, userInfo: nil)
                        onCompletion(invalidAccessError, nil)
                        return
                    }
                }
                
                guard let photosContainer = resultsDictionary!["photos"] as? NSDictionary else { return }
                guard let photosArray = photosContainer["photo"] as? [NSDictionary] else { return }
                
                let flickrPhotos: [FlickrModel] = photosArray.map { photoDict in
                    
                    let photoId = photoDict["id"] as? String ?? ""
                    let farm = photoDict["farm"] as? Int ?? 0
                    let secret = photoDict["secret"] as? String ?? ""
                    let server = photoDict["server"] as? String ?? ""
                    let title = photoDict["title"] as? String ?? ""
                    
                    let flickrPhoto = FlickrModel(id: photoId, farm: farm, secret: secret, server: server, title: title)
                    return flickrPhoto
                }
                
                onCompletion(nil, flickrPhotos)
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(error, nil)
                return
            }
            
        })
        searchTask.resume()
    }
}
