//
//  WalletDetailsModel.swift
//  Vendour
//
//  Created by AppDev on 15/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation
import SwiftyJSON

class WalletModel {
    
    var type : String?
    var imageType : String?
    var orderId : String?
    var transactionId : String?
    var paymentMode : String?
    var refundId : String?
    var time : String?
    var cost : String?
    var numberOfItems : Int = 0
    var currency : String?
    
    init() {}
    
    init(with json : JSON) {
        if json["type"].stringValue == "refund" {
            type = "Instant Refund"
        }
        else if json["type"].stringValue == "spent" {
            type = "Paid for order"
        }
        else {
            type = "Refund to Gateway"
        }
        orderId = json["_oid"].stringValue
        transactionId = json["transaction_uid"].stringValue
        paymentMode = json["mode"].stringValue
        refundId = json["refund_uid"].stringValue
        currency = json["currency"].stringValue
        if type == "Instant Refund" {
            cost = "+\(currency! + json["amount"].stringValue)"
        }
        else {
            cost = "-\(currency! + json["amount"].stringValue)"
        }
        time = json["created_at"].stringValue
    }
}
