//
//  MachineInfo.swift
//  Vendour
//
//  Created by AppDev on 09/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation
import SwiftyJSON

class MachineInfo {
    
    var machineID : String?
    var machineImage : String?
    var machineDescription : String?
    var machineType : String?
    var machineUid : String?
    var operatorName : String?
    var k_Type : String?
    var machineHardwareType = ""
    var cryptoCommandSent : Bool = false
    
    init() {
    }
    
    init(with json : JSON) {
        machineID = json["machine_id"].stringValue
        machineImage = json["machine_type_image"].stringValue
        machineDescription = json["machine_description"].stringValue
        machineType = json["machine_type"].stringValue
        machineUid = json["machine_uid"].stringValue
        operatorName = json["operator_name"].stringValue
        k_Type = json["kb_type"].stringValue
    }
}
