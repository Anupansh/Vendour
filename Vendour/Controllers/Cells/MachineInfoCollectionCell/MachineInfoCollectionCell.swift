//
//  MachineInfoCollectionCell.swift
//  Vendour
//
//  Created by AppDev on 09/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

protocol GoToMachineDetailsVC {
    func goToMachineDetailsVC()
}

class MachineInfoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var machineImage: UIImageView!
    @IBOutlet weak var operatorName: UILabel!
    @IBOutlet weak var machineUid: UILabel!
    @IBOutlet weak var swipeUpBtn: UIButton!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var machineImageTopConstraint: NSLayoutConstraint!
    
    var jumpToVCClosure : (() -> ())?
    
    var machineInfoDelegate : GoToMachineDetailsVC?
    override func awakeFromNib() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureDetected))
        swipeUp.direction = .up
        self.imageBtn.addGestureRecognizer(swipeUp)
        
//        leftArrow.isHidden = true
//        rightArrow.isHidden = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.machineImageTopConstraint.constant = 45
    }
    
    @objc func swipeGestureDetected() {
        jumpToVCClosure!()
    }
}
