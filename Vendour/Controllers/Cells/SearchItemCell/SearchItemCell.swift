//
//  SearchItemCell.swift
//  Vendour
//
//  Created by AppDev on 20/02/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class SearchItemCell: UITableViewCell {
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
