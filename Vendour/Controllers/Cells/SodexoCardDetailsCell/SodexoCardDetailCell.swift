//
//  SodexoCardDetailCell.swift
//  Vendour
//
//  Created by AppDev on 14/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class SodexoCardDetailCell: UITableViewCell {
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var maskedPanLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
