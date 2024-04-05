//
//  SelectedProductCell.swift
//  Vendour
//
//  Created by AppDev on 06/02/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class SelectedProductCell: UICollectionViewCell {
    @IBOutlet weak var rightBar: UILabel!
    @IBOutlet weak var leftBar: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var tickCrossImage: UIImageView!
    @IBOutlet weak var insideView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        borderView.layer.cornerRadius = self.borderView.frame.size.width / 2
        borderView.clipsToBounds = true
        borderView.layer.masksToBounds = true
        insideView.layer.cornerRadius = self.insideView.frame.size.width / 2
        insideView.clipsToBounds = true
        insideView.layer.masksToBounds = true
    }

}
