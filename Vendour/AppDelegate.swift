//
//  AppDelegate.swift
//  Vendour
//
//  Created by AppDev on 05/12/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps
import IQKeyboardManagerSwift
import SWRevealViewController
import Firebase
import Crashlytics
import Fabric

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var nav = UINavigationController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
//        let vc = MachineDetailsVC()
         let vc = LaunchScreenVC()
//        let vc = NoSelectionFlowVC()
        self.nav.viewControllers = [vc]
        self.nav.isNavigationBarHidden = true
        self.window?.rootViewController = self.nav
        self.window?.makeKeyAndVisible()
        GMSServices.provideAPIKey(kConstant.Constants.gmsMapKey)
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func checkUpdates(){
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/version/updates/")
        
        let requestParam : [String : Any] = ["type" : "ios" , "version":"1.0" ]
      //  CommonController.shared.showHud(title: "", sender: self.view)
        Alamofire.request(serviceName, method: .post, parameters: requestParam, encoding: JSONEncoding.default , headers : CommonController.shared.getHeaders()).responseJSON{
            response in
            
            
           // CommonController.shared.hideHud() 
            guard response.result.isSuccess else {
                //CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Error while fetching data ")
                return
            }
            guard let dict = response.result.value as? NSDictionary else {
                return
            }
            //                    guard let status = dict["status"] as? Int else{return}
            //                    if  Int(status) == 200 {
            //                        print(dict)
            //
            //
            //                    }else if Int(status) == 204{
            //                        let message = (dict.object(forKey: "Message") as! String)
            //                        print(message)
            //
            //                    }else if Int(status) == 401{
            //                        let message = (dict.object(forKey: "Message") as! String)
            //                    }
        }
    }
    
    
  


}

