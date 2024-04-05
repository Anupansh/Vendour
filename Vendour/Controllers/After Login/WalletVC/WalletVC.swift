//
//  WalletVC.swift
//  Vendour
//
//  Created by AppDev on 15/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WalletVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var walletBalanceLabel: UILabel!
    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.delegate = self
            tableview.dataSource = self
            tableview.separatorStyle = .none
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableview.reloadData()
    }
    var walletModelArray = [WalletModel]()
    var pageNumber = 0
    var toCallApiAgain : Bool = true
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "WalletCell", bundle: nil)
        tableview.register(nibName, forCellReuseIdentifier: "WalletCell")
        walletHistoryApiCall()
        getBalanceApiCalled()
        UIApplication.shared.statusBarStyle = .lightContent
        walletBalanceLabel.isHidden = true
        // Do any additional setup after loading the view.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletModelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "WalletCell", for: indexPath) as! WalletCell
        cell.orderIdTopConstraint.constant = 12
        cell.orderIdHeightConstraint.constant = 18
        cell.transactionIdTopConstraint.constant = 12
        cell.transactionIdHeightContraint.constant = 18
        cell.paymentModeTopConstraint.constant = 12
        cell.paymentModeHeightConstraint.constant = 18
        cell.refundIdTopConstraint.constant = 12
        cell.refundHeightConstraint.constant = 18
        if walletModelArray[indexPath.row].type == "" {
            cell.typeTopConstraint.constant = 0
            cell.typeHeightConstratint.constant = 0
        }
        else {
            cell.typeLabel.text = walletModelArray[indexPath.row].type
        }
        
        if walletModelArray[indexPath.row].orderId == "" {
            cell.orderIdTopConstraint.constant = 0
            cell.orderIdHeightConstraint.constant = 0
        }
        else {
            let myString : NSString = "Ref ID: \(walletModelArray[indexPath.row].orderId!)" as NSString
            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia-Bold", size: 13.0)!])
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location:8,length:myString.length - 8))
            cell.orderId.attributedText = myMutableString
        }
        
        if walletModelArray[indexPath.row].transactionId == "" {
            cell.transactionIdTopConstraint.constant = 0
            cell.transactionIdHeightContraint.constant = 0
        }
        else {
            let myString : NSString = "Transaction ID: \(walletModelArray[indexPath.row].transactionId!)" as NSString
            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia-Bold", size: 13.0)!])
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location:16,length:myString.length - 16))
            cell.transactionId.attributedText = myMutableString
        }
        
        if walletModelArray[indexPath.row].paymentMode == "" {
            cell.paymentModeTopConstraint.constant = 0
            cell.paymentModeHeightConstraint.constant = 0
        }
        else {
            let myString : NSString = "Payment Mode: \(walletModelArray[indexPath.row].paymentMode!)" as NSString
            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia-Bold", size: 13.0)!])
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location:14,length:myString.length - 14))
            cell.paymentMode.attributedText = myMutableString
        }
        
        if walletModelArray[indexPath.row].refundId == "" {
            cell.refundIdTopConstraint.constant = 0
            cell.refundHeightConstraint.constant = 0
        }
        else {
            let myString : NSString = "Refund ID: \(walletModelArray[indexPath.row].refundId!)" as NSString
            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia-Bold", size: 13.0)!])
            myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location:11,length:myString.length - 11))
            cell.refundId.attributedText = myMutableString
        }
        
        if walletModelArray[indexPath.row].type == "Instant Refund" {
            cell.costLabel.textColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
            cell.arrowImage.image = UIImage(named: "green_Plus")
        }
        else {
            cell.arrowImage.image = UIImage(named: "up_arrow")
            cell.costLabel.textColor = UIColor.black
        }
        cell.dateAndTimeLabel.text = self.getFormattedDate(date: walletModelArray[indexPath.row].time!)
        cell.costLabel.text = walletModelArray[indexPath.row].cost
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if walletModelArray[indexPath.row].numberOfItems == 1 {
            return 70
        }
        else if walletModelArray[indexPath.row].numberOfItems == 2 {
            return 100
        }
        else if walletModelArray[indexPath.row].numberOfItems == 3 {
            return 130
        }
        else if walletModelArray[indexPath.row].numberOfItems == 4 {
            return 160
        }
        else {
            return 190
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if toCallApiAgain {
            if indexPath.row == walletModelArray.count - 1 {
                pageNumber += 1
                self.walletHistoryApiCall()
            }
        }
    }
    
    
    func getFormattedDate(date : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let myDate = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timeStamp = dateFormatter.string(from: myDate!)
        return timeStamp
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getBalanceApiCalled() {
        CommonController.shared.showHud(title: "", sender: self.view)
        print("Get balacne API",getFullServiceUrl(serviceName: "/api/vendour/v1/wallet/"))
        Alamofire.request(getFullServiceUrl(serviceName: "/api/vendour/v1/wallet/"), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = JSON(json["response"])
                    let currency = jsonResponse["currency"].stringValue
                    let walletBalance = jsonResponse["personal_wallet"].stringValue
                    self.walletBalanceLabel.text = currency + walletBalance
                    self.walletBalanceLabel.isHidden = false
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
    
    
    func walletHistoryApiCall() {
        CommonController.shared.showHud(title: "", sender: self.view)
        print("Wallet history API",getFullServiceUrl(serviceName: "/api/vendour/v1/wallet/history/?page=\(pageNumber)"))
        Alamofire.request(getFullServiceUrl(serviceName: "/api/vendour/v1/wallet/history/?page=\(pageNumber)"), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                let jsonResponse = JSON(json["response"])
                for i in 0..<jsonResponse.count {
                    let singleWalletModel = WalletModel.init(with: jsonResponse[i])
                    if singleWalletModel.type != "" {
                        singleWalletModel.numberOfItems += 1
                    }
                    if singleWalletModel.orderId != "" {
                        singleWalletModel.numberOfItems += 1
                    }
                    if singleWalletModel.transactionId != "" {
                        singleWalletModel.numberOfItems += 1
                    }
                    if singleWalletModel.paymentMode != "" {
                        singleWalletModel.numberOfItems += 1
                    }
                    if singleWalletModel.refundId != "" {
                        singleWalletModel.numberOfItems += 1
                    }
                    self.walletModelArray.append(singleWalletModel)
                }
                self.tableview.reloadData()
                if jsonResponse.count < 10 {
                    self.toCallApiAgain = false
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
}

