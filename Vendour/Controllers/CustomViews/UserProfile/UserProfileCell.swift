//
//  UserProfileCell.swift
//  Vendour
//
//  Created by AppDev on 22/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

protocol BackToVC {
    func backBtnPressed()
    func changeProfileImageBtnPressed()
    func changePasswordBtnPressed()
    func saveBtnPressed(name : String, dob : String, email : String)
    func handleDatePicker()
}

class UserProfileCell: UITableViewCell {

    @IBOutlet weak var pushNotificationSwitch: UISwitch!
    @IBOutlet weak var dobTf: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTf: SkyFloatingLabelTextField!
    @IBOutlet weak var nameTf: SkyFloatingLabelTextField!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    var delegate : BackToVC?
    let datePicker = UIDatePicker()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 65.0
        profileImage.layer.masksToBounds = true
        profileImage.clipsToBounds = true
        setupDobTf()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupDobTf() {
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleToolbarDone))
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleToolbarCancel))
        toolbar.setItems([doneBtn, cancelBtn], animated: true)
        dobTf.inputView = datePicker
        dobTf.inputAccessoryView = toolbar
    }
    
    @objc func handleToolbarDone() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dobTf.text = formatter.string(from: datePicker.date)
        delegate?.handleDatePicker()
    }
    
    @objc func handleToolbarCancel() {
        delegate?.handleDatePicker()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        delegate?.backBtnPressed()
    }
    
    @IBAction func changeProfileImageBtnPressed(_ sender: Any) {
        delegate?.changeProfileImageBtnPressed()
    }
    
    @IBAction func changePasswordBtnPressed(_ sender: Any) {
        delegate?.changePasswordBtnPressed()
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        delegate?.saveBtnPressed(name: nameTf.text!, dob: dobTf.text!, email: emailTf.text!)
    }
    
}
