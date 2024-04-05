//
//  CommonController.swift
//  Vendour
//
//  Created by AppDev on 05/12/18.
//  Copyright © 2018 Test. All rights reserved.

import UIKit
import SystemConfiguration
import Alamofire
import CoreBluetooth

class CommonController: NSObject{
    var hud : MBProgressHUD!
    class var shared: CommonController{
        struct Static {
            static let instance = CommonController()
        }
        return Static.instance
    }
    
    //  VARIABLES TO BE USED DURING PAYMENT GATEWAY INTEGRATION
    
    var machineHardwareType = ""
    var selectionFlow = ""
    var machineId = ""
    var amountByGateway : Double?
    var amountByWallet : Double?
    var individualItemArray = [MachineDetails]()
    var walletTransactionId : String?
    var peripheral : CBPeripheral?
    var systemDate : String?
    var crypto : String?
    var transactionId : String?
    var noSelectionFlowAmount : String?
    
    func showHud(title: String, sender: UIView){
        if (hud != nil)
        {
            self.hideHud()
        }
        hud = MBProgressHUD.showAdded(to: sender, animated: true)
        hud.label.text = title
    }
    func hideHud(){
        if (hud == nil)
        {
            return
        }
        hud.hide(animated: true)
        hud=nil
    }

    func isInternetAvailable() -> Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func isValidPhone(phone: String) -> Bool {
        
        let phoneRegex = "^[0-9]{6,14}$";
        let valid = NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phone)
        return valid
    }
    
    func isValidEmail(candidate: String) -> Bool {
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        var valid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
        if valid {
            valid = !candidate.contains("..")
        }
        return valid
    }
    
    
    func ShowAlert(_ sender: UIViewController,msg_title:String,message_heading:String){
        let alert = UIAlertController(title: msg_title, message: message_heading, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        sender.present(alert, animated: true, completion: nil)
    }
    
    
    
    func getHeaders() -> HTTPHeaders{
        
        let header : HTTPHeaders = ["VENDOUR-AUTH-TOKEN":"\(kConstant.Constants.vendourAuthToken)" , "APP-AUTHORIZATION" : "\(kConstant.Constants.appAuthorization)" , "LOGIN-REQUIRED" : "false"]
        
        return header
    }
    
    func getHeadersForAuthenticatedUser() -> HTTPHeaders{
        let authToken = UserDefaults.standard.value(forKey: kConstant.localKeys.authToken) as! String
        
        let header : HTTPHeaders = ["VENDOUR-AUTH-TOKEN":"\(kConstant.Constants.vendourAuthToken)" , "APP-AUTHORIZATION" : "\(kConstant.Constants.appAuthorization)" , "AUTH-TOKEN": authToken, "Content-Type" : "application/json"]
        return header
    }
    
    func myAlert(title:String,message:String,buttonTitle:String,view:UIViewController){
        
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction.init(title: buttonTitle, style: .default, handler: nil))
        
        view.present(alert, animated: true, completion: nil)
        
    }
    
    func validateEmail(enteredEmail:String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }

    
}




