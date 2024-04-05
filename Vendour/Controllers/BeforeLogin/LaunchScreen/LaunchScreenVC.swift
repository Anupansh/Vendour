//
//  LaunchScreenVC.swift
//  Vendour
//
//  Created by AppDev on 31/12/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import Alamofire
import SWRevealViewController

class LaunchScreenVC: UIViewController {

    
    var window: UIWindow?
    var nav = UINavigationController()

    override func viewDidLoad() {
        super.viewDidLoad()
        callApi()
        // Do any additional setup after loading the view.
    }
    
    func callApi() {
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/version/updates/")
        
        let requestParam : [String : Any] = ["type" : kConstant.Constants.deviceType , "version":kConstant.Constants.appVersion ]
        print("Check updates API", serviceName)
        print(requestParam)
        Alamofire.request(serviceName, method: .post, parameters: requestParam, encoding: JSONEncoding.default, headers: CommonController.shared.getHeaders()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = response.result.value as? [String:Any]
                print(json)
                if response.response?.statusCode == 200 {
                    let response = json!["response"] as? [String:Any]
                    let message = json!["message"] as? String
                //    print("REsponse is",response)
                    let preLoginBlock = response!["pre_login_block"] as? String
                    if preLoginBlock == "1" {
                        let alert = UIAlertController(title: "Vendour", message: message, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Proceed", style: .default, handler: { (action) in
                            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1024941703"),
                                UIApplication.shared.canOpenURL(url){
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        if UserDefaults.standard.value(forKey: kConstant.localKeys.authToken) != nil{
                            let  vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                            self.navigationController?.viewControllers = [vc]
                        }else{
                            let   vc = Login()
                            self.navigationController?.viewControllers = [vc]
                        }
                        
                    }
                }
            }
            else {
                CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "No Internet Connection")
            }
        }
//        Alamofire.request(serviceName, method: .post, parameters: requestParam, encoding: JSONEncoder.default , headers : CommonController.shared.getHeaders()).responseJSON{
//            response in
//            print(response.result.value as AnyObject)
//            guard response.result.isSuccess else {
//                print("Error while fetching data : \(String(describing: response.result.error))")
//                return
//            }
//            guard let dict = response.result.value as? NSDictionary else {
//                print("Malformed data received ")
//                return
//            }
//        }
    }
}
