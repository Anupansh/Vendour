
//
//  MachineDetailsCollectionCell.swift
//  Vendour
//
//  Created by AppDev on 02/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class MachineDetailsCollectionCell: UICollectionViewCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var machineDetailsView: UIView!
    @IBOutlet weak var numberOfItemsLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var infoBtn: UIButton!
    
    var minusClosure : (() -> ())?
    var plusClosure : (() -> ())?
    var infoClosure : (() -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
        machineDetailsView.layer.cornerRadius = 10
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(increaseBtnPressed(_:)))
        machineDetailsView.isUserInteractionEnabled = true
        machineDetailsView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func decreaseBtnPressed(_ sender: Any) {
        minusClosure!()
    }
    @IBAction func increaseBtnPressed(_ sender: Any) {
        plusClosure!()
    }
    @IBAction func infoBtnPressed(_ sender: Any) {
        infoClosure!()
    }
    
    
    
}
