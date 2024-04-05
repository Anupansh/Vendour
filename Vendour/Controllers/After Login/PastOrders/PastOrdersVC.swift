//
//  PastOrdersVC.swift
//  Vendour
//
//  Created by AppDev on 17/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PastOrdersVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.backgroundColor = UIColor.clear
        }
    }
    
    @IBOutlet weak var stackView: UIStackView!
    
    var pastOrderArray = [PastOrderSectionHeaderModel]()
    var refundIndexpath : Int?
    var pageNumber : Int = 1
    var refund200Case : Bool = false
    var apiCalled : Bool = false
    var toCallApiAgain : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        let sectionNibName = UINib(nibName: "SectionHeaderCell", bundle: nil)
        tableView.register(sectionNibName, forCellReuseIdentifier: "SectionHeaderCell")
        let nibName = UINib(nibName: "PastOrderCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "PastOrderCell")
        pastOrderApiCall()
        stackView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastOrderArray[section].itemDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastOrderCell") as! PastOrderCell
        cell.itemImage.sd_setImage(with: URL(string: pastOrderArray[indexPath.section].itemDetails[indexPath.row].image!), completed: nil)
        cell.itemCost.text = pastOrderArray[indexPath.section].itemDetails[indexPath.row].currency! + pastOrderArray[indexPath.section].itemDetails[indexPath.row].amount!
        cell.itemName.text = pastOrderArray[indexPath.section].itemDetails[indexPath.row].productName
        cell.itemQuantity.text = "X " + pastOrderArray[indexPath.section].itemDetails[indexPath.row].quantity!
        cell.itemStatus.text = pastOrderArray[indexPath.section].itemDetails[indexPath.row].status
        if pastOrderArray[indexPath.section].itemDetails[indexPath.row].status == "false" {
            cell.itemStatus.backgroundColor = UIColor.red
            cell.itemStatus.text = "Failure"
        }
        else {
            cell.itemStatus.backgroundColor = UIColor.green
            cell.itemStatus.text = "Success"
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        if pastOrderArray.count == 0 {
//            if apiCalled {
//                stackView.isHidden = false
//                return 0
//            }
//            else {
//                stackView.isHidden = true
//                return 0
//            }
//        }
//        else {
//            stackView.isHidden = true
//            return pastOrderArray.count
//        }
        return pastOrderArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell") as! SectionHeaderCell
        cell.costLAbel.text = pastOrderArray[section].currency! + pastOrderArray[section].amount!
        cell.transactionIDLabel.text = pastOrderArray[section].transactionID
        cell.paymentModeLabel.text = pastOrderArray[section].paymentMode
        cell.machineIdLabel.text = pastOrderArray[section].machineID
        cell.transactionDayLabel.text = getFormattedDate(date: pastOrderArray[section].createdAt!)
        cell.transactionTimeLabel.text = getFormattedTime(date: pastOrderArray[section].createdAt!)
        cell.refundIdLabel.text = pastOrderArray[section].refundID
        cell.refundStatus.text = pastOrderArray[section].refundStatus
        cell.refundDayLAbel.text = getFormattedDate(date: pastOrderArray[section].lastUpdatedAt!)
        cell.refundDateLabel.text = getFormattedTime(date: pastOrderArray[section].lastUpdatedAt!)
        if pastOrderArray[section].typeOfSection == .eligibleForRefund {
            cell.refundToGatewayBtn.isHidden = false
            cell.refundIdLabel.isHidden = true
            cell.refundStatus.isHidden = true
            cell.refundDateLabel.isHidden = true
            cell.refundDayLAbel.isHidden = true
            cell.refundIdHeadingLabel.isHidden = true
            cell.refundStatusHeadingLAbel.isHidden = true
        }
        cell.refundClosure = {
            self.refundIndexpath = section
            self.refundToGatewayApiCalled()
            if self.refund200Case {
                cell.refundToGatewayBtn.isHidden = true
                cell.refundIdLabel.isHidden = false
                cell.refundStatus.isHidden = false
                cell.refundDateLabel.isHidden = false
                cell.refundDayLAbel.isHidden = false
                cell.refundIdHeadingLabel.isHidden = false
                cell.refundStatusHeadingLAbel.isHidden = false
                self.refund200Case = false
            }
            else {
                cell.refundToGatewayBtn.isHidden = false
                cell.refundIdLabel.isHidden = true
                cell.refundStatus.isHidden = true
                cell.refundDateLabel.isHidden = true
                cell.refundDayLAbel.isHidden = true
                cell.refundIdHeadingLabel.isHidden = true
                cell.refundStatusHeadingLAbel.isHidden = true
                self.refund200Case = false
            }
        }
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if pastOrderArray[section].typeOfSection == .successfull {
            return 105
        }
        else if pastOrderArray[section].typeOfSection == .eligibleForRefund {
            return 150
        }
        else {
            return 180
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if toCallApiAgain {
            if indexPath.section == pastOrderArray.count - 1 {
                pageNumber += 1
                self.pastOrderApiCall()
            }
        }
        else {
            
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func getFormattedDate(date : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let myDate = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeStamp = dateFormatter.string(from: myDate!)
        return timeStamp
    }
    
    func getFormattedTime(date : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let myDate = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "HH:mm"
        let timeStamp = dateFormatter.string(from: myDate!)
        return timeStamp
    }
    
    func pastOrderApiCall() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let userId : String = UserDefaults.standard.string(forKey: kConstant.localKeys.userId)!
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/customer/transactions/\(userId)/?page=\(pageNumber)")
        print("Past order API",serviceName)
        Alamofire.request(serviceName, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"]
                    for i in 0..<jsonResponse.count {
                        let singleOrder = PastOrderSectionHeaderModel.init(with: jsonResponse[i])
                        self.pastOrderArray.append(singleOrder)
                    }
                    self.tableView.reloadData()
                    if jsonResponse.count < 5 {
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
            self.apiCalled = true
            if self.pastOrderArray.count == 0 {
                self.stackView.isHidden = false
            }
            else {
                self.stackView.isHidden = true
            }
        }
    }

    
    func refundToGatewayApiCalled() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let params : [String : Any] = [
            "_uuid" : pastOrderArray[refundIndexpath!].orderUUID as Any
        ]
        print("Refund to gateway",getFullServiceUrl(serviceName: "/api/vendour/v1/customer/transaction/refund/"))
        Alamofire.request(getFullServiceUrl(serviceName: "/api/vendour/v1/customer/transaction/refund/"), method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"]
                    self.pastOrderArray[self.refundIndexpath!].refundID = jsonResponse["refund_uid"].stringValue
                    self.pastOrderArray[self.refundIndexpath!].refundStatus = jsonResponse["refund_status"].stringValue
                    self.pastOrderArray[self.refundIndexpath!].lastUpdatedAt = jsonResponse["created_at"].stringValue
                    self.pastOrderArray[self.refundIndexpath!].typeOfSection = .refunded
                    self.refund200Case = true
                    self.tableView.reloadData()
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
                    print("inside else")
                }
            }
            else {
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "No Internet Connection")
                print("Inside no internet connection")
            }
            CommonController.shared.hideHud()
        }
    }
}
