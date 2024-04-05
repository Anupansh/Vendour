//
//  DrawerMenu.swift
//  Vendour
//
//  Created by AppDev on 18/12/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DrawerMenu: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var walletBalanceLabel: UILabel!
    let arr = ["My Profile","Past Orders","Wallet","Invite Friends","Help","Logout"]
    var arrIcon:[UIImage] = [
        UIImage(named: "profile_image")!,
        UIImage(named: "past_order_image")!,
        UIImage(named: "wallet_image")!,
        UIImage(named: "invite_friends_image")!,
        UIImage(named: "help_image")!,
        UIImage(named: "logout_image")!,]


    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewOutlet.separatorStyle = .none
        initialSetup()
        getBalanceApiCalled()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBalanceApiCalled()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DrawerMenuCell
        cell.menuLabel.text = String(arr[indexPath.row])
        cell.selectionStyle = .none
        cell.imageViewIcon.image = arrIcon[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = UserProfile_()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 1{
            let vc = PastOrdersVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 2 {
            let vc = WalletVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 3 {
            let text = "vendour.in"
            let textToShare = [text]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
        else if indexPath.row == 4 {
            let vc = HelpVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 5 {
            let alert = UIAlertController(title: "Vendour", message: "Are you sure you want to logout?", preferredStyle: .alert)
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
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func initialSetup() {
        profileImage.layer.cornerRadius = 65.0
        profileImage.layer.masksToBounds = true
        profileImage.clipsToBounds = true
        nameLabel.text = UserDefaults.standard.string(forKey: kConstant.localKeys.userName)
        numberLabel.text = UserDefaults.standard.string(forKey: kConstant.localKeys.mobNumber)
        if let url = URL(string: UserDefaults.standard.string(forKey: kConstant.localKeys.imageURL)!) {
            if let data = NSData(contentsOf: url) {
                profileImage.image = UIImage(data: data as Data)
            }
        }
    }
    
    func getBalanceApiCalled() {
        print("Get balance API",getFullServiceUrl(serviceName: "/api/vendour/v1/wallet/") )
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
                }
                else if response.response?.statusCode == 403 {
                    let alert = UIAlertController(title: "Vendour", message: "Something wrong happened. Please login again to continue.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Yes", style: .default) { (alert) in
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
}
