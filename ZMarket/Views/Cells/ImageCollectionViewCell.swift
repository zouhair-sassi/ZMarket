//
//  ImageCollectionViewCell.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 11/24/20.
//  Copyright © 2020 Zouhair Sassi. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!

    func setupImageWidth(itemImage: UIImage)  {
        imageView.image = itemImage
    }
}
