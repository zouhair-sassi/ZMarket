//
//  ItemTableViewCell.swift
//  ZMarket
//
//  Created by Zouhair Sassi on 10/3/20.
//  Copyright © 2020 Zouhair Sassi. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func generateCell(_ item: Item) {
        nameLabel.text = item.name ?? ""
        descriptionLabel.text = item.description ?? ""
        priceLabel.text = "\(item.price ?? 0)"
        //TODO download image
    }

}