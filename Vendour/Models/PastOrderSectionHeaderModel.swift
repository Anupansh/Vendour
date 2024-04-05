//
//  PastOrderSectionHeaderModel.swift
//  Vendour
//
//  Created by AppDev on 17/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation
import SwiftyJSON

enum TypeOfSection {
    case successfull
    case eligibleForRefund
    case refunded
}

class PastOrderSectionHeaderModel {
    var transactionID : String?
    var paymentMode : String?
    var machineID : String?
    var refundID : String?
    var refundStatus : String?
    var amount : String?
    var currency : String?
    var createdAt : String?
    var lastUpdatedAt : String?
    var isSuccessful : String?
    var itemDetails = [PastItemOrderModel]()
    var typeOfSection : TypeOfSection?
    var orderUUID : String?
    
    init() {}

    init(with json : JSON) {
        transactionID = json["transaction_uid"].stringValue
        paymentMode = json["payment_mode"].stringValue
        machineID = json["machine_name"].stringValue
        refundID = json["refund_uid"].stringValue
        refundStatus = json["refund_status"].stringValue
        amount = json["amount"].stringValue
        currency = json["currency"].stringValue
        createdAt = json["created_at"].stringValue
        lastUpdatedAt = json["last_updated_at"].stringValue
        isSuccessful = json["is_successful"].stringValue
        orderUUID = json["_uuid"].stringValue
        if isSuccessful == "true" && refundID == "" {
            typeOfSection = .successfull
        }
        else if isSuccessful == "false" && refundID == "" && (paymentMode == "Wallet" || paymentMode == "Sodexo"){
            typeOfSection = .successfull
        }
        else if isSuccessful == "false" && refundID == "" {
            typeOfSection = .eligibleForRefund
        }
        else {
            typeOfSection = .refunded
        }
        for i in 0..<json["products"].count {
            let singleItem = PastItemOrderModel.init(with: json["products"][i])
            itemDetails.append(singleItem)
        }
    }
}
