//
//  Constants.swift
//  Vendour
//
//  Created by AppDev on 05/12/18.
//  Copyright © 2018 Test. All rights reserved.
//

import Foundation
import UIKit

// Global Vars
let SW = UIScreen.main.bounds.width
let SH = UIScreen.main.bounds.height

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class kConstant {
    
    struct Constants {
        static let kBaseURL = "https://stage.app.vendata.in"
        static let kBaseGisURL = "https://stage.gis.vendata.in"
        static let deviceType = "ios"
        static let vendourAuthToken = "87b99d6f8bbb7fcd10704254ce9e2eb6"
        static let appAuthorization = "40cf9629d214ee6b2d3dae615aac6741f36b6dd7d04526afa20ce447c35407ad"
        static let gmsMapKey = "AIzaSyCqro8QvfeB_5qdB3cfUo_rKO7a2B4741g"
        static let appVersion = "1.0"
        
    }
    
    // All userdefaults keys
    struct localKeys {
        static let UId = "UId"
        static let userName = "userName"
        static let emailId = "emailId"
        static let mobNumber = "mobNumber"
        static let authToken = "authToken"
        static let FCMToken = "FCMToken"
        static let imageURL = "imageURL"
        static let userId = "userID"
        static let dob = "dob"
        static let customerId = "customerId"
    }
    
    // All notification keys
    struct notificationCentreKeys {
        static let homeCategorySelect = "homeCategory"
    }
}

public func getFullServiceUrl(serviceName : String) -> String{
    return kConstant.Constants.kBaseURL + serviceName
}

public func getFullServiceGisUrl(serviceName : String) -> String{
    return kConstant.Constants.kBaseGisURL + serviceName
}

extension Notification.Name {
    static let homeCategory = Notification.Name(kConstant.notificationCentreKeys.homeCategorySelect)
}

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 2) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

enum TypeOfCell {
    case normalCell
    case infoCell
}

