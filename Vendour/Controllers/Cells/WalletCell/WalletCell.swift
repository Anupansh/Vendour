//
//  WalletCell.swift
//  Vendour
//
//  Created by AppDev on 15/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class WalletCell: UITableViewCell {

    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var transactionId: UILabel!
    @IBOutlet weak var paymentMode: UILabel!
    @IBOutlet weak var refundId: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var refundHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var paymentModeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var transactionIdHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var orderIdHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var typeHeightConstratint: NSLayoutConstraint!
    @IBOutlet weak var typeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var orderIdTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var transactionIdTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var paymentModeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var refundIdTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
