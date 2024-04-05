//
//  VendingScreenVC.swift
//  Vendour
//
//  Created by AppDev on 04/02/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import CoreBluetooth

class VendingScreenVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
   
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var vendingLabel: UILabel!
    @IBOutlet weak var hiddenButton: UIButton!
    @IBOutlet weak var machineImage: UIImageView!
    @IBOutlet weak var vendingLabelBottomConstraint: NSLayoutConstraint!
    
    let localPeripheral : CBPeripheral = CommonController.shared.peripheral!
    let ServiceUUID = CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455")
    let readCharactersticUUID = CBUUID(string: "49535343-1E4D-4BD9-BA61-23C647249616")
    let writeCharactersticUUID = CBUUID(string: "49535343-1E4D-4BD9-BA61-23C647249616")
    var centralManager : CBCentralManager!
    var readCharacterstic : CBCharacteristic?
    var writeCharacterstic : CBCharacteristic?
    var readEnabled : Bool = false
    var writeEnabled : Bool = false
    var messageToBeSent = "*"
    var currentIndex = 0
    var nextIsResponse : Bool?
    var bluetoothResponse = ""
    let localItemsArray = CommonController.shared.individualItemArray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CommonController.shared.selectionFlow == "0" {
            collectionView.isHidden = true
            vendingLabel.text = "Select a product to vend."
            vendingLabelBottomConstraint.constant = 40
        }
        else {
            vendingLabel.text = "\(localItemsArray[currentIndex].name!) is being vended"
        }
//        vendingLabel.text = "\(localItemsArray[currentIndex].name!) is being vended"
        let nibName = UINib(nibName: "SelectedProductCell", bundle: nil)
        hiddenButton.isHidden = true
        collectionView.register(nibName, forCellWithReuseIdentifier: "SelectedProductCell")
        centralManager = CBCentralManager(delegate: self, queue: nil)
        UIApplication.shared.isIdleTimerDisabled = true
        machineImage.image = UIImage.gifImageWithURL("https://cdn.vendour.in/media/machines/live/vendour/vendour_compressed.gif")
    }
    
    @IBAction func hiddenBtnPressed(_ sender: Any) {
        CommonController.shared.individualItemArray.removeAll()
        for controller in self.navigationController!.viewControllers {
            if controller.isKind(of: HomeScreen.self) {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return localItemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedProductCell", for: indexPath) as! SelectedProductCell
        if  localItemsArray[indexPath.row].isVended  != "" {
            cell.leftBar.backgroundColor = UIColor(red: 43/255, green: 168/255, blue: 115/255, alpha: 1)
            cell.rightBar.backgroundColor = UIColor(red: 43/255, green: 168/255, blue: 115/255, alpha: 1)
            if localItemsArray[indexPath.row].isVended  == "True" {
                cell.borderView.backgroundColor = UIColor(red: 43/255, green: 168/255, blue: 115/255, alpha: 1)
                cell.tickCrossImage.image = UIImage(named: "greenTickColoured")
            }
            else {
                cell.borderView.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                cell.tickCrossImage.image = UIImage(named: "red_cross")
            }
        }
        else {
            cell.borderView.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
            cell.leftBar.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
            cell.rightBar.backgroundColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
            cell.tickCrossImage.image = UIImage()
        }
        cell.productImage.contentMode = .scaleAspectFit
        cell.productImage.sd_setImage(with: URL(string: localItemsArray[indexPath.row].imageURL!), completed: nil)
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if localItemsArray.count == 3 {
            return CGSize(width: UIScreen.main.bounds.width / 3, height: 130)
        }
        else if localItemsArray.count == 2 {
            return CGSize(width: UIScreen.main.bounds.width / 2, height: 130)
        }
        else {
            return CGSize(width: UIScreen.main.bounds.width, height: 130)
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        CommonController.shared.individualItemArray.removeAll()
        for controller in self.navigationController!.viewControllers {
            if controller.isKind(of: MachineDetails.self) {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
}

extension VendingScreenVC : CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Bluetooth in unknown state")
        case .resetting:
            print("Bluetooth in resetting state")
        case .unsupported:
            print("Unsupported state")
        case .unauthorized:
            print("Unauthorised")
        case .poweredOff:
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Please turn bluetooth on to vend products")
        case .poweredOn:
//            self.localPeripheral.delegate = self
//            self.localPeripheral.discoverServices([self.ServiceUUID])
            self.decodeMessageToBeSent()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        for service in services {
            localPeripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characterstics = service.characteristics else {return}
        for characterstic in characterstics {
            if characterstic.uuid == readCharactersticUUID {
                readCharacterstic = characterstic
                peripheral.setNotifyValue(true, for: readCharacterstic!)
                readEnabled = true
            }
            if characterstic.uuid == writeCharactersticUUID {
                writeCharacterstic = characterstic
                peripheral.setNotifyValue(true, for: writeCharacterstic!)
                writeEnabled = true
            }
            if readEnabled && writeEnabled {
                localPeripheral.writeValue(Data(messageToBeSent.utf8), for: writeCharacterstic!, type: CBCharacteristicWriteType.withResponse)
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == writeCharacterstic {
            let stringData = String(data: characteristic.value!, encoding: String.Encoding.utf8)
            if stringData == "*VCN#" || stringData == "*VS#" {
                self.handleBluetoothResponse(recievedString: stringData!)
                print("Hardware Response", stringData!)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        peripheral.readValue(for: characteristic)
    }
    func handleBluetoothResponse(recievedString : String) {
//        if recievedString == "*" {
//            nextIsResponse = true
//        }
//        else if recievedString == "#" {
//            self.checkProduct()
//            return
//        }
//        else {
//            if nextIsResponse == true {
//                bluetoothResponse = recievedString
//                nextIsResponse = false
//            }
//        }
        bluetoothResponse = recievedString
        self.checkProduct()
    }
    
    func checkProduct() {
        if CommonController.shared.selectionFlow == "0" {
            vendingLabel.text = "Vending complete, tap anywhere"
            hiddenButton.isHidden = false
        }
        else {
            if bluetoothResponse == "*VS#" {
                localItemsArray[currentIndex].isVended = "True"
            }
            else {
                localItemsArray[currentIndex].isVended = "False"
            }
            currentIndex = currentIndex + 1
            if currentIndex == localItemsArray.count {
                vendingLabel.text = "Vending Complete,tap anywhere "
                hiddenButton.isHidden = false
            }
            else {
                vendingLabel.text = "\(localItemsArray[currentIndex].name!) is being vended"
            }
            collectionView.reloadData()
        }
    }
    
    func decodeMessageToBeSent() {
        if CommonController.shared.selectionFlow == "0" {
            messageToBeSent.append("NK")
//            for i in 0..<localItemsArray.count {
//                let intCost = Int(localItemsArray[i].cost!)! * 100
//                let stringCostInPaise = "\(intCost) "
//                messageToBeSent.append(stringCostInPaise)
//            }
            let intCost = Int(CommonController.shared.noSelectionFlowAmount!)! * 100
            messageToBeSent.append("\(intCost) ")
        }
        else {
            for i in 0..<localItemsArray.count {
                let intCost = Int(localItemsArray[i].cost!)! * 100
                let stringCostInPaise = "\(intCost):"
                messageToBeSent.append(stringCostInPaise)
                let stringCellNumber = "\(localItemsArray[i].cellNumber!) "
                messageToBeSent.append(stringCellNumber)
            }
        }
        let kUserId = UserDefaults.standard.string(forKey: kConstant.localKeys.userId)
        messageToBeSent.append("\(kUserId!):")
        let kTransactionId = CommonController.shared.transactionId
        messageToBeSent.append("\(kTransactionId!)")
        if CommonController.shared.machineHardwareType == "Normal" {
            messageToBeSent.append("#")
        }
        else {
            let kCrypto = CommonController.shared.crypto
            messageToBeSent.append(";\(kCrypto!)#")
        }
        print("Message to be sent",messageToBeSent)
        self.localPeripheral.delegate = self
        self.localPeripheral.discoverServices([self.ServiceUUID])
    }
}
