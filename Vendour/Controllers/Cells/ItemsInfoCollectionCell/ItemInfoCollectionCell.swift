//
//  ItemInfoCollectionCell.swift
//  Vendour
//
//  Created by AppDev on 08/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

protocol CloseCrossButton {
    func closeCrossButton()
}

class ItemInfoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var ingredientImage: UIImageView!
    
    var delegate : CloseCrossButton?
    var crossClosure : (() -> ())?
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = 10.0
        // Initialization code
    }

    @IBAction func crossBtnPressed(_ sender: Any) {
        delegate?.closeCrossButton()
    }
}
