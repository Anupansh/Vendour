//
//  HelpVC.swift
//  Vendour
//
//  Created by AppDev on 24/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import MessageUI

class HelpVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let nameArray = ["Contact Us","Terms & Privacy Policy","App Info"]
    var subject = "Feedback for Vendour"
    var toRecipients = ["contact@vendour.in"]
    @IBOutlet weak var tableview: UITableView! {
        didSet {
            tableview.delegate = self
            tableview.dataSource = self
            tableview.separatorStyle = .none
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "HelpCell", bundle: nil)
        tableview.register(nibName, forCellReuseIdentifier: "HelpCell")
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "HelpCell") as! HelpCell
        cell.nameLabel.text = nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
           sendMail()
        }
        else if indexPath.row == 1 {
            let vc = TermsAndConditionsVC()
            vc.cameFrom = .drawer
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = AppInfoVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    

    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension HelpVC : MFMailComposeViewControllerDelegate {
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let mc : MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(subject)
            mc.setToRecipients(toRecipients)
            self.present(mc, animated: true, completion: nil)
        }
        else {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Please login to mail first")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Mail Cancelled")
        case .saved:
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Mail Saved")
        case .sent:
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Mail Sent")
        case .failed:
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Mail sent failedte")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
