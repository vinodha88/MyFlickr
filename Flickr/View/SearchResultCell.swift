//
//  SearchResultCell.swift
//  Flickr
//
//  Created by Vino (Vinodha) Sundaramoorthy on 11/15/18.
//  Copyright © 2018 Flickr. All rights reserved.
//

import Foundation
import UIKit

class SearchResultCell : UITableViewCell {
    @IBOutlet weak var tile : UILabel!
    @IBOutlet weak var resultImage : UIImageView!
    
    func setupWithPhoto(model : FlickrModel) {
        tile.text = model.title
        ImageLoader.image(for: model.photoUrl) { (image) in
            DispatchQueue.main.async(execute: { () -> Void in
                self.resultImage.image = images
            })
        }
    }
}
