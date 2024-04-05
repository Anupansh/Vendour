//
//  SodexoPaymentVC.swift
//  Vendour
//
//  Created by AppDev on 14/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


enum ApiCalledFor {
    case addNewCard
    case availableCard
}
class SodexoPaymentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var orderId : String?
    var transactionId : String?
    var redirectTo : String?
    var walletUsed : Bool?
    
    @IBOutlet weak var cardDetailsTableview: UITableView! {
        didSet {
            cardDetailsTableview.delegate = self
            cardDetailsTableview.dataSource = self
        }
    }
    
    var cardDetailsArray = [CardDetails]()
    var amount : String?
    var noSelectionFlowAmount : String?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardDetailsArray.count
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SodexoCardDetailCell") as! SodexoCardDetailCell
        cell.ownerNameLabel.text = cardDetailsArray[indexPath.row].ownerName
        cell.maskedPanLabel.text = cardDetailsArray[indexPath.row].maskedPan
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.createTransactionApiCalled(apiCalledFor: .availableCard, index: indexPath.row)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func initialSetup() {
        let nibName = UINib(nibName: "SodexoCardDetailCell", bundle: nil)
        cardDetailsTableview.register(nibName, forCellReuseIdentifier: "SodexoCardDetailCell")
        cardDetailsTableview.separatorStyle = .none
        apiCall()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNewCardBtnPressed(_ sender: Any) {
        createTransactionApiCalled(apiCalledFor: .addNewCard, index: 0)
    }
    
    func apiCall() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = "https://app.vendata.in/api/vendour/v1/sodexo/cards/"
        print("Sodexo saved cards API",serviceName)
        Alamofire.request(serviceName, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = JSON(json["response"])
                    for i in 0..<jsonResponse.count {
                        print("Response",response)
                        let singleCardDetail = CardDetails(with: jsonResponse[i])
                        self.cardDetailsArray.append(singleCardDetail)
                    }
                    self.cardDetailsTableview.reloadData()
                }
                else if response.response?.statusCode == 200 {
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
    
    func createTransactionApiCalled(apiCalledFor : ApiCalledFor,index : Int) {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = "https://app.vendata.in/api/vendour/v1/sodexo/transaction/"
        let params : [String : Any]
        if apiCalledFor == .addNewCard {
            params = [
                "amount" : amount! as Any
            ]
        }
        else {
            params = [
                "amount" : amount! as Any,
                "sourceId" : cardDetailsArray[index].sourceId as Any
            ]
        }
        print("sodexo create Transaction API",serviceName)
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = JSON(json["response"])
                    self.transactionId = jsonResponse["data"]["transactionId"].stringValue
                    self.orderId = jsonResponse["order_id"].stringValue
                    self.redirectTo = jsonResponse["data"]["redirectUserTo"].stringValue
                    let vc = SodexoWebViewVC()
                    vc.orderId = self.orderId
                    vc.walletUsed = self.walletUsed
                    vc.redirectUserTo = self.redirectTo
                    vc.transactionId = self.transactionId
                    vc.noselectionFlowAmount = self.noSelectionFlowAmount
                    self.navigationController?.pushViewController(vc, animated: true)
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


class CardDetails {
    var ownerName : String?
    var maskedPan : String?
    var sourceId : String?
    init() {}
    init(with json : JSON) {
        ownerName = json["cardSourceDetails"]["ownerName"].stringValue
        maskedPan = json["cardSourceDetails"]["maskedPan"].stringValue
        sourceId = json["sourceId"].stringValue
    }
}
