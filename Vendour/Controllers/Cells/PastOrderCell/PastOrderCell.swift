//
//  PastOrderCell.swift
//  Vendour
//
//  Created by AppDev on 17/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class PastOrderCell: UITableViewCell {
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemQuantity: UILabel!
    @IBOutlet weak var itemCost: UILabel!
    @IBOutlet weak var itemStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
