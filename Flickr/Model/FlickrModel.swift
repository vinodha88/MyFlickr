//
//  FlickrModel.swift
//  Flickr
//
//  Created by Vino (Vinodha) Sundaramoorthy on 11/15/18.
//  Copyright © 2018 Flickr. All rights reserved.
//

import Foundation
import UIKit

struct FlickrModel {
    let id : String
    let farm : Int
    let secret : String
    let server : String
    let title : String
    var photoUrl: URL {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_m.jpg")!
    }
}

