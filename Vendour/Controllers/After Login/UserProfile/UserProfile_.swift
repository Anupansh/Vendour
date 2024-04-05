//
//  UserProfile_.swift
//  Vendour
//
//  Created by AppDev on 19/12/18.
//  Copyright © 2018 Test. All rights reserved.
//




import UIKit
import SkyFloatingLabelTextField
import Alamofire
import SwiftyJSON
import SWRevealViewController

class UserProfile_: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var baseView : UIView!
    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.delegate = self
            tableview.dataSource = self
            tableview.separatorStyle = .none
        }
    }
    var imagePicker = UIImagePickerController()
    var mobileNumber : String?
    var name : String?
    var email : String?
    var dob : String?
    var profileImage = UIImageView()
    var kImage = UIImageView()
    
    @IBOutlet weak var testImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "UserProfileCell") as! UserProfileCell
        cell.mobileLabel.text = mobileNumber
        cell.nameTf.text = name
        cell.emailTf.text = email
        cell.dobTf.text = dob
        cell.profileImage.image = self.profileImage.image
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 667
    }
    
    func initialSetup() {
        let nibName = UINib(nibName: "UserProfileCell", bundle: nil)
        tableview.register(nibName, forCellReuseIdentifier: "UserProfileCell")
//        UIApplication.shared.statusBarStyle = .lightContent
        mobileNumber = UserDefaults.standard.string(forKey: kConstant.localKeys.mobNumber)
        name = UserDefaults.standard.string(forKey: kConstant.localKeys.userName)
        email = UserDefaults.standard.string(forKey: kConstant.localKeys.emailId)
        dob = UserDefaults.standard.string(forKey: kConstant.localKeys.dob)
        profileImage.image = convertToImage(imageURL: UserDefaults.standard.string(forKey: kConstant.localKeys.imageURL)!)
        kImage = profileImage
        tableview.reloadData()
    }
    
    func convertToImage(imageURL : String) -> UIImage {
        if let url = URL(string: imageURL) {
            if let data = NSData(contentsOf: url) {
                return UIImage(data: data as Data)!
            }
        }
        return UIImage()
    }
}

extension UserProfile_ : BackToVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func saveBtnPressed(name: String, dob: String, email: String) {
//        CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "API under construction")
        if email == "" {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "E-Mail cannot be blank")
        }
        else if dob == "" {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Date Of Birth cannot be blank")
        }
        else if name == "" {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Name cannot be blank")
        }
        else if !CommonController.shared.isValidEmail(candidate: email) {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Please enter valid E-Mail")
        }
        else {
            CommonController.shared.showHud(title: "", sender: self.view)
            let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/user/\(UserDefaults.standard.value(forKey: kConstant.localKeys.userId) ?? "")/")
            let params : [String : String] = [
                "dob" : dob,
                "email" : email,
                "username" : name
            ]
            print("Update User API",serviceName)
            print(params)
            Alamofire.upload(multipartFormData: { (multipartformData) in
                let imageData = self.kImage.image!.jpegData(compressionQuality: 0.1)
                multipartformData.append(imageData!, withName: "profile_image", fileName: "\(self.getImageToUploadName()).jpeg", mimeType: "image/jpeg")
                for (key,value) in params {
                    multipartformData.append(value.data(using: .utf8)!, withName: key)
                }
            }, to: serviceName, method: .put, headers: CommonController.shared.getHeadersForAuthenticatedUser()) { (encodingResult) in
                switch encodingResult {
                    case .success(let uploadRequest, streamingFromDisk: _, streamFileURL: _):
                        uploadRequest.responseJSON(completionHandler: { (response) in
                            if response.result.isSuccess {
                                print(response)
                                let json = JSON(response.result.value!)
                                let message = json["message"].stringValue
                                if response.response?.statusCode == 200 {
                                    let jsonResponse = json["response"]
                                    let name = jsonResponse["username"].stringValue
                                    let imageName = jsonResponse["profile_image"].stringValue
                                    let email = jsonResponse["email"].stringValue
                                    let dob = jsonResponse["dob"].stringValue
                                    UserDefaults.standard.set(name, forKey: kConstant.localKeys.userName)
                                    UserDefaults.standard.set(imageName, forKey: kConstant.localKeys.imageURL)
                                    UserDefaults.standard.set(email, forKey: kConstant.localKeys.emailId)
                                    UserDefaults.standard.set(dob, forKey: kConstant.localKeys.dob)
                                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
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
                        })
                    case .failure(_) :
                        print("Errot")
                }
            }
        }
    }
    
 
    func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func changeProfileImageBtnPressed() {
        let alert = UIAlertController(title: "", message: "Please select an option.", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (alert) in
            self.handleCamera()
        }
        let galleryAction = UIAlertAction(title: "Photo Gallery", style: .default) { (alert) in
            self.photoGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func changePasswordBtnPressed() {
        let vc = ChangePasswordVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func handleDatePicker() {
         self.view.endEditing(true)
    }
    
    func getImageToUploadName() -> String {
        let date = Date()
        let dt = DateFormatter()
        dt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dt.string(from: date)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = image
            profileImage.stopAnimating()
            self.tableview.reloadData()
        }
        picker.dismiss(animated: true, completion: nil)
        if let updatedImage = self.profileImage.image?.updateImageOrientionUpSide() {
            kImage.image = updatedImage
        } else {
            kImage.image = self.profileImage.image
        }
    }
    
    func handleCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func photoGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

}

extension UIImage {
    
    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
}
