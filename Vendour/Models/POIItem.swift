//
//  POIItem.swift
//  Vendour
//
//  Created by Clixlogix on 01/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import Foundation

class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}
