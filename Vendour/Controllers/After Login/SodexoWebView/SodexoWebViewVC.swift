//
//  SodexoWebViewVC.swift
//  Vendour
//
//  Created by AppDev on 14/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

class SodexoWebViewVC: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var myView: UIView!
    
    var redirectUserTo : String?
    var transactionId : String?
    var orderId : String?
    var myWebView : WKWebView!
    var systemTimeStamp = ""
    var systemDate = ""
    var productArray = [[String : Any]]()
    var walletUsed : Bool?
    var noselectionFlowAmount : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWKWebView()
//        CommonController.shared.machineHardwareType = "Normal"
        if CommonController.shared.machineHardwareType == "Security" || CommonController.shared.machineHardwareType == "Crypto" {
            self.getTimeApiCalled()
        }
         if CommonController.shared.selectionFlow != "0" {
            self.getProductArray()
        }
    }
    
    func setupWKWebView() {
        myWebView = WKWebView(frame: myView.bounds, configuration: WKWebViewConfiguration())
        myWebView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        myView.addSubview(myWebView)
        myWebView.load(URLRequest(url: URL(string: redirectUserTo!)!))
        myWebView.navigationDelegate = self
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if ((navigationAction.request.url?.absoluteString.range(of: "vendata")) != nil) {
            webView.isUserInteractionEnabled = false
            checkTransactionApi()
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
    }
    
    func checkTransactionApi() {
        let serviceName = "https://app.vendata.in/api/vendour/v1/sodexo/transaction/\(transactionId!)/"
        print("Sodexo Check Transaction",serviceName)
        CommonController.shared.showHud(title: "", sender: self.view)
        Alamofire.request(serviceName, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                if response.response?.statusCode == 200 {
                    self.transactionCaptureApi()
                }
                else if response.response?.statusCode == 403 {
                    let alert = UIAlertController(title: "Vendour", message: "Something wrong happened. Please login again to continue.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (alert) in
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.authToken)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.userName)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.mobNumber)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.imageURL)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.emailId)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.userId)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.dob)
                        let vc = Login()
                        self.navigationController?.viewControllers = [vc]
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "Vendour", message: "Could not progress. Please use some other method", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                        CommonController.shared.individualItemArray.removeAll()
                        if CommonController.shared.selectionFlow == "0" {
                            for controller in self.navigationController!.viewControllers {
                                if controller.isKind(of: NoSelectionFlowVC.self) {
                                    self.navigationController?.popToViewController(controller, animated: true)
                                    Thread.sleep(forTimeInterval: 1)
                                }
                            }
                        }
                        else {
                            for controller in self.navigationController!.viewControllers {
                                if controller.isKind(of: MachineDetailsVC.self) {
                                    self.navigationController?.popToViewController(controller, animated: true)
                                    Thread.sleep(forTimeInterval: 1)
                                }
                            }
                        }
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "No Internet Conenction")
            }
            CommonController.shared.hideHud()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Did finish")
    }

    func getTimeApiCalled() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/v1/events/get/time/")
        Alamofire.request(serviceName, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"]
                    self.systemDate = jsonResponse["system_date"].stringValue
                    self.systemTimeStamp = jsonResponse["system_timestamp"].stringValue
                }
                else if response.response?.statusCode == 403 {
                    let alert = UIAlertController(title: "Vendour", message: "Something wrong happened. Please login again to continue.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (alert) in
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.authToken)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.userName)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.mobNumber)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.imageURL)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.emailId)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.userId)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.dob)
                        let vc = Login()
                        self.navigationController?.viewControllers = [vc]
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: message)
                }
            }
            else {
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "No Internet Connection")
            }
            CommonController.shared.hideHud()
        }
    }
    
    func transactionCaptureApi() {
        var params : [String : Any] = [:]
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/transaction/capture/")
        if walletUsed == true {
            if CommonController.shared.machineHardwareType == "Normal" && CommonController.shared.selectionFlow == "0" {
                // Don't call paramters products and crypto and timestamp
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : "wallet+sodexo",
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : CommonController.shared.amountByWallet!,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ],
                    "wallet_data" : [
                        "paid_by_personal_wallet" : Float(CommonController.shared.amountByWallet!),
                        "paid_by_org_wallet" : 0,
                        "paid_by_personal_cashback" : 0
                    ],
                    "wallet_transaction_id" : CommonController.shared.walletTransactionId!
                ]
            }
            else if CommonController.shared.machineHardwareType != "Normal" && CommonController.shared.selectionFlow == "0" {
                //  Call crypto and timestanmp but not products
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "timestamp" : self.systemTimeStamp,
                    "crypto" : CommonController.shared.crypto!,
                    "payment_mode" : "wallet+sodexo",
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : CommonController.shared.amountByWallet!,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ],
                    "wallet_data" : [
                        "paid_by_personal_wallet" : Float(CommonController.shared.amountByWallet!),
                        "paid_by_org_wallet" : 0,
                        "paid_by_personal_cashback" : 0
                    ],
                    "wallet_transaction_id" : CommonController.shared.walletTransactionId!
                ]
            }
            else if CommonController.shared.machineHardwareType == "Normal" && CommonController.shared.selectionFlow != "0" {
                // Call Products but not crypto timestamp
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : "wallet+sodexo",
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : CommonController.shared.amountByWallet!,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ],
                    "products" : productArray,
                    "wallet_data" : [
                        "paid_by_personal_wallet" : Float(CommonController.shared.amountByWallet!),
                        "paid_by_org_wallet" : 0,
                        "paid_by_personal_cashback" : 0
                    ],
                    "wallet_transaction_id" : CommonController.shared.walletTransactionId!
                ]
            }
            else {
                // Call both Products and Crypto
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : "wallet+sodexo",
                    "timestamp" : self.systemTimeStamp,
                    //                "crypto" : self.systemDate,
                    "crypto" : CommonController.shared.crypto!,
                    "machine" : Int(CommonController.shared.machineId) ?? 0,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : CommonController.shared.amountByWallet!,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ],
                    "products" : productArray,
                    "wallet_data" : [
                        "paid_by_personal_wallet" : Float(CommonController.shared.amountByWallet!),
                        "paid_by_org_wallet" : 0,
                        "paid_by_personal_cashback" : 0
                    ],
                    "wallet_transaction_id" : CommonController.shared.walletTransactionId!
                ]
            }
        }
        else {
            if CommonController.shared.machineHardwareType == "Normal" && CommonController.shared.selectionFlow == "0" {
                // Don't call paramters products and crypto and timestamp
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : "sodexo",
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId!,
                        "order_id" : self.orderId!
                    ],
                    "amount" : [
                        "paid_by_wallet" : 0,
                        "paid_by_gateway" : CommonController.shared.amountByGateway
                    ]
                ]
            }
            else if CommonController.shared.machineHardwareType != "Normal" && CommonController.shared.selectionFlow == "0" {
                //  Call crypto and timestanmp but not products
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "timestamp" : self.systemTimeStamp,
                    "crypto" : CommonController.shared.crypto!,
                    "payment_mode" : "sodexo",
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId!,
                        "order_id" : self.orderId!
                    ],
                    "amount" : [
                        "paid_by_wallet" : 0,
                        "paid_by_gateway" : CommonController.shared.amountByGateway
                    ]
                ]
            }
            else if CommonController.shared.machineHardwareType == "Normal" && CommonController.shared.selectionFlow != "0" {
                // Call Products but not crypto timestamp
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : "sodexo",
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId!,
                        "order_id" : self.orderId!
                    ],
                    "amount" : [
                        "paid_by_wallet" : 0,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ],
                    "products" : productArray
                ]
            }
            else {
                // Call both Products and Crypto
                let paidByGateway = Float(CommonController.shared.amountByGateway!)
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : "sodexo",
                    "timestamp" : self.systemTimeStamp,
    //                "crypto" : self.systemDate,
                    "crypto" : CommonController.shared.crypto!,
                    "machine" : Int(CommonController.shared.machineId) ?? 0,
                    "transaction" : [
                        "transaction_id" : self.transactionId!,
                        "order_id" : self.orderId!
                    
                    ],
                    "amount" : [
                        "paid_by_wallet" : Float(0.0),
                        "paid_by_gateway" : paidByGateway
                    ],
                    "products" : productArray
                ]
            }
        }
        print("Transaction Capture API",serviceName)
        print("Parameters",params)
        CommonController.shared.showHud(title: "", sender: self.view)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
//                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    CommonController.shared.crypto = json["new_crypto"].stringValue
                    CommonController.shared.transactionId = json["response"].stringValue
//                    let alert = UIAlertController(title: "Vendour", message: "Payment Successful", preferredStyle: .alert)
                    
//                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                        let vc = VendingScreenVC()
                        if let kAmount = self.noselectionFlowAmount {
                            CommonController.shared.noSelectionFlowAmount = kAmount
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
//                    })
//                    alert.addAction(okAction)
//                    self.present(alert, animated: true, completion: nil)
                }
                else if response.response?.statusCode == 403 {
                    let alert = UIAlertController(title: "Vendour", message: "Something wrong happened. Please login again to continue.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (alert) in
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.authToken)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.userName)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.mobNumber)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.imageURL)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.emailId)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.userId)
                        UserDefaults.standard.removeObject(forKey: kConstant.localKeys.dob)
                        let vc = Login()
                        self.navigationController?.viewControllers = [vc]
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                    
                else {
                    CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Could not progress. Please use some other method")
                    CommonController.shared.individualItemArray.removeAll()
                    for controller in self.navigationController!.viewControllers {
                        if controller.isKind(of: MachineDetailsVC.self) {
                            self.navigationController?.popToViewController(controller, animated: true)
                        }
                    }
                }
            }
            else {
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "No Internet Connection")
            }
            CommonController.shared.hideHud()
        }
    }
    
    func getProductArray() {
        for i in 0..<CommonController.shared.individualItemArray.count {
            var singleProduct : [String : Any] = [:]
            singleProduct["product"] = Int(CommonController.shared.individualItemArray[i].productID!)
            singleProduct["price"] = Float(CommonController.shared.individualItemArray[i].cost!)
            singleProduct["status"] = Int("0")
            singleProduct["cell_number"] = CommonController.shared.individualItemArray[i].cellNumber
            self.productArray.append(singleProduct)
        }
    }
}

