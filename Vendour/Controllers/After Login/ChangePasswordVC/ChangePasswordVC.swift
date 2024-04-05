//
//  ChangePasswordVC.swift
//  Vendour
//
//  Created by AppDev on 23/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Alamofire
import SwiftyJSON

class ChangePasswordVC: UIViewController, UITextFieldDelegate {
   
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var passwordTf: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTf.delegate = self
        UIApplication.shared.statusBarStyle = .lightContent
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 4
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length == 4 {
            nextBtn.isEnabled = true
            nextBtn.setImage(UIImage(named: "redArrowBtn"), for: .normal)
        }
        else {
            nextBtn.isEnabled = false
            nextBtn.setImage(UIImage(named: "nextBtn"), for: .normal)
        }
        return newString.length <= maxLength
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        if passwordTf.text == "" {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Please enter new password")
        }
        else if (passwordTf.text?.count)! < 4 {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Password must be 4 digits long")
        }
        else {
            apiCall()
        }
    }
    
    func apiCall() {
         let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/user/\(UserDefaults.standard.value(forKey: kConstant.localKeys.userId) ?? "")/")
        print("Change Password API",serviceName)
        CommonController.shared.showHud(title: "", sender: self.view)
        let params : [String : String] = [
            "password" : passwordTf.text!
        ]
        print(params)
        Alamofire.request(serviceName, method: .put, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let alert = UIAlertController(title: "Vendour", message: "Your password bas been successfully changed.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                        self.navigationController?.popViewController(animated: true)
                        self.view.endEditing(true)
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
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
    
    @IBAction func passwordTfEditingChanged(_ sender: Any) {
        if passwordTf.text?.count == 4 {
            self.view.endEditing(true)
        }
    }
    
}
