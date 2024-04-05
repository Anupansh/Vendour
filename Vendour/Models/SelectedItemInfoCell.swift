//
//  SelectedItemInfoCell.swift
//  Vendour
//
//  Created by AppDev on 10/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class SelectedItemInfoCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var numberOfItemsLabel: UILabel!
    
    
    var plusClosure : (() -> ())?
    var minusClosure : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.borderWidth = 1.0
        backView.layer.borderColor = UIColor.lightGray.cgColor
        // Initialization code
    }
    @IBAction func minusBtnPressed(_ sender: Any) {
        minusClosure!()
    }
    
    @IBAction func plusBtnPressed(_ sender: Any) {
        plusClosure!()
    }
}
