//
//  TermsAndConditionsVC.swift
//  Vendour
//
//  Created by AppDev on 31/12/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit

enum CameFrom {
    case signup
    case drawer
}

class TermsAndConditionsVC: UIViewController {

    @IBOutlet var myWebView : UIWebView!
    @IBOutlet var btnBack : UIButton!
    var cameFrom : CameFrom?
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://vendour.in/terms-and-privacy-policy/")
        let requestObject = URLRequest(url: url!)
        myWebView.loadRequest(requestObject)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func btnBackActn(){
        if cameFrom! == .drawer {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }

}
