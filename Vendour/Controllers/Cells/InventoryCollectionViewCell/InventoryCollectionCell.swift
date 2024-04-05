//
//  InventoryCollectionCell.swift
//  Vendour
//
//  Created by Clixlogix on 03/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class InventoryCollectionCell: UICollectionViewCell {
    @IBOutlet var imageviewProduct : UIImageView!
    @IBOutlet var labelPrice : UILabel!
    @IBOutlet var labelQuantity : UILabel!
    @IBOutlet var viewRoot : UIView!
    
    override func awakeFromNib() {
        viewRoot.layer.borderColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 0.3).cgColor
        viewRoot.layer.borderWidth = 1.0
    }
}
