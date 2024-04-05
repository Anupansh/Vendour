//
//  NoSelectionFlowVC.swift
//  Vendour
//
//  Created by AppDev on 04/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Razorpay
import SimplOneClick

class NoSelectionFlowVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var rs50Btn: UIButton!
    @IBOutlet weak var rs25Btn: UIButton!
    @IBOutlet weak var rs15Btn: UIButton!
    @IBOutlet weak var amountTf: UITextField!
    @IBOutlet weak var partialPaymentLabel: UILabel!
    @IBOutlet weak var partialPaymentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var vendourWallet: UIImageView!
    @IBOutlet weak var walletBalanceLabel: UILabel!
    @IBOutlet weak var greenTick: UIImageView!
    @IBOutlet weak var partialPaymentView: UIView!
    @IBOutlet weak var simplBtn: UIButton!
    @IBOutlet weak var otherPaymentsBtn: UIButton!
    @IBOutlet weak var sodexoBtn: UIButton!
    @IBOutlet weak var paytmBtn: UIButton!
    @IBOutlet weak var walletBtn: UIButton!
    @IBOutlet weak var paymentMethodView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    var totalAmount : Double = 0
    var intWalletBalance : Int?
    var doubleWalletBalance : Double?
    var walletUsed : Bool = false
    var currency : String?
    var transactionId = ""
    var orderId = ""
    var systemTimeStamp = ""
    var systemDate = ""
    var razorpay : Razorpay!
    var razorpayTransactionId = ""
    var machineID = ""
    var paytmOrderId = ""
    var user = GSUser()
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var locationManager = CLLocationManager()
    var simplTransactionId = ""
    var simplTransactionToken = ""
    var paytmTranasactionId : String?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        razorpay = Razorpay.initWithKey("rzp_test_8aO2sKK7TOHACH", andDelegate: self)
        getBalanceApiCalled()
        CommonController.shared.hideHud()
        getTimeApiCalled()
        GSManager.initialize(withMerchantID: "8c07e5c7017f3bec5604dda4a40e2c17")
        GSManager.enableSandBoxEnvironment(true)
        user = GSUser(phoneNumber: UserDefaults.standard.string(forKey: kConstant.localKeys.mobNumber)!, email: UserDefaults.standard.string(forKey: kConstant.localKeys.emailId)!)
        checkEligibilityForSimpl()
    }
    
    @IBAction func addMoneyBtnPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            totalAmount += 15
        }
        else if sender.tag == 1 {
            totalAmount += 25
        }
        else {
            totalAmount += 50
        }
        amountTf.text = String(totalAmount)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func walletBtnPressed(_ sender: Any) {
        if totalAmount == 0 {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Amount cannot be 0")
        }
        else if intWalletBalance! == 0 {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "0 wallet balance")
        }
        else {
            if doubleWalletBalance! < totalAmount {
                let toBePaidByGateway = String(totalAmount - doubleWalletBalance!)
                partialPaymentView.isHidden = false
                partialPaymentLabel.isHidden = false
                partialPaymentViewHeightConstraint.constant = 20
                partialPaymentLabel.text = "Pay \(currency! + toBePaidByGateway) more using another payment method"
                walletBtn.layer.borderColor = UIColor.init(red: 43/255, green: 168/255, blue: 155/268, alpha: 1).cgColor
                CommonController.shared.amountByWallet = doubleWalletBalance
                CommonController.shared.amountByGateway = Double(toBePaidByGateway)
                walletUsed = true
                greenTick.isHidden = false
                walletBtn.isUserInteractionEnabled = false
            }
            else {
                walletUsed = true
                CommonController.shared.amountByWallet = totalAmount
                CommonController.shared.amountByGateway = 0
                self.walletChargeApiCalled(for: "")
            }
        }
    }
    
    @IBAction func paytmBtnPressed(_ sender: Any) {
        if totalAmount == 0 {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Amount cannot be 0")
        }
        else {
            if walletUsed == true {
                CommonController.shared.amountByWallet = doubleWalletBalance
                CommonController.shared.amountByGateway = totalAmount - doubleWalletBalance!
                self.walletChargeApiCalled(for: "paytm")
            }
            else {
                CommonController.shared.amountByGateway = totalAmount
            }
            getChecksumApiCalled()
        }
    }
    
    @IBAction func sodexoBtnPressed(_ sender: Any) {
        if totalAmount == 0 {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Amount cannot be 0")
        }
        else {
            if walletUsed == true {
                CommonController.shared.amountByWallet = doubleWalletBalance
                CommonController.shared.amountByGateway = totalAmount - doubleWalletBalance!
            }
            else {
                CommonController.shared.amountByGateway = totalAmount
            }
            let vc = SodexoPaymentVC()
            vc.walletUsed = self.walletUsed
            if walletUsed {
                self.walletChargeApiCalled(for: "sodexo")
                vc.amount = String(CommonController.shared.amountByGateway!)
            }
            else {
                vc.amount = String(totalAmount)
            }
            if CommonController.shared.selectionFlow == "0" {
                vc.noSelectionFlowAmount = amountTf.text
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func otherPaymentBtnPressed(_ sender: Any) {
        var amountToBePaid = 0.0
        if totalAmount == 0 {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Amount cannot be 0")
        }
        else {
            if walletUsed {
                self.walletChargeApiCalled(for: "razorpay")
                amountToBePaid = CommonController.shared.amountByGateway!
            }
            else {
                amountToBePaid = totalAmount
            }
            let options : [String : Any] = [
                "amount" : amountToBePaid * 100,
                "prefill" : [
                    "contact" : UserDefaults.standard.string(forKey: kConstant.localKeys.mobNumber),
                    "email" : UserDefaults.standard.string(forKey: kConstant.localKeys.emailId)
                ]
            ]
            razorpay.open(options, displayController: self)
        }
    }
    
    @IBAction func simplBtnPressed(_ sender: Any) {
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted{
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Please enable location in Settings -> Vendour -> Location to use simpl")
        }
        else {
            if totalAmount == 0 {
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Amount cannot be 0")
            }
            else {
                if walletUsed == false {
                    CommonController.shared.amountByGateway = totalAmount
                }
                else {
                    self.walletChargeApiCalled(for: "simpl")
                }
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                self.handleSimplTransaction()
            }
        }
    }
    
    func handleSimplTransaction() {
        var amountToBePaid : Double?
        if walletUsed == true {
            amountToBePaid = CommonController.shared.amountByGateway
        }
        else {
            amountToBePaid = totalAmount
        }
        let transaction = GSTransaction(user: user, amountInPaise: Int(amountToBePaid! * 100))
        GSManager.shared().authorizeTransaction(transaction) { (response, error) in
            if error != nil {
                if self.walletUsed == true {
                    self.walletRefundApi()
                }
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Unable to procced using Simpl. Please try any other method")
            }
            else {
                self.simplTransactionToken = response!["transaction_token"] as! String
                self.simplTransactionCaptureApi()
            }
        }
    }
    
    func simplTransactionCaptureApi() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/simpl/transaction/capture/")
        let params : [String : Any] = [
            "transaction_token" : simplTransactionToken,
            "amount_in_paise" : CommonController.shared.amountByGateway! * 100,
//            "Items" : simplProductArray,
            "shipping_address" : [
                "longitude" : self.longitude,
                "latitude" : self.latitude
            ],
            "billing_address" : [
                "longitude" : self.longitude,
                "latitude" : self.latitude
            ],
            "machine_id" : Int(CommonController.shared.machineId)!
        ]
        print("Simpl transaction Capture API",serviceName)
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"]
                    self.simplTransactionId = jsonResponse["transaction_id"].stringValue
                    if self.walletUsed == true {
                        self.transactionCaptureApi(otherMethodUsed: "wallet+simpl")
                    }
                    else {
                        self.transactionCaptureApi(otherMethodUsed: "simpl")
                    }
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation : CLLocationCoordinate2D = manager.location!.coordinate
        latitude = lastLocation.latitude
        longitude = lastLocation.longitude
        locationManager.stopUpdatingLocation()
    }
    
    func checkEligibilityForSimpl() {
        var params : [String : Any] = [:]
        params["transaction_amount_in_paise"] = String(totalAmount * 100)
        user.headerParams = params
        GSManager.shared().checkApproval(for: user) {
            (approved, firstTransaction, text, error) in
            self.simplBtn.isHidden = !approved
        }
    }
    
    func getChecksumApiCalled() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/gateways/paytm/checksum/")
        var amountToBePaid = ""
        if walletUsed == true {
            amountToBePaid = String(CommonController.shared.amountByGateway!)
        }
        else {
            amountToBePaid = String(totalAmount)
        }
        let params : [String : String] = [
            "CUST_ID" : UserDefaults.standard.string(forKey: kConstant.localKeys.customerId)!,
            "TXN_AMOUNT" : amountToBePaid,
            "EMAIL" : UserDefaults.standard.string(forKey: kConstant.localKeys.emailId)!,
            "MOBILE_NO" : UserDefaults.standard.string(forKey: kConstant.localKeys.mobNumber)!,
            "machine_id" : CommonController.shared.machineId
        ]
        print("Paytm checksum", serviceName)
        print("Parameters",params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"]
                    let orderID = jsonResponse["ORDER_ID"].stringValue
                    let merchantID = jsonResponse["paytm"]["paytm_mid"].stringValue
                    let channelID = jsonResponse["paytm"]["channel_id"].stringValue
                    let website = jsonResponse["paytm"]["paytm_website"].stringValue
                    let industryType = jsonResponse["paytm"]["industry_type_id"].stringValue
                    let callbackURL = jsonResponse["paytm"]["callback_url"].stringValue
                    let checksum = jsonResponse["CHECKSUMHASH"].stringValue
                    let theme = jsonResponse["paytm"]["theme"].stringValue
                    self.paytmOrderId = orderID
                    self.handlePaytmTransaction(merchantID: merchantID, orderID: orderID, channelID: channelID, website: website, industryType: industryType, checksum: checksum, callbackUrl: callbackURL, theme : theme, amount : amountToBePaid)
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
    
    func getBalanceApiCalled() {
        print("Get Wallet balance API",getFullServiceUrl(serviceName: "/api/vendour/v1/wallet/"))
        Alamofire.request(getFullServiceUrl(serviceName: "/api/vendour/v1/wallet/"), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = JSON(json["response"])
                    let currency = jsonResponse["currency"].stringValue
                    self.currency = currency
                    let walletBalance = jsonResponse["personal_wallet"].stringValue
                    self.intWalletBalance = Int(walletBalance)
                    self.walletBalanceLabel.text = currency + walletBalance
                    if self.intWalletBalance == 0 {
                        self.walletBalanceLabel.textColor = UIColor(red: 184/255, green: 184/255, blue: 184/255, alpha: 1)
                        self.vendourWallet.image = UIImage(named: "grayWallet")
                    }
                    else {
                        self.walletBalanceLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                        self.vendourWallet.image = UIImage(named: "walletVendour")
                    }
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
        }
    }
    
    func walletChargeApiCalled(for otherPaymentMode : String) {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/charge/wallet/")
        var params : [String : Any] = [:]
        if otherPaymentMode == "" {
            params = [
                "machine_id" : CommonController.shared.machineId,
                "payment_mode" : "wallet",
                "amount" : [
                    "paid_by_personal_wallet" : Float(totalAmount)
                ]
            ]
        }
        else {
            params = [
                "machine_id" : CommonController.shared.machineId,
                "payment_mode" : "wallet",
                "amount" : [
                    "paid_by_personal_wallet" : Float(CommonController.shared.amountByWallet!),
                    "paid_by_gateway" : Float(CommonController.shared.amountByGateway!),
                    "gateway_payment_mode" : otherPaymentMode
                ]
            ]
        }
        print("Wallet Charge API",serviceName)
        print("Parameters",params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"]
                    if otherPaymentMode == "" {
                        CommonController.shared.walletTransactionId = jsonResponse["wallet_transaction_id"].stringValue
                        self.transactionCaptureApi(otherMethodUsed: "wallet")
                    }
                    else {
                        CommonController.shared.walletTransactionId = jsonResponse["wallet_transaction_id"].stringValue
                    }
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
    
    func transactionCaptureApi(otherMethodUsed : String) {
        CommonController.shared.showHud(title: "", sender: self.view)
        var params : [String : Any] = [:]
        var kOtherMethodUsed = ""
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/transaction/capture/")
        if otherMethodUsed == "razorpay" {
            self.transactionId = razorpayTransactionId
            self.orderId = ""
            kOtherMethodUsed = "razorpay"
        }
        if otherMethodUsed == "wallet" {
            self.transactionId = CommonController.shared.walletTransactionId!
            self.orderId = ""
            kOtherMethodUsed = "wallet"
        }
        if otherMethodUsed == "simpl" {
            self.transactionId = simplTransactionId
            self.orderId = ""
            kOtherMethodUsed = "simpl"
        }
        if otherMethodUsed == "wallet+razorpay" {
            self.transactionId = razorpayTransactionId
            self.orderId = ""
            kOtherMethodUsed = "wallet+razorpay"
        }
        if otherMethodUsed == "wallet+simpl" {
            self.transactionId = simplTransactionId
            self.orderId = ""
            kOtherMethodUsed = "wallet+simpl"
        }
        if otherMethodUsed == "wallet+paytm" {
            self.transactionId = self.paytmTranasactionId!
            self.orderId = paytmOrderId
            kOtherMethodUsed = "wallet+paytm"
        }
        if otherMethodUsed == "paytm" {
            self.transactionId = self.paytmTranasactionId!
            self.orderId = paytmOrderId
            kOtherMethodUsed = "paytm"
        }
        if walletUsed == true {
            if CommonController.shared.machineHardwareType == "Normal" && CommonController.shared.selectionFlow == "0" {
                // Don't call paramters products and crypto and timestamp
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : kOtherMethodUsed,
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
            else {
                //  Call crypto and timestanmp but not products
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "timestamp" : self.systemTimeStamp,
                    "crypto" : CommonController.shared.crypto!,
                    //                    "crypto" : self.systemDate,
                    "payment_mode" : kOtherMethodUsed,
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
        }
        else {
            if CommonController.shared.machineHardwareType == "Normal" && CommonController.shared.selectionFlow == "0" {
                // Don't call paramters products and crypto and timestamp
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : kOtherMethodUsed,
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : 0,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ]
                ]
            }
            else {
                //  Call crypto and timestanmp but not products
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "timestamp" : self.systemTimeStamp,
                    "crypto" : CommonController.shared.crypto!,
                    //                    "crypto" : self.systemDate,
                    "payment_mode" : kOtherMethodUsed,
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : 0,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ]
                ]
            }
        }
        print("Trasaction Capture API", serviceName)
        print("Params",params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    CommonController.shared.crypto = json["new_crypto"].stringValue
                    CommonController.shared.transactionId = json["response"].stringValue
                    //                    let alert = UIAlertController(title: "Vendour", message: "Payment Successful", preferredStyle: .alert)
                    //                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    CommonController.shared.noSelectionFlowAmount = self.amountTf.text
                    let vc = VendingScreenVC()
                    self.navigationController?.pushViewController(vc, animated: true)
                    CommonController.shared.hideHud()
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
                    CommonController.shared.hideHud()
                }
                else {
                    CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: message)
                    CommonController.shared.hideHud()
                }
            }
            else {
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "No Internet Connection")
            }
            CommonController.shared.hideHud()
        }
    }
    
    func getTimeApiCalled() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/v1/events/get/time/")
        print("Get time API",serviceName)
        Alamofire.request(serviceName, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print("Response",json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"]
                    self.systemDate = jsonResponse["system_date"].stringValue
                    self.systemTimeStamp = jsonResponse["system_timestamp"].stringValue
                    CommonController.shared.systemDate = self.systemDate
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
    
    func walletRefundApi() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/wallet/refund/")
        let params : [String : Any] = [
            "paid_by_personal_wallet" : Float(CommonController.shared.amountByWallet!),
            "wallet_transaction_id" : CommonController.shared.walletTransactionId!
        ]
        print("Wallet Refund API",serviceName)
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Wallet balance refunded")
                    self.getBalanceApiCalled()
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
    
    // PAYTM 
    
    func handlePaytmTransaction(merchantID : String, orderID : String, channelID : String, website : String, industryType : String, checksum : String, callbackUrl : String, theme : String, amount : String) {
        let mc = PGMerchantConfiguration.default()
        var orderDict = [AnyHashable : Any]()
        PGServerEnvironment.createProduction()
        let pgServer = PGServerEnvironment.init()
        orderDict["MID"] = merchantID
        orderDict["ORDER_ID"] = orderID
        orderDict["CUST_ID"] = UserDefaults.standard.string(forKey: kConstant.localKeys.customerId)!
        orderDict["MOBILE_NO"] = UserDefaults.standard.string(forKey: kConstant.localKeys.mobNumber)!
        orderDict["EMAIL"] = UserDefaults.standard.string(forKey: kConstant.localKeys.emailId)!
        orderDict["CHANNEL_ID"] = channelID
        orderDict["WEBSITE"] = website
        orderDict["TXN_AMOUNT"] = amount
        orderDict["INDUSTRY_TYPE_ID"] = industryType
        orderDict["CHECKSUMHASH"] = checksum
        orderDict["CALLBACK_URL"] = callbackUrl
        orderDict["THEME"] = theme
        print("Paytm calling parameters", orderDict)
        let order = PGOrder(params: orderDict)
        pgServer.callBackURLFormat = callbackUrl
        let txnController = PGTransactionViewController.init(transactionFor: order)
        txnController?.serverType = eServerTypeProduction
        txnController?.merchant = mc
        txnController?.loggingEnabled = true
        txnController?.delegate = self
        self.show(txnController!, sender: self)
        //        let vc = PaytmVC()
        //        vc.show(txnController!, sender: nil)
        //        self.navigationController?.pushViewController(vc, animated: true)
        //        //Step 1: Create a default merchant config object
        //        let mc: PGMerchantConfiguration = PGMerchantConfiguration.default()
        //
        //        //Step 2: If you have your own checksum generation and validation url set this here. Otherwise use the default Paytm urls
        //
        //        mc.checksumGenerationURL = "https://pguat.paytm.com/paytmchecksum/paytmCheckSumGenerator.jsp"
        //        mc.checksumValidationURL = "https://pguat.paytm.com/paytmchecksum/paytmCheckSumVerify.jsp"
        //
        //        //Step 3: Create the order with whatever params you want to add. But make sure that you include the merchant mandatory params
        //        var orderDict: [NSObject : AnyObject] = NSMutableDictionary() as [NSObject : AnyObject]
        //        let order = PGOrder(forOrderID: "", customerID: "", amount: "", customerMail: "", customerMobile: "")
        //        order!.params = ["MID": "rxazcv89315285244163",
        //                        "ORDER_ID": "order1",
        //                        "CUST_ID": "cust123",
        //                        "MOBILE_NO": "7777777777",
        //                        "EMAIL": "username@emailprovider.com",
        //                        "CHANNEL_ID": "WAP",
        //                        "WEBSITE": "WEBSTAGING",
        //                        "TXN_AMOUNT": "100.12",
        //                        "INDUSTRY_TYPE_ID": "Retail",
        //                        "CHECKSUMHASH": "oCDBVF+hvVb68JvzbKI40TOtcxlNjMdixi9FnRSh80Ub7XfjvgNr9NrfrOCPLmt65UhStCkrDnlYkclz1qE0uBMOrmuKLGlybuErulbLYSQ=",
        //                        "CALLBACK_URL": "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=order1"]
        //
        //        //Step 4: Choose the PG server. In your production build dont call selectServerDialog. Just create a instance of the
        //        //PGTransactionViewController and set the serverType to eServerTypeProduction
        //        PGServerEnvironment.selectServerDialog(self.view, completionHandler: {(type: ServerType) -> Void in
        //
        //            let txnController = PGTransactionViewController.init(transactionFor: order)
        //
        //
        //            if type != eServerTypeNone {
        //                txnController!.serverType = type
        //                txnController!.merchant = mc
        //                txnController!.delegate = self
        //                self.show(txnController!, sender: nil)
        //            }
        //        })
        //
    }
    
    func paymCheckStatusApi() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/gateways/paytm/check/status/")
        let params : [String : Any] = [
            //            String “ORDER_ID” Integer “machine_id”
            "ORDER_ID" : paytmOrderId,
            "machine_id" : Int(CommonController.shared.machineId)!
        ]
        print("PAytm get status API",serviceName)
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess == true {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    if self.walletUsed == true {
                        self.transactionCaptureApi(otherMethodUsed: "wallet+paytm")
                    }
                    else {
                        self.transactionCaptureApi(otherMethodUsed: "paytm")
                    }
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

    
    func setupUI() {
        walletBtn.layer.borderWidth = 1.0
        walletBtn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        walletBtn.layer.cornerRadius = 5.0
        paytmBtn.layer.borderWidth = 1.0
        paytmBtn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        paytmBtn.layer.cornerRadius = 5.0
        sodexoBtn.layer.borderWidth = 1.0
        sodexoBtn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        sodexoBtn.layer.cornerRadius = 5.0
        otherPaymentsBtn.layer.borderWidth = 1.0
        otherPaymentsBtn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        otherPaymentsBtn.layer.cornerRadius = 5.0
        simplBtn.layer.borderWidth = 1.0
        simplBtn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        simplBtn.layer.cornerRadius = 5.0
        rs15Btn.layer.borderWidth = 1.0
        rs15Btn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        rs15Btn.layer.cornerRadius = 5.0
        rs25Btn.layer.borderWidth = 1.0
        rs25Btn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        rs25Btn.layer.cornerRadius = 5.0
        rs50Btn.layer.borderWidth = 1.0
        rs50Btn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        rs50Btn.layer.cornerRadius = 5.0
        bottomView.layer.cornerRadius = 10.0
        bottomView.layer.masksToBounds = true
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        partialPaymentView.layer.borderWidth = 1.0
        partialPaymentView.layer.borderColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0/255).cgColor
        greenTick.isHidden = true
        partialPaymentView.isHidden = true
        partialPaymentLabel.isHidden = true
        partialPaymentViewHeightConstraint.constant = 0
        var myMutableStringTitle = NSMutableAttributedString()
        myMutableStringTitle = NSMutableAttributedString(string:"Amount", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 22.0)!])
        amountTf.attributedPlaceholder = myMutableStringTitle
    }
}

extension NoSelectionFlowVC : RazorpayPaymentCompletionProtocol, PGTransactionDelegate {
    
    // PAYTM Delegates
    
    func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!) {
        paytmTranasactionId = responseString
        self.paymCheckStatusApi()
    }
    
    func didCancelTrasaction(_ controller: PGTransactionViewController!) {
        if self.walletUsed == true {
            self.walletRefundApi()
        }
        CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Payment Successful")
        print("Paytm Cancel Transaction")
    }
    
    func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {
        print("Paytm Missing parameters")
    }
    
    // RAZORPAY Deleagtes
    
    func onPaymentError(_ code: Int32, description str: String) {
        self.navigationController?.isNavigationBarHidden = true
        if walletUsed {
            self.walletRefundApi()
        }
        CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Payment failed")
        print("razorpay failed")
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        self.navigationController?.isNavigationBarHidden = true
        self.razorpayTransactionId = payment_id
        if walletUsed {
            self.transactionCaptureApi(otherMethodUsed: "wallet+razorpay")
        }
        else {
            CommonController.shared.amountByGateway = totalAmount
            self.transactionCaptureApi(otherMethodUsed: "razorpay")
        }
        print("Razorpay Success")
    }
}
