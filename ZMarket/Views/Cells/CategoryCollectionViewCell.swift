//
//  CategoryCollectionViewCell.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 9/22/20.
//  Copyright © 2020 Zouhair Sassi. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    func generateCell(_ category: Category) {
        nameLabel.text = category.name
        imageView.image = category.image
    }
}
