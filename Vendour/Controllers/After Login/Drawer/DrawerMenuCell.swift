//
//  DrawerMenuCell.swift
//  Vendour
//
//  Created by AppDev on 18/12/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit

class DrawerMenuCell: UITableViewCell {
    
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet var imageViewIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
