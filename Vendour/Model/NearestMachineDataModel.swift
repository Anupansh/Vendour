//
//  NearestMachineDataModel.swift
//  Vendour
//
//  Created by Clixlogix on 31/12/18.
//  Copyright © 2018 Test. All rights reserved.
//

import Foundation

class NearestMachineDataModel: NSObject {
//    class var shared: NearestMachineDataModel
//    {
//        struct Static {
//            static let instance = NearestMachineDataModel()
//        }
//        return Static.instance
//    }
    var countryId:Int!
    var displacement:Double!
    var distance:String!
    var eta:String!
    var id: Int!
    var is_v2d2: Bool!
    var latitude: String!
    var location_type: String!
    var longitude: String!
    var machine_description: String!
    var machine_type: String!
    var machine_uid: String!
   // var offers
    var reverse_geocode: String!
}
