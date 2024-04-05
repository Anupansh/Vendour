//
//  Login.swift
//  Vendour
//
//  Created by AppDev on 06/12/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SkyFloatingLabelTextField
import Photos
import SWRevealViewController
import SwiftyJSON

class SignUpVC: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    //MARK:- IBOutlets
    @IBOutlet var  signUpOTPMobileNum : SkyFloatingLabelTextField!
    @IBOutlet var  signUpOTP : SkyFloatingLabelTextField!
    @IBOutlet var  signUpMobileNoMainScreen : SkyFloatingLabelTextField!
    @IBOutlet var  signUpEmail : SkyFloatingLabelTextField!
    @IBOutlet var  signUpDateofBirth : SkyFloatingLabelTextField!
    @IBOutlet var  signUpPassword : SkyFloatingLabelTextField!
    
    @IBOutlet var labelTopVerifyOtp : UILabel!
    
    @IBOutlet var signUpOTPMobileNumNextBtn : UIButton!
    @IBOutlet var signUpMaleBtn : UIButton!
    @IBOutlet var signUpFemaleBtn : UIButton!
    @IBOutlet var signUpOtherBtn : UIButton!
    @IBOutlet var signUpMainScreenNextBtn : UIButton!
    @IBOutlet var imageInvisibleBtn : UIButton!
    @IBOutlet var signUpMobileNumOTPBAcktoLoginBtn : UIButton!
    @IBOutlet var buttonSignUpSendOtp : UIButton!    // next btn on OTP
    
    @IBOutlet var  MainScreenSignUpView : UIView!
    @IBOutlet var  otpVarificationSignUpView : UIView!
    @IBOutlet  var signUpMobileNoVArificationOTPView : UIView!
    @IBOutlet var buttonOpenGallery : UIButton!
    
    @IBOutlet var imageViewProfile : UIImageView!
    
    //MARK:- Variables
    var imagePicker = UIImagePickerController()
    var response = [String:Any]()
    var genderType = ""
    var mobile = ""
    var nameSelected : Bool = false
    var emailSelected : Bool = false
    var dobSelected : Bool = false
    var passwordSelected : Bool = false
    var genderSelected : Bool = false
    var kImage = UIImageView()


    //MARK:- View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewProfile.layer.cornerRadius = 50
        signUpOTPMobileNum.delegate = self
        signUpOTP.delegate = self
        signUpPassword.delegate = self
       //textFieldEditing(signUpDateofBirth)
        specialDateTextFieldClick(signUpDateofBirth)
        
        MainScreenSignUpView.isHidden = true
        otpVarificationSignUpView.isHidden = true
        signUpMobileNoVArificationOTPView.isHidden = false
        signUpOTPMobileNumNextBtn.isEnabled = false
        buttonSignUpSendOtp.isEnabled = false
        signUpMobileNoMainScreen.autocorrectionType = .no
        signUpMobileNoMainScreen.autocapitalizationType = .words
        signUpEmail.autocapitalizationType = .none
    }
    
    @IBAction func termsConditionsBtnPressed(_ sender: Any) {
        let vc = TermsAndConditionsVC()
        vc.cameFrom = .signup
        self.present(vc, animated: true, completion: nil)
    }
    
   override func viewDidAppear(_ animated: Bool) {
    //Outline color
        signUpMobileNumOTPBAcktoLoginBtn.layer.borderWidth = 1
        signUpMobileNumOTPBAcktoLoginBtn.layer.cornerRadius = 5
        signUpMobileNumOTPBAcktoLoginBtn.layer.borderColor = UIColor.init(red: 255/255, green: 0, blue: 0, alpha: 1).cgColor
    }
    
    
    //Text Length check for mobile number
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if(textField == signUpOTPMobileNum){
        let maxLength = 10
        let currentString: NSString = signUpOTPMobileNum.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        let newLength = signUpOTPMobileNum.text!.count + string.count - range.length
        if newLength < 10 {
            signUpOTPMobileNumNextBtn.isEnabled = false
            signUpOTPMobileNumNextBtn.setImage(UIImage(named: "nextBtn"), for: .normal)
        }else{
             signUpOTPMobileNumNextBtn.isEnabled = true
             signUpOTPMobileNumNextBtn.setImage(UIImage(named: "redArrowBtn"), for: .normal)
        }
            
        return newString.length <= maxLength
    
    }else if(textField == signUpOTP ){
    let maxLength = 4
    let currentString: NSString = signUpOTP.text! as NSString
    let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
    
    let newLength = signUpOTP.text!.count + string.count - range.length
    if newLength < 4 {
        buttonSignUpSendOtp.isEnabled = false
        buttonSignUpSendOtp.setImage(UIImage(named: "nextBtn"), for: .normal)
    }else{
        buttonSignUpSendOtp.isEnabled = true
        buttonSignUpSendOtp.setImage(UIImage(named: "redArrowBtn"), for: .normal)
    }
             return newString.length <= maxLength
    }
        if signUpMobileNoMainScreen.text != "" && signUpEmail.text != "" && signUpDateofBirth.text != "" && signUpPassword.text != ""{
            signUpMainScreenNextBtn.isEnabled = true
            signUpMainScreenNextBtn.setImage(UIImage(named: "redArrowBtn"), for: .normal)
        }
        if textField == signUpPassword{
            let maxLength = 4
            let currentString: NSString = signUpPassword.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        signupBtnHighlight()
    }
    
    
    func signupBtnHighlight(){
        if signUpMobileNoMainScreen.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&  signUpEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" && signUpDateofBirth.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" && signUpPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
            genderType != "" {
            signUpMainScreenNextBtn.setImage(UIImage(named: "redArrowBtn"), for: .normal)
        }else{
            signUpMainScreenNextBtn.setImage(UIImage(named: "nextBtn"), for: .normal)
        }
        
    }
    
    func openAlertPopup(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraButton = UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
            self.openCameraButton(sender: action)
        })
        let  galleryButton = UIAlertAction(title: "Select from Gallery", style: .default, handler: { (action) -> Void in
            self.openPhotoLibraryButton(sender: action)
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        })
        alertController.addAction(cameraButton)
        alertController.addAction(galleryButton)
        alertController.addAction(cancelButton)
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    
    
    //Mark:- Camera Code
    func openCameraButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
//            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibraryButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageViewProfile.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
        if let updatedImage = self.imageViewProfile.image?.updateImageOrientionUpSide() {
            kImage.image = updatedImage
        }
        else {
            kImage.image = self.imageViewProfile.image
        }
    }
    
    
    
    
    //Mark:- APIs Almofire
    func registerUserWithAlamofire(){
         if NetworkReachabilityManager()!.isReachable{
            
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/user/register/")
//        let requestParam : [String : Any] = ["dob":signUpDateofBirth.text!,
//                                             "gender":genderType,
//                                             "mobile" :signUpMobileNoMainScreen.text!,
//                                             "email" : signUpEmail.text!,
//                                             "password"  :signUpPassword.text! ,
//                                             "username" : ""]
//            print(requestParam)
//        Alamofire.request(serviceName, method: .post, parameters: requestParam, encoding: JSONEncoding.default , headers : CommonController.shared.getHeaders()).responseJSON{
//                    response in
//                    print(response.result.value as AnyObject)
//                    CommonController.shared.hideHud()
//                    guard response.result.isSuccess else {
//                        print("Error while fetching data : \(String(describing: response.result.error))")
//                        CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Error while fetching data.")
//                        return
//                    }
//                    guard let dict = response.result.value as? NSDictionary else {
//                        print("Malformed data received ")
//                        return
//                    }
//                    guard let status = dict["status"] as? Int else{return}
//                    if  Int(status) == 200 {
//                        print(dict)
//                    }else if Int(status) == 204{
//                        let message = (dict.object(forKey: "Message") as! String)
//                        print(message)
//                    }else if Int(status) == 401{
//                        let message = (dict.object(forKey: "Message") as! String)
//                    }
//            }
    
            let image = kImage.image
            CommonController.shared.showHud(title: "", sender: self.view)
            print("Sign Up API")
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append(self.signUpDateofBirth.text!.data(using: .utf8)!, withName: "dob")
                    multipartFormData.append(self.genderType.data(using: .utf8)!, withName: "gender")
                    multipartFormData.append(self.signUpMobileNoMainScreen.text!.data(using: .utf8)!, withName: "username")
                    multipartFormData.append(self.signUpEmail.text!.data(using: .utf8)!, withName: "email")
                    multipartFormData.append(self.signUpPassword.text!.data(using: .utf8)!, withName: "password")
                    multipartFormData.append("iOS".data(using: .utf8)!, withName: "device")
                    multipartFormData.append("1".data(using: .utf8)!, withName: "app_version")
                    multipartFormData.append(self.mobile.data(using: .utf8)!, withName: "mobile")
                    if self.imageViewProfile.image != UIImage(named: "profilePlaceholder") {
                        let imgData = image?.jpegData(compressionQuality: 0.5)!
                        multipartFormData.append(imgData!, withName: "profile_image", fileName: "send.png", mimeType: "image/png")
                    }
            }, to: serviceName , headers: CommonController.shared.getHeaders()) { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        CommonController.shared.hideHud()
                        if !response.result.isSuccess {
                            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "No Internet Connection")
                        } else {
                            
//                            guard let response = response.result.value as? NSDictionary else {
//                                print("Data not recieved in correct format.")
//                                return
//                            }
//                            let finalResponse = response.object(forKey: "response") as [String:Any]
            
//                            let response = response.result.value as! [String:Any]
                            let response = JSON(response.result.value!)
                            print(response)
                            let jsonResponse = response["response"]
                            let authToken = jsonResponse["auth_token"].stringValue
                            let name = jsonResponse["username"].stringValue
                            let mobileNumber = jsonResponse["mobile"].stringValue
                            let imageName = jsonResponse["profile_image"].stringValue
                            let email = jsonResponse["email"].stringValue
                            let userId = jsonResponse["id"].stringValue
                            let dob = jsonResponse["dob"].stringValue
                            let customerId = jsonResponse["_uid"].stringValue
                            UserDefaults.standard.set(authToken, forKey: kConstant.localKeys.authToken)
                            UserDefaults.standard.set(name, forKey: kConstant.localKeys.userName)
                            UserDefaults.standard.set(mobileNumber, forKey: kConstant.localKeys.mobNumber)
                            UserDefaults.standard.set(imageName, forKey: kConstant.localKeys.imageURL)
                            UserDefaults.standard.set(email, forKey: kConstant.localKeys.emailId)
                            UserDefaults.standard.set(userId, forKey: kConstant.localKeys.userId)
                            UserDefaults.standard.set(dob, forKey: kConstant.localKeys.dob)
                            UserDefaults.standard.set(customerId, forKey: kConstant.localKeys.customerId)
                            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        }
    }
    @IBAction func termsAndConditionsBtnPressed(_ sender: Any) {
        let vc = TermsAndConditionsVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: Send OTP Api
    func sendMobileNoForOTPSignUpAlmofire(){
        if NetworkReachabilityManager()!.isReachable{
        guard let getMobileNoOTPSifnUp = signUpOTPMobileNum.text else{
            CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Mobile number is required!")
            return}
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/registration/otp/")
        let requestParam : [String : Any] = ["mobile" : [getMobileNoOTPSifnUp] ]
        print("Mobile number API", serviceName)
        print(requestParam)
        CommonController.shared.showHud(title: "", sender: self.view)
        Alamofire.request(serviceName, method: .post, parameters: requestParam, encoding: JSONEncoding.default , headers : CommonController.shared.getHeaders()).responseJSON{
            response in
            print(response)
            CommonController.shared.hideHud()
            CommonController.shared.hideHud()
            guard response.result.isSuccess else {
                CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Error while fetching data ")
                return
            }
            guard let dict = response.result.value as? NSDictionary else {
                return
            }
            let message = dict["message"] as? String
            guard let status = dict["status"] as? Int else{return}
                                if  Int(status) == 200 {
                                    self.MainScreenSignUpView.isHidden = true
                                    self.otpVarificationSignUpView.isHidden = false
                                    self.signUpMobileNoVArificationOTPView.isHidden = true
                                    self.mobile = self.signUpOTPMobileNum.text!
                                    self.labelTopVerifyOtp.text = "We have sent you an OTP via SMS on \(self.signUpOTPMobileNum.text!) for verification"
//                                    self.sendOTPForSignUpAlmofire( getMobileNoOTPSifnUp)
//                                    print(getMobileNoOTPSifnUp)
            }
                                else {
                                    CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: message!)
            }
        }
        }
        else{
            CommonController.shared.myAlert(title: "", message: "Please check internet connection.", buttonTitle: "Ok", view: self)
        }
    }

   
    
    //MARK: Verify OTP Api
    func sendOTPForSignUpAlmofire(_ mobileNo : String) {
         if NetworkReachabilityManager()!.isReachable {
            guard let getOTPSignUp = signUpOTP.text else {
                CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Mobile number is required!")
                return}
        let serviceName = getFullServiceUrl(serviceName: "/api/v1/verify/otp/")
        
        let requestParam : [String : Any] = ["mobile" : [mobileNo],
                                             "otp" : getOTPSignUp]
            print("Verify OTP API",serviceName)
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
                print(dict)
                //self.registerUserWithAlamofire()
                self.view.endEditing(true)
                self.otpVarificationSignUpView.isHidden = true
                self.MainScreenSignUpView.isHidden = false

            }else{
                CommonController.shared.ShowAlert(self, msg_title: "", message_heading: message)
            }
//                                else if Int(status) == 204{
//                                    let message = (dict.object(forKey: "Message") as! String)
//                                    print(message)
//
//                                }else if Int(status) == 401{
//                                    let message = (dict.object(forKey: "Message") as! String)
//                                }
        }
    }
    
    
    
    
    }
    
    
    
    
    //MARK:- IBActions
    
    
    @IBAction func backToLoginAction(){
        self.navigationController?.popViewController(animated: true)
    }
   
    @IBAction func nextBtnMobileNumOTPSignUpAction(){
        
            if signUpOTPMobileNum.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                CommonController.shared.myAlert(title: "", message: "Please Enter Mobile Number", buttonTitle: "OK", view: self)
            }
            else if signUpOTPMobileNum.text?.count != 10 {
                 CommonController.shared.myAlert(title: "", message: "Please enter correct mobile number", buttonTitle: "OK", view: self)
            }
            else{
                signUpOTP.becomeFirstResponder()
                sendMobileNoForOTPSignUpAlmofire()
            }
        }
    
    
    @IBAction func nextBtnMainScreenSignUpAction(_sender:UIButton){
        
        if signUpMobileNoMainScreen.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            CommonController.shared.myAlert(title: "", message: "Please Enter Name", buttonTitle: "OK", view: self)
        }
        else  if signUpEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            CommonController.shared.myAlert(title: "", message: "Please Enter Correct Mail id", buttonTitle: "OK", view: self)
        }else  if signUpDateofBirth.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            CommonController.shared.myAlert(title: "", message: "Please Enter Date of Birth", buttonTitle: "OK", view: self)
        }else  if signUpPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            CommonController.shared.myAlert(title: "", message: "Please Enter Password", buttonTitle: "OK", view: self)
        }else  if signUpMaleBtn.isSelected == false && signUpFemaleBtn.isSelected == false && signUpOtherBtn.isSelected == false{
            CommonController.shared.myAlert(title: "", message: "Please Choose a gender", buttonTitle: "OK", view: self)
        }else if !CommonController.shared.isValidEmail(candidate: signUpEmail.text!) {
            CommonController.shared.myAlert(title: "", message: "Please enter correct E-Mail ID", buttonTitle: "OK", view: self)
        }
        else{
           registerUserWithAlamofire()
        }
    }
    
    @IBAction func nameEditingBegin(_ sender: Any) {
        if nameSelected && emailSelected && dobSelected && passwordSelected && genderSelected {
            signUpMainScreenNextBtn.isEnabled = true
            signUpMainScreenNextBtn.setImage(UIImage(named: "redArrowBtn"), for: .normal)
        }
        nameSelected = true
    }
    
    @IBAction func emailEditingBegin(_ sender: Any) {
        emailSelected = true
        if nameSelected && emailSelected && dobSelected && passwordSelected && genderSelected {
            signUpMainScreenNextBtn.isEnabled = true
            signUpMainScreenNextBtn.setImage(UIImage(named: "redArrowBtn"), for: .normal)
        }
    }
    
    @IBAction func dobEditingBegin(_ sender: Any) {
        dobSelected = true
        if nameSelected && emailSelected && dobSelected && passwordSelected && genderSelected {
            signUpMainScreenNextBtn.isEnabled = true
            signUpMainScreenNextBtn.setImage(UIImage(named: "redArrowBtn"), for: .normal)
        }
    }
    
    @IBAction func passwordEditingBegin(_ sender: Any) {
        passwordSelected = true
        if nameSelected && emailSelected && dobSelected && passwordSelected && genderSelected {
            signUpMainScreenNextBtn.isEnabled = true
            signUpMainScreenNextBtn.setImage(UIImage(named: "redArrowBtn"), for: .normal)
        }
    }
    @IBAction func genderSelectionAction(_sender:UIButton){
        
        if _sender == signUpMaleBtn{
            genderSelected = true
            genderType = "M"
            signUpMaleBtn.isSelected = true
            signUpFemaleBtn.isSelected = false
            signUpOtherBtn.isSelected = false
            if nameSelected && emailSelected && dobSelected && passwordSelected && genderSelected {
                signUpMainScreenNextBtn.isEnabled = true
                signUpMainScreenNextBtn.setImage(UIImage(named: "redArrowBtn"), for: .normal)
            }
            
        }
        else if _sender == signUpFemaleBtn{
            genderSelected = true
            genderType = "F"
            signUpMaleBtn.isSelected = false
            signUpFemaleBtn.isSelected = true
            signUpOtherBtn.isSelected = false
            if nameSelected && emailSelected && dobSelected && passwordSelected && genderSelected {
                signUpMainScreenNextBtn.isEnabled = true
                signUpMainScreenNextBtn.setImage(UIImage(named: "redArrowBtn"), for: .normal)
            }
            
            
        }else if _sender == signUpOtherBtn{
            genderSelected = true
            genderType = "O"
            signUpMaleBtn.isSelected = false
            signUpFemaleBtn.isSelected = false
            signUpOtherBtn.isSelected = true
            if nameSelected && emailSelected && dobSelected && passwordSelected && genderSelected {
                signUpMainScreenNextBtn.isEnabled = true
                signUpMainScreenNextBtn.setImage(UIImage(named: "redArrowBtn"), for: .normal)
            }
        }
    }
    
    
    // Keyboard hide Show
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
    @IBAction func btnSendOtpSignUpActn(){
       if signUpOTP.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            CommonController.shared.myAlert(title: "", message: "Please Enter OTP", buttonTitle: "OK", view: self)
        }
        else if signUpOTP.text?.count != 4 {
            CommonController.shared.myAlert(title: "", message: "Please enter correct OTP", buttonTitle: "OK", view: self)
        }
        else{
        sendOTPForSignUpAlmofire(signUpOTPMobileNum.text!)
//        self.view.endEditing(true)
//        otpVarificationSignUpView.isHidden = true
//        MainScreenSignUpView.isHidden = false
        }
    }
    
    @IBAction func handleGallery(){
        openAlertPopup()
    }
    
    
//    @IBAction func textFieldEditing(_ sender: UITextField) {
//
//        let datePickerView:UIDatePicker = UIDatePicker()
//
//        datePickerView.datePickerMode = UIDatePicker.Mode.date
//
//        sender.inputView = datePickerView
//
//        datePickerView.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: .valueChanged)
//
//    }
//
//
//    @objc func datePickerValueChanged(sender:UIDatePicker) {
//
//        let dateFormatter = DateFormatter()
//
//        dateFormatter.dateStyle = .medium
//
//        dateFormatter.timeStyle = .none
//
//        signUpDateofBirth.text = dateFormatter.string(from: sender.date )
//
//    }

    
    
    @IBAction func specialDateTextFieldClick(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        signUpDateofBirth.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerFromValueChanged(sender:)), for: .valueChanged)
        datePickerView.maximumDate = Date()
    }
    
    @IBAction func btnResendOtpActn(){
        signUpOTP.text = ""
        sendMobileNoForOTPSignUpAlmofire()
    }
    
    @objc func datePickerFromValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        signUpDateofBirth.text = dateFormatter.string(from: sender.date)
        
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
