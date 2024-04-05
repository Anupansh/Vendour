//
//  PastOrderItemsModel.swift
//  Vendour
//
//  Created by AppDev on 17/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation
import SwiftyJSON

class PastItemOrderModel {
    var image : String?
    var productName : String?
    var quantity : String?
    var amount : String?
    var status : String?
    var currency : String?
    
    init() {}
    
    init(with json : JSON) {
        image = json["product_detail"]["image"].stringValue
        productName = json["product_detail"]["product_name"].stringValue
        quantity = json["qty"].stringValue
        amount = json["product_detail"]["price"].stringValue
        status = json["status"].stringValue
        currency = json["currency"].stringValue
    }
}
