//
//  MachineDetails.swift
//  Vendour
//
//  Created by AppDev on 02/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation
import SwiftyJSON

class MachineDetails{
    var imageURL : String?
    var name : String?
    var cost : String?
    var quantity : String?
    var unit : String?
    var maxQuantity : String?
    var typeofCell : TypeOfCell = .normalCell
    var ingredientImage : String?
    var currentQuantity : Int = 0
    var machineDetailsIndex : Int?
    var productID : String?
    var cellNumber : String?
    var status : String?
    var isVended : String = ""
    var vendedImage : String?
    var shouldShowInfoBtn : Bool = true
    
    init() {
    }
    init(with json : JSON) {
        imageURL = json["product_detail"]["image"].stringValue
        name = json["product_detail"]["product_name"].stringValue
        cost = json["product_detail"]["price"].stringValue
        quantity = json["qty"].stringValue
        unit = json["product_detail"]["unit"].stringValue
        maxQuantity = json["max_qty"].stringValue
        ingredientImage = json["product_detail"]["nutritional_info"].stringValue
        productID = json["product_detail"]["id"].stringValue
        cellNumber = json["cell_number"].stringValue
    }
}
