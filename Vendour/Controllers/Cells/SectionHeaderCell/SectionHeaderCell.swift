//
//  SectionHeaderCell.swift
//  Vendour
//
//  Created by AppDev on 17/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class SectionHeaderCell: UITableViewCell {
    @IBOutlet weak var transactionIDLabel: UILabel!
    @IBOutlet weak var costLAbel: UILabel!
    @IBOutlet weak var transactionDayLabel: UILabel!
    @IBOutlet weak var transactionTimeLabel: UILabel!
    @IBOutlet weak var refundDayLAbel: UILabel!
    @IBOutlet weak var refundDateLabel: UILabel!
    @IBOutlet weak var refundIdHeadingLabel: UILabel!
    @IBOutlet weak var refundStatusHeadingLAbel: UILabel!
    
    var refundClosure : (() -> ())?
    
    @IBOutlet weak var refundToGatewayBtn: UIButton! {
        didSet {
            refundToGatewayBtn.layer.borderWidth = 1
            refundToGatewayBtn.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
            refundToGatewayBtn.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var paymentModeLabel: UILabel! {
        didSet {
            paymentModeLabel.layer.borderWidth = 1
            paymentModeLabel.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
            paymentModeLabel.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var machineIdLabel: UILabel! {
        didSet {
            machineIdLabel.layer.borderWidth = 1
            machineIdLabel.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
            machineIdLabel.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var refundIdLabel: UILabel! {
        didSet {
            refundIdLabel.layer.borderWidth = 1
            refundIdLabel.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
            refundIdLabel.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var refundStatus: UILabel! {
        didSet {
            refundStatus.layer.borderWidth = 1
            refundStatus.layer.borderColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1).cgColor
            refundStatus.layer.cornerRadius = 5
        }
    }
    
    @IBAction func refundToGatewayBtnPressed(_ sender: UIButton) {
        refundClosure!()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        refundToGatewayBtn.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
