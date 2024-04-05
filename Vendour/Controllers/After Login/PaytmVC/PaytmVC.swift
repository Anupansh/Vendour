//
//  PaytmVC.swift
//  Vendour
//
//  Created by AppDev on 06/02/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class PaytmVC: UIViewController {

    @IBOutlet weak var paytmView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
