//
//  SignUpVC.swift
//  Vendour
//
//  Created by AppDev on 05/12/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SWRevealViewController
import Alamofire


enum CurrentlyAt {
    case Login
    case OTP
    case MobileNumber
    case ChangePassword
}
class Login: UIViewController,UITextFieldDelegate {
   
    // MARK :- VIEW OUTLETS
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var mobileNumberView: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var forgotPwdView: UIView!
    
    // MARK :- ENTER MOBILE OUTLETS AND VARIABLES
    
    @IBOutlet weak var mobileNumberTf: SkyFloatingLabelTextField!
    @IBOutlet weak var backToLoginBtn: UIButton!
    @IBOutlet weak var mobileNumberViewNextBtn: UIButton!
    
    // MARK :- OTP OUTLETS AND VARIABLES
    
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var otpTf: SkyFloatingLabelTextField!
    
    // MARK :- NEW PASSWORD OUTLETS AND VARIBLES
    
    @IBOutlet weak var newPasswordTf: SkyFloatingLabelTextField!
    @IBOutlet weak var newPasswordViewNextBtn: UIButton!
    
    
    @IBOutlet weak var underlineMobileno: UILabel!
    @IBOutlet weak var underlinePwd: UILabel!
    
    @IBOutlet weak var underlineMobForgotPwd: UIView!
    @IBOutlet weak var OTPSentView: UIView!
    @IBOutlet var viewSignUp : UIView!
    @IBOutlet weak var nextBtnFgtPwd: UIButton!
    @IBOutlet weak var backToLogin: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var mobileNo: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
    @IBOutlet weak var forgotPassMobNo: UITextField!
    @IBOutlet weak var  otpLoginFgtPwd : SkyFloatingLabelTextField!
    @IBOutlet var buttonLoginNext : UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var otpViewNextBtn: UIButton!
    
    
    var textCount = 0
    var mobileNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otpView.layer.cornerRadius = 10
        mobileNumberView.layer.cornerRadius = 10
        loginView.layer.cornerRadius = 10
        forgotPwdView.layer.cornerRadius = 10
        viewSignUp.layer.cornerRadius = 10
        viewSignUp.clipsToBounds = true
        loginView.isHidden = false
        otpView.isHidden = true
        mobileNumberView.isHidden = true
        forgotPwdView.isHidden = true
        backBtn.isHidden = true
        backToLoginBtn.layer.borderWidth = 1
        backToLoginBtn.layer.borderColor = UIColor.init(red: 255/255, green: 0, blue: 0, alpha: 1).cgColor
        backToLoginBtn.layer.cornerRadius = 5
        otpTf.delegate = self
        newPasswordTf.delegate = self
        mobileNumberTf.delegate = self
        mobileNo.delegate = self
        passwordField.delegate = self
        // Do any additional setup after loading the view.
    }
    // function which is triggered when handleTap is called


    @IBAction func passwordEditingChanged(_ sender: Any) {
        if passwordField.text?.count == 4 {
            self.view.endEditing(true)
        }
    }
    
    @IBAction func mobileNoEditingChanged(_ sender: Any) {
        if mobileNo.text?.count == 10 {
            passwordField.becomeFirstResponder()
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        signUpBtn.layer.borderWidth = 1
        signUpBtn.layer.cornerRadius = 5
        signUpBtn.layer.borderColor = UIColor.init(red: 255/255, green: 0, blue: 0, alpha: 1).cgColor
    }
    
    @IBAction func backToLoginBtnPressed(_ sender: Any) {
        loginView.isHidden = false
        otpView.isHidden = true
        mobileNumberView.isHidden = true
        forgotPwdView.isHidden = true
    }
    
    //MARK:- Textfield delegate methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == mobileNo{
            underlineMobileno.backgroundColor = UIColor.init(red: 255/255 , green: 0, blue: 0, alpha: 1)
        }
       else if textField == forgotPassMobNo{
            underlineMobForgotPwd.backgroundColor = UIColor.init(red: 255/255 , green: 0, blue: 0, alpha: 1)
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        loginView.isHidden = true
        otpView.isHidden = true
        mobileNumberView.isHidden = false
        forgotPwdView.isHidden = true
        backBtn.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

           if textField == mobileNo{
            underlineMobileno.backgroundColor = UIColor.init(red: 100/255 , green: 100/255, blue: 100/255, alpha: 1)
        }

        if textField == forgotPassMobNo{
            underlineMobForgotPwd.backgroundColor = UIColor.init(red: 100/255 , green: 100/255, blue: 100/255, alpha: 1)
        }
    }
    
    func mobileNumberApiCall() {
        
    }
    func loginWithAlamofire() {
        
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/login")
        guard let mobNumber = mobileNo.text else {
            CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Mobile number is required")
            return
        }
        guard let password = passwordField.text else {
            CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Password is required")
            return
        }
        
        if !CommonController.shared.isValidPhone(phone: mobNumber){
            CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Invalid phone number")
            return
        }
        if password.count < 4 {
            CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Password must be atleast 4 characters")
            return
        }
        let params : [String:Any] = [
            "mobile":mobNumber,
            "password":password,
            "app_version":"1.0" as Any,
            "device":"iOS"
        ]
        print("Login API",serviceName)
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeaders()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = response.result.value as! [String:Any]
                print(json)
                let message = json["message"] as! String
                guard let data = response.result.value as? NSDictionary else{
                    return
                }
                if response.response?.statusCode == 200 {
                    let authToken = (data.object(forKey: "response") as AnyObject).object(forKey: "auth_token") as! String
                    let name = (data.object(forKey: "response") as AnyObject).object(forKey: "username") as! String
                    let mobileNumber = (data.object(forKey: "response") as AnyObject).object(forKey: "mobile") as Any
                    let imageName = (data.object(forKey: "response") as AnyObject).object(forKey: "profile_image") as! String
                    let email = (data.object(forKey: "response") as AnyObject).object(forKey: "email") as! String
                    let userId = (data.object(forKey: "response") as AnyObject).object(forKey: "id") as Any
                    let dob = (data.object(forKey: "response") as AnyObject).object(forKey: "dob") as! String
                    let customerId = (data.object(forKey: "response") as AnyObject).object(forKey: "customer_id") as! String
                    UserDefaults.standard.set(authToken, forKey: kConstant.localKeys.authToken)
                    UserDefaults.standard.set(name, forKey: kConstant.localKeys.userName)
                    UserDefaults.standard.set(mobileNumber, forKey: kConstant.localKeys.mobNumber)
                    UserDefaults.standard.set(imageName, forKey: kConstant.localKeys.imageURL)
                    UserDefaults.standard.set(email, forKey: kConstant.localKeys.emailId)
                    UserDefaults.standard.set(userId, forKey: kConstant.localKeys.userId)
                    UserDefaults.standard.set(dob, forKey: kConstant.localKeys.dob)
                    UserDefaults.standard.set(customerId, forKey: kConstant.localKeys.customerId)
                    print(userId)
                let controller = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                self.navigationController?.pushViewController(controller, animated: true)
                }
                else {
                    self.errorMessage(message: message)
                    CommonController.shared.ShowAlert(self, msg_title: "", message_heading: message)
                }
            }
            else {
                self.errorMessage(message: "No Internet Connection")
            }
        }
    }

    func mobileNumberViewApiCalled() {
        if mobileNumberTf.text == "" {
            errorMessage(message: "Please enter mobile number")
        }
        else {
            let params : [String:Any] = [
                "mobile":[mobileNumberTf.text!]
            ]
            let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/password/reset/otp/")
            print("Mobile number API",serviceName)
            print("PArametes",params)
            Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeaders()).responseJSON { (response) in
                if response.result.isSuccess {
                    let json = response.result.value as? [String:Any]
                    print(json)
                    let message = json!["message"] as! String
                    if response.response?.statusCode == 200 {
                        self.mobileNumber = self.mobileNumberTf.text!
                        self.otpLabel.text = "We have sent you an OTP via sms on \(self.mobileNumber) for verification"
                        self.loginView.isHidden = true
                        self.otpView.isHidden = false
                        self.mobileNumberView.isHidden = true
                        self.forgotPwdView.isHidden = true
                        self.mobileNumberTf.text = ""
                        self.backBtn.isHidden = false
                    }
                    else {
                        self.errorMessage(message: message)
                    }
                }
            else {
                self.errorMessage(message: "No Internet Connection")
            }
        }
        }
    }
    //MARK: Verify OTP Api
    func verifyOtpWithAlmofire(_ mobileNo : String){
        if NetworkReachabilityManager()!.isReachable{
            
            let serviceName = getFullServiceUrl(serviceName: "/api/v1/verify/otp/")
            
            let requestParam : [String : Any] = ["mobile" : [mobileNo],
                                                 "otp" : ""]
            print("Verify OTP API", serviceName)
            print(requestParam)
            CommonController.shared.showHud(title: "", sender: self.view)
            Alamofire.request(serviceName, method: .post, parameters: requestParam, encoding: JSONEncoding.default , headers : CommonController.shared.getHeaders()).responseJSON{
                response in
                
                print(response)
                
                CommonController.shared.hideHud()
                guard response.result.isSuccess else {
                    CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Error while fetching data ")
                    return
                }
                guard let dict = response.result.value as? NSDictionary else {
                    return
                }
                
                let message = (dict.object(forKey: "message") as! String)
                guard let status = dict["status"] as? Int else{return}
                if  Int(status) == 200 {
                }else{
                    CommonController.shared.ShowAlert(self, msg_title: "", message_heading: message)
                }
            }
        }
    }
    
    @IBAction func resendOtpBtnPressed(_ sender: Any) {
        let params : [String:Any] = [
            "mobile":[mobileNumber]
        ]
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/password/reset/otp/")
        print("Resend OTP API",serviceName)
        print("PArametes",params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeaders()).responseJSON { (response) in
            print("Response is",response)
            if response.result.isSuccess {
                let json = response.result.value as? [String:Any]
                let message = json!["message"] as! String
                if response.response?.statusCode == 200 {
                    self.errorMessage(message: "OTP Sent again")
                }
                else {
                    self.errorMessage(message: message)
                }
            }
            else {
                self.errorMessage(message: "No Internet Connection")
            }
        }
    }
    
    
    @IBAction func newPasswordNextBtnPressed(_ sender: Any) {
        newPasswordApiCalled()
    }
    
    func newPasswordApiCalled() {
        
        guard let newPassword = newPasswordTf.text , newPassword != "" else{
            CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Please enter new password")
            return
        }
            let params : [String:Any] = [
                "mobile":mobileNumber,
                "password": newPassword
            ]
            let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/user/password/reset/")
        print("New Password API",serviceName)
        print("PArametes",params)
            Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeaders()).responseJSON { (response) in
                print("Response is",response)
                if response.result.isSuccess {
                    let json = response.result.value as? [String:Any]
                    let message = json!["message"] as! String
                    if response.response?.statusCode == 200 {
                        let alert = UIAlertController(title: "Vendour", message: "Your password has been successfully changed", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                            self.loginView.isHidden = false
                            self.otpView.isHidden = true
                            self.mobileNumberView.isHidden = true
                            self.forgotPwdView.isHidden = true
                            self.newPasswordTf.text = ""
                            self.view.endEditing(true)
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        self.errorMessage(message: message)
                    }
                }
                else {
                    self.errorMessage(message: "No Internet Connection")
                }
            }
    }
    
    //MARK:- IBActions
    @IBAction func newPasswordViewEditingChanged(_ sender: Any) {
        if newPasswordTf.text?.count == 4 {
            self.view.endEditing(true)
        }
    }
    
    @IBAction func signUpBtnAction(_ sender: Any) {
            let vc = SignUpVC()
            self.navigationController?.pushViewController(vc, animated: true)
        
    }
    @IBAction func otpViewEditingChanged(_ sender: Any) {
        if otpTf.text?.count == 4 {
            self.view.endEditing(true)
        }
    }
    
    @IBAction func mobileNumberViewEditingChanged(_ sender: Any) {
        if mobileNumberTf.text?.count == 10 {
            self.view.endEditing(true)
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == otpTf {
            let maxLength = 4
                        let currentString: NSString = textField.text! as NSString
                        let newString: NSString =
                        currentString.replacingCharacters(in: range, with: string) as NSString
                        if newString.length == 4 {
                            otpViewNextBtn.isUserInteractionEnabled = true
                            otpViewNextBtn.setImage( UIImage(named: "redArrowBtn"), for: .normal)
                        }
                        else {
                            otpViewNextBtn.isUserInteractionEnabled = false
                            otpViewNextBtn.setImage( UIImage(named: "nextBtn"), for: .normal)
                        }
                        return newString.length <= maxLength
        }
        if textField == mobileNumberTf {
            let maxLength = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length == 10 {
                mobileNumberViewNextBtn.isUserInteractionEnabled = true
                mobileNumberViewNextBtn.setImage( UIImage(named: "redArrowBtn"), for: .normal)
            }
            else {
                mobileNumberViewNextBtn.isUserInteractionEnabled = false
                mobileNumberViewNextBtn.setImage( UIImage(named: "nextBtn"), for: .normal)
            }
            return newString.length <= maxLength
        }
        if textField == newPasswordTf {
            let maxLength = 4
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length == 4 {
                newPasswordViewNextBtn.isUserInteractionEnabled = true
                newPasswordViewNextBtn.setImage( UIImage(named: "redArrowBtn"), for: .normal)
            }
            else {
                newPasswordViewNextBtn.isUserInteractionEnabled = false
                newPasswordViewNextBtn.setImage( UIImage(named: "nextBtn"), for: .normal)
            }
            return newString.length <= maxLength
        }
        if textField == mobileNo {
            let maxLength = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        if textField == passwordField {
            let maxLength = 4
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            if newString.length == 4 {
                buttonLoginNext.isUserInteractionEnabled = true
                buttonLoginNext.setImage( UIImage(named: "redArrowBtn"), for: .normal)
            }
            else {
                buttonLoginNext.isUserInteractionEnabled = false
                buttonLoginNext.setImage( UIImage(named: "nextBtn"), for: .normal)
            }
            return newString.length <= maxLength
        }
        return true
    }
    @IBAction func otpViewNextBtnPressed(_ sender: Any) {
        otpViewApiCalled()
    }
    
    func otpViewApiCalled() {
        guard let otp = otpTf.text , otp != "" else{
            CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Please enter OTP")
            return
        }

            let serviceName = getFullServiceUrl(serviceName: "/api/v1/verify/otp/")
            let param : [String : Any] = [
                "mobile" : [mobileNumber],
                "otp" : otp
            ]
            print("OTP API",serviceName)
            print(param)
            Alamofire.request(serviceName, method: .post, parameters: param, encoding: JSONEncoding.default , headers : CommonController.shared.getHeaders()).responseJSON{ (response) in
                if response.result.isSuccess {
                    let json = response.result.value as? [String:Any]
                    print(json)
                    let message = json!["message"] as! String
                    if response.response?.statusCode == 200 {
                        self.loginView.isHidden = true
                        self.otpView.isHidden = true
                        self.mobileNumberView.isHidden = true
                        self.forgotPwdView.isHidden = false
                        self.backBtn.isHidden = true
                        self.otpTf.text = ""
                    }
                    else {
                        self.errorMessage(message: message)
                    }
                }
                else {
                    self.errorMessage(message: "No Internet Connection")
                }
            }
        
    }
    
    @IBAction func mobileViewNextBtnPressed(_ sender: Any) {
        mobileNumberViewApiCalled()
    }
    
    @IBAction func forgotBtnAction(){
        loginView.isHidden = true
        otpView.isHidden = true
        mobileNumberView.isHidden = false
        forgotPwdView.isHidden = true
    }

   
    @IBAction func loginBtnAction(){
        loginWithAlamofire()
    }

    func errorMessage(message : String) {
        let when = DispatchTime.now() + 2
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        DispatchQueue.main.asyncAfter(deadline: when) {
           alert.dismiss(animated: true, completion: nil)
        }
        self.present(alert, animated: true, completion: nil)
    }
}
