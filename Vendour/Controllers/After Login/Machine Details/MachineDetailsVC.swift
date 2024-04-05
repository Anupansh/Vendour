//
//  MachineDetailsVC.swift
//  Vendour
//
//  Created by AppDev on 02/01/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import Razorpay
import SimplOneClick

class MachineDetailsVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {

    // MARK :- OUTLETS AND VARIABLES
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var payView: UIView!
    @IBOutlet weak var payLabel: UILabel!
    @IBOutlet weak var numberOfItemsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cartImage: UIImageView!
    @IBOutlet weak var selectedItemsCollectionView: UICollectionView!{
        didSet{
            selectedItemsCollectionView.delegate = self
            selectedItemsCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var walletBtn: UIButton!
    @IBOutlet weak var paytmBtn: UIButton!
    @IBOutlet weak var sodexoBtn: UIButton!
    @IBOutlet weak var otherPaymentsBtn: UIButton!
    @IBOutlet weak var hiddenView: UIView!
    @IBOutlet weak var walletBalanceLabel: UILabel!
    @IBOutlet weak var greenTick: UIImageView!
    @IBOutlet weak var simplBtn: UIButton!
    @IBOutlet weak var vendourWallet: UIImageView!
    @IBOutlet weak var partialPaymentView: UIView! {
        didSet {
            partialPaymentView.layer.borderColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1).cgColor
            partialPaymentView.layer.cornerRadius = 3
            partialPaymentView.layer.borderWidth = 1.0
            partialPaymentView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var partialPaymentLabel: UILabel!
    @IBOutlet weak var partialPaymentViewheightContraint: NSLayoutConstraint!
    @IBOutlet weak var paytmBtnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    
    var numberOfItems = 0
    var machineID = ""
    var machineDetails = [MachineDetails]()
    var currency = "Rs"
    var infoItemIndexpath : Int?
    var infoBtnPressed : Bool = false
    var pressedItemIndexPath : Int?
    var swipeUpGesture = UISwipeGestureRecognizer()
    var swipeDownGesture = UISwipeGestureRecognizer()
    var totalCost = 0.0
    var selectedItemsArray = [MachineDetails]()
    var razorpay : Razorpay!
    var individualItemArray = [MachineDetails]()
    var selectionFlow = ""
    var walletUsed : Bool = false
    var intWalletBalance : Int?
    var doubleWalletBalance : Double?
    var razorpayTransactionId = ""
    var systemTimeStamp = ""
    var systemDate = ""
    var productArray = [[String : Any]]()
    var transactionId = ""
    var orderId = ""
    var locationManager = CLLocationManager()
    var user = GSUser()
    var simplTransactionToken = ""
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var simplProductArray = [[String : Any]]()
    var simplTransactionId = ""
    var paytmOrderId = ""
    var inventoryMap = [String : [String]]()
    var mappingDone = false
    var mainApiMessageShown = false
    var infoIndexPath : Int?
    var paytmTransactionId : String?
    var remainderBalance : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        let nibName = UINib(nibName: "MachineDetailsCollectionCell", bundle : nil)
        let itemInfoNibName = UINib(nibName: "ItemInfoCollectionCell", bundle: nil)
        let selectedItemNibName = UINib(nibName: "SelectedItemInfoCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "MachineDetailsCollectionCell")
        collectionView.register(itemInfoNibName, forCellWithReuseIdentifier: "ItemInfoCollectionCell")
        selectedItemsCollectionView.register(selectedItemNibName, forCellWithReuseIdentifier: "SelectedItemInfoCell")
        GSManager.initialize(withMerchantID: "8c07e5c7017f3bec5604dda4a40e2c17")
        GSManager.enableSandBoxEnvironment(true)
        razorpay = Razorpay.initWithKey("rzp_test_8aO2sKK7TOHACH", andDelegate: self)
//        getBalanceApiCalled()
        simplBtn.isHidden = true
        user = GSUser(phoneNumber: UserDefaults.standard.string(forKey: kConstant.localKeys.mobNumber)!, email: UserDefaults.standard.string(forKey: kConstant.localKeys.emailId)!)
        setupUI()
        apiCall()
        checkEligibilityForSimpl()
        if CommonController.shared.machineHardwareType == "Security" || CommonController.shared.machineHardwareType == "Crypto" {
            self.getTimeApiCalled()
        }
        CommonController.shared.hideHud()
        payView.isHidden = true
        self.payLabel.isHidden = true
        self.bottomView.isHidden = true
        self.partialPaymentView.isHidden = true
        self.partialPaymentLabel.isHidden = true
        self.partialPaymentViewheightContraint.constant = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        priceLabel.text = "\(currency)\(totalCost)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = true
//        CommonController.shared.individualItemArray.removeAll()
        self.individualItemArray.removeAll()
        self.productArray.removeAll()
//        CommonController.shared.individualItemArray.removeAll()
        self.walletUsed = false
        walletBtn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        greenTick.isHidden = true
        walletBtn.isUserInteractionEnabled = true
        self.collectionView.reloadData()
        self.selectedItemsCollectionView.reloadData()
        self.getBalanceApiCalled()
        self.partialPaymentView.isHidden = true
        self.partialPaymentLabel.isHidden = true
        self.partialPaymentViewheightContraint.constant = 0
    }
    
    // COLLECTION VIEW DELEGATES AND METHODS
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == selectedItemsCollectionView {
            return selectedItemsArray.count
        }
        else {
            return machineDetails.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == selectedItemsCollectionView {
        let totalCellWidth = 100 * selectedItemsArray.count
        let totalSpacingWidth = 10 * (selectedItemsArray.count - 1)
        
        let leftInset = (self.view.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
            return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        }
        else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == selectedItemsCollectionView {
            let cell = selectedItemsCollectionView.dequeueReusableCell(withReuseIdentifier: "SelectedItemInfoCell", for: indexPath) as! SelectedItemInfoCell
            cell.itemImage.contentMode = .scaleAspectFit
            cell.itemImage.sd_setImage(with: URL(string: selectedItemsArray[indexPath.row].imageURL!), completed: nil)
            cell.quantityLabel.text = currency + selectedItemsArray[indexPath.row].cost!
            cell.numberOfItemsLabel.text = String(selectedItemsArray[indexPath.row].currentQuantity)
            cell.minusClosure = {
                if cell.numberOfItemsLabel.text != "0" {
                    let count = Int(cell.numberOfItemsLabel!.text!)
                    let newValue = count! - 1
                    cell.numberOfItemsLabel.text = "\(newValue)"
//                    self.selectedItemsArray[indexPath.row].currentQuantity = newValue
                    self.machineDetails[self.selectedItemsArray[indexPath.row].machineDetailsIndex!].currentQuantity = newValue
                    self.numberOfItems -= 1
                    self.numberOfItemsLabel.text = "\(self.numberOfItems) items"
                    self.totalCost -= Double(self.selectedItemsArray[indexPath.row].cost!)!
                    self.priceLabel.text = "\(self.currency)\(self.totalCost)"
                    if newValue == 0 {
                        for i in 0..<self.selectedItemsArray.count {
                            if self.selectedItemsArray[i].currentQuantity == 0 {
                                self.selectedItemsArray.remove(at: i)
                                break
                            }
                        }
                    }
                    if self.numberOfItems == 0 {
                        self.payView.isHidden = true
                        self.payLabel.isHidden = true
                        self.bottomView.isHidden = true
                        self.handleSwipeDownGesture()
                        self.collectionView.reloadData()
                    }
                    self.checkEligibilityForSimpl()
                    self.selectedItemsCollectionView.reloadData()
                }
                else {
                    
//                    print("Cannot be less than 0")
                }
            }
            cell.plusClosure = {
                if self.numberOfItems == 3 {
                    self.errorMessage(message: "You can select maximum 3 items")
                }
                else {
                    let currentQuantity = cell.numberOfItemsLabel.text!
                    if Int(currentQuantity)! < Int(self.machineDetails[indexPath.row].maxQuantity!)! {
                        let count = Int(cell.numberOfItemsLabel!.text!)
                        let newValue = count! + 1
                        cell.numberOfItemsLabel.text = "\(newValue)"
                    //                    self.selectedItemsArray[indexPath.row].currentQuantity = newValue
                        self.machineDetails[self.selectedItemsArray[indexPath.row].machineDetailsIndex!].currentQuantity = newValue
                        self.numberOfItems += 1
                        if newValue == 1 {
                            self.selectedItemsArray.append(self.machineDetails[indexPath.row])
                        }
                        self.numberOfItemsLabel.text = "\(self.numberOfItems) items"
                        self.totalCost += Double(self.selectedItemsArray[indexPath.row].cost!)!
                        self.priceLabel.text = "\(self.currency)\(self.totalCost)"
                        self.checkEligibilityForSimpl()
                    }
                    else {
                        self.errorMessage(message: "Maximum limit reached")
                    }
                }
            }

            cell.numberOfItemsLabel.text = String(selectedItemsArray[indexPath.row].currentQuantity)
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MachineDetailsCollectionCell", for: indexPath) as! MachineDetailsCollectionCell
            let infoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemInfoCollectionCell", for: indexPath) as! ItemInfoCollectionCell
//            cell.infoBtn.isHidden = false
            if machineDetails[indexPath.row].shouldShowInfoBtn {
                cell.infoBtn.isHidden = false
            }
            else {
                cell.infoBtn.isHidden = true
            }
            infoCell.delegate = self
//            if cell.numberOfItemsLabel.text == "0" {
//                cell.stackView.isHidden = true
//            }
//            else {
//                cell.stackView.isHidden = false
//            }
            if machineDetails[indexPath.row].currentQuantity == 0 {
                cell.stackView.isHidden = true
            }
            else {
                cell.stackView.isHidden = false
            }
            if machineDetails[indexPath.row].typeofCell == .infoCell {
                infoCell.nameLabel.text = machineDetails[indexPath.row].name
                infoCell.ingredientImage.contentMode = .scaleAspectFit
                infoCell.ingredientImage.sd_setImage(with: URL(string: machineDetails[indexPath.row].ingredientImage!), completed: nil)
                return infoCell
            }
            else {
                cell.costLabel.text = currency + machineDetails[indexPath.row].cost!
                cell.productImage.contentMode = .scaleAspectFit
                cell.productImage.sd_setImage(with: URL(string: machineDetails[indexPath.row].imageURL!), completed: nil)
                cell.nameLabel.text = machineDetails[indexPath.row].name
                cell.quantityLabel.text = machineDetails[indexPath.row].quantity! + machineDetails[indexPath.row].unit!
                cell.numberOfItemsLabel.text = String(machineDetails[indexPath.row].currentQuantity)
            }
            cell.plusClosure = {
                if self.numberOfItems == 3 {
                    self.errorMessage(message: "You can select 3 items at a time")
                }
                else {
                    
                    let currentQuantity = cell.numberOfItemsLabel.text!
                    if cell.numberOfItemsLabel.text == "0" {
                        cell.stackView.isHidden = false
                    }
                    if Int(currentQuantity)! < Int(self.machineDetails[indexPath.row].maxQuantity!)! {
                       let count = Int(cell.numberOfItemsLabel!.text!)
                        let newValue = count! + 1
                        cell.numberOfItemsLabel.text = "\(newValue)"
                        self.machineDetails[indexPath.row].currentQuantity = newValue
                        self.machineDetails[indexPath.row].machineDetailsIndex = indexPath.row
                        if newValue == 1 {
                            self.selectedItemsArray.append(self.machineDetails[indexPath.row])
                        }
                        self.numberOfItems += 1
                        self.numberOfItemsLabel.text = "\(self.numberOfItems) items"
                        self.totalCost += Double(self.machineDetails[indexPath.row].cost!)!
                        self.priceLabel.text = "\(self.currency)\(self.totalCost)"
                        self.checkEligibilityForSimpl()
                        self.payView.isHidden = false
                        self.payLabel.isHidden = false
                        self.bottomView.isHidden = false
//                        self.cartImage.isHidden = false
                    }
                    else {
                        self.errorMessage(message: "Maximum limit reached.")
                        cell.stackView.isHidden = true
                    }
                }
            }
            cell.minusClosure = {
                if cell.numberOfItemsLabel.text != "0"
                {
                    if cell.numberOfItemsLabel.text == "1" {
                        cell.stackView.isHidden = true
                    }
                    let count = Int(cell.numberOfItemsLabel!.text!)
                    let newValue = count! - 1
                    cell.numberOfItemsLabel.text = "\(newValue)"
                    self.machineDetails[indexPath.row].currentQuantity = newValue
                    if newValue == 0 {
                        for i in 0..<self.selectedItemsArray.count {
                            if self.selectedItemsArray[i].currentQuantity == 0 {
                                self.selectedItemsArray.remove(at: i)
                                break
                            }
                        }
                    }
                    self.numberOfItems -= 1
                    self.numberOfItemsLabel.text = "\(self.numberOfItems) items"
                    self.totalCost -= Double(self.machineDetails[indexPath.row].cost!)!
                    self.priceLabel.text = "\(self.currency)\(self.totalCost)"
                    if self.numberOfItems == 0 {
                        self.payView.isHidden = true
                        self.payLabel.isHidden = true
                        self.bottomView.isHidden = true
                    }
                    else {
                        self.bottomView.isHidden = false
                        self.payLabel.isHidden = false
                        self.payView.isHidden = false
                    }
                    self.checkEligibilityForSimpl()
//                    self.bottomView.isHidden = false
                }
                else {
//                    print("Cannot be less than 0")
                }
            }
            cell.infoClosure = {
                for i in 0..<self.machineDetails.count {
                    self.machineDetails[i].shouldShowInfoBtn = true
                }
                self.infoBtnPressed = true
                let indexPath = self.collectionView.indexPath(for: cell)
                if indexPath?.row == (self.machineDetails.count - 1) {
                    self.infoItemIndexpath = (indexPath?.row)! + 1
                }
                else if ((indexPath?.row)! % 2) == 0 {
                    self.infoItemIndexpath = (indexPath?.row)! + 2
                }
                else {
                    self.infoItemIndexpath = (indexPath?.row)! + 1
                }
                self.pressedItemIndexPath = indexPath?.row
                self.infoIndexPath = indexPath?.row
                self.machineDetails[indexPath!.row].shouldShowInfoBtn = false
                self.apiCall()
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == selectedItemsCollectionView {
            return CGSize(width: 100, height: 150)
        }
        else {
            let size : CGSize?
            if machineDetails[indexPath.row].typeofCell == .normalCell {
                size = CGSize(width: self.view.frame.width/2 - 24, height: 270.0)
            }
            else {
                size = CGSize(width: self.view.frame.width - 32, height: 250.0)
            }
            return size!
        }
    }
    

    
    // METHODS TO HANDLE SWIPE GESTURES
    
    
    @objc func handleSwipeUpGesture() {
        bottomViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        cartImage.isHidden = false
        hiddenView.isHidden = false
        payLabel.text = ""
        selectedItemsCollectionView.reloadData()
        selectedItemsCollectionView.isHidden = false
    }
    
    @objc func handleSwipeDownGesture() {
        bottomViewBottomConstraint.constant = -460
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        cartImage.isHidden = true
        payLabel.text = "Pay"
        hiddenView.isHidden = true
        collectionView.reloadData()
        selectedItemsCollectionView.isHidden = true
    }
    
    @objc func handleHiddenView() {
        bottomViewBottomConstraint.constant = -460
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        cartImage.isHidden = true
        payLabel.text = "Pay"
        hiddenView.isHidden = true
        collectionView.reloadData()
        selectedItemsCollectionView.isHidden = true
    }
    
    @IBAction func paytmBtnPressed(_ sender: Any) {
        if totalCost == 0 {
            self.errorMessage(message: "Please select items first")
        }
        else {
//            if CommonController.shared.selectionFlow != "0" {
                getIndividualItemArray()
                getProductArray()
//            }
            if walletUsed == true {
                CommonController.shared.amountByWallet = doubleWalletBalance
                CommonController.shared.amountByGateway = totalCost - doubleWalletBalance!
                self.walletChargeApiCalled(for: "paytm")
            }
            else {
                CommonController.shared.amountByGateway = totalCost
            }
            getChecksumApiCalled()
        }
    }
    
    @IBAction func payBtnPressed(_ sender: Any) {
        bottomViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        cartImage.isHidden = false
        payLabel.text = ""
        hiddenView.isHidden = false
        selectedItemsCollectionView.reloadData()
        selectedItemsCollectionView.isHidden = false
    }
    
    // BUTTON ACTIONS
    
    
    
    @IBAction func walletBtnPressed(_ sender: Any) {
        if totalCost == 0 {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Please add items first")
        }
        else {
            if intWalletBalance == 0 {
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Empty Wallet Balance")
            }
            else {
                if doubleWalletBalance! < totalCost {
                    let toBePaidByGateway = String(totalCost - doubleWalletBalance!)
//                    CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Pay \(currency + toBePaidByGateway) more using another payment method")
                    partialPaymentView.isHidden = false
                    partialPaymentLabel.isHidden = false
                    partialPaymentViewheightContraint.constant = 20
                    partialPaymentLabel.text = "Pay \(currency + toBePaidByGateway) more using another payment method"
                    walletBtn.layer.borderColor = UIColor.init(red: 43/255, green: 168/255, blue: 155/268, alpha: 1).cgColor
                    CommonController.shared.amountByWallet = doubleWalletBalance
                    CommonController.shared.amountByGateway = Double(toBePaidByGateway)
                    walletUsed = true
                    greenTick.isHidden = false
                    walletBtn.isUserInteractionEnabled = false
                }
                else {
                    CommonController.shared.amountByWallet = totalCost
                    CommonController.shared.amountByGateway = 0
                    walletUsed = true
//                    if CommonController.shared.selectionFlow != "0" {
                        self.getIndividualItemArray()
                        self.getProductArray()
//                    }
                    self.walletChargeApiCalled(for: "")
                }
            }
        }
    }
    
    @IBAction func sodexoBtnPressed(_ sender: Any) {
        if totalCost == 0 {
            self.errorMessage(message: "Please select items first")
        }
        else {
//            if CommonController.shared.selectionFlow != "0" {
                getIndividualItemArray()
//            }
            if walletUsed == true {
                CommonController.shared.amountByWallet = doubleWalletBalance
                CommonController.shared.amountByGateway = totalCost - doubleWalletBalance!
            }
            else {
                CommonController.shared.amountByGateway = totalCost
            }
            let vc = SodexoPaymentVC()
            vc.walletUsed = self.walletUsed
            if walletUsed {
                self.walletChargeApiCalled(for: "sodexo")
                vc.amount = String(CommonController.shared.amountByGateway!)
            }
            else {
                vc.amount = String(totalCost)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func otherPaymentBtnPressed(_ sender: Any) {
        if totalCost == 0 {
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Please select items first")
        }
        else {
            if walletUsed == true {
                self.walletChargeApiCalled(for: "razorpay")
            }
            if CommonController.shared.selectionFlow != "0" {
                self.getIndividualItemArray()
                self.getProductArray()
            }
            var amountToBePaid = 0.0
            if walletUsed == true {
                amountToBePaid = CommonController.shared.amountByGateway!
            }
            else {
                amountToBePaid = totalCost
            }
            let options : [String : Any] = [
                "amount" : amountToBePaid * 100,
                "prefill" : [
                    "contact" : UserDefaults.standard.string(forKey: kConstant.localKeys.mobNumber),
                    "email" : UserDefaults.standard.string(forKey: kConstant.localKeys.emailId)
                ]
            ]
            print("Razorpay calling parameters", options)
            razorpay.open(options, displayController: self)
        }
    }
    
    @IBAction func simplBtnPressed(_ sender: Any) {
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted{
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Please enable location in Settings -> Vendour -> Location to use simpl")
        }
        else {
            if totalCost == 0 {
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Please select items first")
            }
            else {
                if walletUsed == false {
                    CommonController.shared.amountByGateway = totalCost
                }
                else {
                    self.walletChargeApiCalled(for: "simpl")
                }
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                self.handleSimplTransaction()
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // HELPER FUNCTIONS

    
    func handleSimplTransaction() {
        var amountToBePaid : Double?
        if walletUsed == true {
            amountToBePaid = CommonController.shared.amountByGateway
        }
        else {
            amountToBePaid = totalCost
        }
        let transaction = GSTransaction(user: user, amountInPaise: Int(amountToBePaid! * 100))
        GSManager.shared().authorizeTransaction(transaction) { (response, error) in
            if error != nil {
                if self.walletUsed == true {
                    self.walletRefundApi()
                }
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Unable to procced using Simpl. Please try any other method")
            }
            else {
                self.simplTransactionToken = response!["transaction_token"] as! String
                self.simplTransactionCaptureApi()
            }
        }
    }
    
    func checkEligibilityForSimpl() {
        var params : [String : Any] = [:]
        params["transaction_amount_in_paise"] = String(totalCost * 100)
        user.headerParams = params
        GSManager.shared().checkApproval(for: user) {
            (approved, firstTransaction, text, error) in
            print(approved)
            self.simplBtn.isHidden = !approved
        }
    }

    
    func simplTransactionCaptureApi() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/simpl/transaction/capture/")
//        if CommonController.shared.selectionFlow != "0" {
            self.getIndividualItemArray()
            self.getSimplProductArray()
//        }
        self.getProductArray()
        let params : [String : Any] = [
            "transaction_token" : simplTransactionToken,
            "amount_in_paise" : CommonController.shared.amountByGateway! * 100,
            "Items" : simplProductArray,
            "shipping_address" : [
                "longitude" : self.longitude,
                "latitude" : self.latitude
            ],
            "billing_address" : [
                "longitude" : self.longitude,
                "latitude" : self.latitude
            ],
            "machine_id" : Int(machineID)!
        ]
        print("Simpl Transaction capture API", serviceName)
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"]
                    self.simplTransactionId = jsonResponse["transaction_id"].stringValue
                    if self.walletUsed == true {
                        self.transactionCaptureApi(otherMethodUsed: "wallet+simpl")
                    }
                    else {
                        self.transactionCaptureApi(otherMethodUsed: "simpl")
                    }
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
        }
    }
    
    func apiCall() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceURL = getFullServiceUrl(serviceName: "/api/vendour/v1/inventory/\(machineID)/")
        Alamofire.request(serviceURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if self.mainApiMessageShown == false {
                    print("Service Name",serviceURL)
                    print(json)
                    self.mainApiMessageShown = true
                }
                self.currency = json["currency"].stringValue
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let finalResponse = json["response"] as JSON
                    if self.infoBtnPressed {
                        self.machineDetails.removeAll()
                        for i in 0..<(finalResponse.count + 1) {
                            if i < self.infoItemIndexpath! {
                                let singleMachineDetails = MachineDetails.init(with: finalResponse[i])
                                self.machineDetails.append(singleMachineDetails)
                            }
                            else if i > self.infoItemIndexpath! {
                                let singleMachineDetails = MachineDetails.init(with: finalResponse[i-1])
                                self.machineDetails.append(singleMachineDetails)
                            }
                            else {
                                let singleMachineDetails = MachineDetails.init(with: finalResponse[self.pressedItemIndexPath!])
                                singleMachineDetails.typeofCell = .infoCell
                                self.machineDetails.append(singleMachineDetails)
                            }
                        }
                        if let kInfoindexpath = self.infoIndexPath {
                            self.machineDetails[kInfoindexpath].shouldShowInfoBtn = false
                        }
                    }
                    else {
                        self.machineDetails.removeAll()
                        for i in 0..<finalResponse.count {
                            let singleMachineDetails = MachineDetails.init(with: finalResponse[i])
                            self.machineDetails.append(singleMachineDetails)
                        }
                    }
                    if !self.mappingDone {
                        self.performItemMapping()
                    }
                    self.collectionView.reloadData()
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
                    self.present(alert, animated: true, completion: nil)                }
                else {
                    self.errorMessage(message: message)
                }
            }
            else {
                self.errorMessage(message: "No Internet Connection")
            }
            CommonController.shared.hideHud()
        }
    }
    
    func performItemMapping() {
        let productIdArray = Array(inventoryMap.keys)
        var i = 0
        for singleMachine in machineDetails {
            if productIdArray.contains(singleMachine.productID!) {
                singleMachine.cellNumber = inventoryMap[singleMachine.productID!]![0]
                singleMachine.maxQuantity = String(inventoryMap[singleMachine.productID!]!.count)
            }
            else {
                machineDetails.remove(at: i)
                i -= 1
            }
            i += 1
        }
        self.mappingDone = true
    }
    
    func getIndividualItemArray() {
        var i = 0
        while(i < numberOfItems) {
            if selectedItemsArray[i].currentQuantity == 3 {
                individualItemArray.append(selectedItemsArray[i])
                individualItemArray.append(selectedItemsArray[i])
                individualItemArray.append(selectedItemsArray[i])
                i += 1
                numberOfItems -= 2
            }
            else if selectedItemsArray[i].currentQuantity == 2 {
                individualItemArray.append(selectedItemsArray[i])
                individualItemArray.append(selectedItemsArray[i])
                i += 1
                numberOfItems -= 1
            }
            else {
                individualItemArray.append(selectedItemsArray[i])
                i += 1
            }
        }
        CommonController.shared.individualItemArray = self.individualItemArray
    }
    
    func errorMessage(message : String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func walletChargeApiCalled(for otherPaymentMode : String) {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/charge/wallet/")
        var params : [String : Any] = [:]
        if otherPaymentMode == "" {
            params = [
                "machine_id" : CommonController.shared.machineId,
                "payment_mode" : "wallet",
                "amount" : [
                    "paid_by_personal_wallet" : Float(totalCost)
                ]
            ]
        }
        else {
            params = [
                "machine_id" : CommonController.shared.machineId,
                "payment_mode" : "wallet",
                "amount" : [
                    "paid_by_personal_wallet" : Float(CommonController.shared.amountByWallet!),
                    "paid_by_gateway" : Float(CommonController.shared.amountByGateway!),
                    "gateway_payment_mode" : otherPaymentMode
                ]
            ]
        }
        print("Wallet Charge API",serviceName)
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"]
                    if otherPaymentMode == "" {
                        CommonController.shared.walletTransactionId = jsonResponse["wallet_transaction_id"].stringValue
                        self.transactionCaptureApi(otherMethodUsed: "wallet")
                    }
                    else {
                        CommonController.shared.walletTransactionId = jsonResponse["wallet_transaction_id"].stringValue
                    }
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
        }
    }
    
    func setupUI() {
        self.bottomView.layer.cornerRadius = 10.0
        self.bottomView.layer.masksToBounds = true
        self.bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.payLabel.layer.cornerRadius = 30
        self.payLabel.clipsToBounds = true
        swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUpGesture))
        swipeUpGesture.direction = .up
        swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDownGesture))
        swipeDownGesture.direction = .down
        payView.addGestureRecognizer(swipeUpGesture)
        bottomView.addGestureRecognizer(swipeDownGesture)
        cartImage.isHidden = true
        walletBtn.layer.borderWidth = 1.0
        walletBtn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        walletBtn.layer.cornerRadius = 5.0
        paytmBtn.layer.borderWidth = 1.0
        paytmBtn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        paytmBtn.layer.cornerRadius = 5.0
        sodexoBtn.layer.borderWidth = 1.0
        sodexoBtn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        sodexoBtn.layer.cornerRadius = 5.0
        otherPaymentsBtn.layer.borderWidth = 1.0
        otherPaymentsBtn.layer.borderColor = UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
        otherPaymentsBtn.layer.cornerRadius = 5.0
        greenTick.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHiddenView))
        hiddenView.addGestureRecognizer(tapGesture)
    }
    
    func getBalanceApiCalled() {
        print("Get wallet balance API", getFullServiceUrl(serviceName: "/api/vendour/v1/wallet/"))
        Alamofire.request(getFullServiceUrl(serviceName: "/api/vendour/v1/wallet/"), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = JSON(json["response"])
                    let currency = jsonResponse["currency"].stringValue
                    let walletBalance = jsonResponse["personal_wallet"].stringValue
                    self.doubleWalletBalance = Double(walletBalance)
                    self.intWalletBalance = Int(self.doubleWalletBalance!)
                    self.walletBalanceLabel.text = currency + String(self.doubleWalletBalance!)
                    if self.doubleWalletBalance == 0.0 {
                        self.walletBalanceLabel.textColor = UIColor(red: 184/255, green: 184/255, blue: 184/255, alpha: 1)
                        self.vendourWallet.image = UIImage(named: "grayWallet")
                    }
                    else {
                        self.walletBalanceLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                        self.vendourWallet.image = UIImage(named: "walletVendour")
                    }
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
        }
    }
    
    func getTimeApiCalled() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/v1/events/get/time/")
        print("Get Time API",serviceName)
        Alamofire.request(serviceName, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"]
                    self.systemDate = jsonResponse["system_date"].stringValue
                    self.systemTimeStamp = jsonResponse["system_timestamp"].stringValue
                    CommonController.shared.systemDate = self.systemDate
                    print("Crypto Command Sent : ","@D\(self.systemDate)$")
                    print("Crypto Combined Response ", "*U\(CommonController.shared.crypto!)#")
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
        }
    }
    
    func transactionCaptureApi(otherMethodUsed : String) {
        CommonController.shared.showHud(title: "", sender: self.view)
        var params : [String : Any] = [:]
        var kOtherMethodUsed = ""
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/transaction/capture/")
        if otherMethodUsed == "razorpay" {
            self.transactionId = razorpayTransactionId
            self.orderId = ""
            kOtherMethodUsed = "razorpay"
        }
        if otherMethodUsed == "wallet" {
            self.transactionId = CommonController.shared.walletTransactionId!
            self.orderId = ""
            kOtherMethodUsed = "wallet"
        }
        if otherMethodUsed == "simpl" {
            self.transactionId = simplTransactionId
            self.orderId = ""
            kOtherMethodUsed = "simpl"
        }
        if otherMethodUsed == "wallet+razorpay" {
            self.transactionId = razorpayTransactionId
            self.orderId = ""
            kOtherMethodUsed = "wallet+razorpay"
        }
        if otherMethodUsed == "wallet+simpl" {
            self.transactionId = simplTransactionId
            self.orderId = ""
            kOtherMethodUsed = "wallet+simpl"
        }
        if otherMethodUsed == "wallet+paytm" {
            self.transactionId = self.paytmTransactionId!
            self.orderId = paytmOrderId
            kOtherMethodUsed = "wallet+paytm"
        }
        if otherMethodUsed == "paytm" {
            self.transactionId = self.paytmTransactionId!
            self.orderId = paytmOrderId
            kOtherMethodUsed = "paytm"
        }
        if walletUsed == true {
            if CommonController.shared.machineHardwareType == "Normal" && CommonController.shared.selectionFlow == "0" {
                // Don't call paramters products and crypto and timestamp
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : kOtherMethodUsed,
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : CommonController.shared.amountByWallet!,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ],
                    "wallet_data" : [
                        "paid_by_personal_wallet" : Float(CommonController.shared.amountByWallet!),
                        "paid_by_org_wallet" : 0,
                        "paid_by_personal_cashback" : 0
                    ],
                    "wallet_transaction_id" : CommonController.shared.walletTransactionId!
                ]
            }
            else if CommonController.shared.machineHardwareType != "Normal" && CommonController.shared.selectionFlow == "0" {
                //  Call crypto and timestanmp but not products
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "timestamp" : self.systemTimeStamp,
                    "crypto" : CommonController.shared.crypto!,
//                    "crypto" : self.systemDate,
                    "payment_mode" : kOtherMethodUsed,
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : CommonController.shared.amountByWallet!,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ],
                    "wallet_data" : [
                        "paid_by_personal_wallet" : Float(CommonController.shared.amountByWallet!),
                        "paid_by_org_wallet" : 0,
                        "paid_by_personal_cashback" : 0
                    ],
                    "wallet_transaction_id" : CommonController.shared.walletTransactionId!
                ]
            }
            else if CommonController.shared.machineHardwareType == "Normal" && CommonController.shared.selectionFlow != "0" {
                // Call Products but not crypto timestamp
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : kOtherMethodUsed,
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : CommonController.shared.amountByWallet!,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ],
                    "products" : productArray,
                    "wallet_data" : [
                        "paid_by_personal_wallet" : Float(CommonController.shared.amountByWallet!),
                        "paid_by_org_wallet" : 0,
                        "paid_by_personal_cashback" : 0
                    ],
                    "wallet_transaction_id" : CommonController.shared.walletTransactionId!
                ]
            }
            else {
                // Call both Products and Crypto
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : kOtherMethodUsed,
                    "timestamp" : self.systemTimeStamp,
                    //                "crypto" : self.systemDate,
                    "crypto" : CommonController.shared.crypto!,
                    "machine" : Int(CommonController.shared.machineId) ?? 0,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : CommonController.shared.amountByWallet!,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ],
                    "products" : productArray,
                    "wallet_data" : [
                        "paid_by_personal_wallet" : Float(CommonController.shared.amountByWallet!),
                        "paid_by_org_wallet" : 0,
                        "paid_by_personal_cashback" : 0
                    ],
                    "wallet_transaction_id" : CommonController.shared.walletTransactionId!
                ]
            }
        }
        else {
            if CommonController.shared.machineHardwareType == "Normal" && CommonController.shared.selectionFlow == "0" {
                // Don't call paramters products and crypto and timestamp
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : kOtherMethodUsed,
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : 0,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ]
                ]
            }
            else if CommonController.shared.machineHardwareType != "Normal" && CommonController.shared.selectionFlow == "0" {
                //  Call crypto and timestanmp but not products
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "timestamp" : self.systemTimeStamp,
                    "crypto" : CommonController.shared.crypto!,
//                    "crypto" : self.systemDate,
                    "payment_mode" : kOtherMethodUsed,
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : 0,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ]
                ]
            }
            else if CommonController.shared.machineHardwareType == "Normal" && CommonController.shared.selectionFlow != "0" {
                // Call Products but not crypto timestamp
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : kOtherMethodUsed,
                    "machine" : CommonController.shared.machineId,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : 0,
                        "paid_by_gateway" : CommonController.shared.amountByGateway!
                    ],
                    "products" : productArray
                ]
            }
            else {
                // Call both Products and Crypto
                let paidByGateway = Float(CommonController.shared.amountByGateway!)
                params = [
                    "auth_token" : UserDefaults.standard.string(forKey: kConstant.localKeys.authToken)!,
                    "payment_mode" : kOtherMethodUsed,
                    "timestamp" : self.systemTimeStamp,
                    //                "crypto" : self.systemDate,
                    "crypto" : CommonController.shared.crypto!,
                    "machine" : Int(CommonController.shared.machineId) ?? 0,
                    "transaction" : [
                        "transaction_id" : self.transactionId,
                        "order_id" : self.orderId
                    ],
                    "amount" : [
                        "paid_by_wallet" : Float(0.0),
                        "paid_by_gateway" : paidByGateway
                    ],
                    "products" : productArray
                ]
            }
        }
        print("Transaction Capture API", serviceName)
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    CommonController.shared.crypto = json["new_crypto"].stringValue
                    CommonController.shared.transactionId = json["response"].stringValue
//                    let alert = UIAlertController(title: "Vendour", message: "Payment Successful", preferredStyle: .alert)
//                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                        let vc = VendingScreenVC()
                        self.navigationController?.pushViewController(vc, animated: true)
                    CommonController.shared.hideHud()
//                    })
//                    alert.addAction(okAction)
//                    self.present(alert, animated: true, completion: nil)
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
                    CommonController.shared.hideHud()
                }
            }
            else {
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "No Internet Connection")
            }
            CommonController.shared.hideHud()
        }
    }
    
    func walletRefundApi() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/wallet/refund/")
        let params : [String : Any] = [
            "paid_by_personal_wallet" : Float(CommonController.shared.amountByWallet!),
            "wallet_transaction_id" : CommonController.shared.walletTransactionId!
        ]
        print("Wallet Refund API")
        
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Wallet balance refunded")
                    self.getBalanceApiCalled()
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
        }
    }
    
    func getProductArray() {
        for i in 0..<CommonController.shared.individualItemArray.count {
            var singleProduct : [String : Any] = [:]
            singleProduct["product"] = Int(CommonController.shared.individualItemArray[i].productID!)
            singleProduct["price"] = Float(CommonController.shared.individualItemArray[i].cost!)
            singleProduct["status"] = Int("0")
            singleProduct["cell_number"] = CommonController.shared.individualItemArray[i].cellNumber
            self.productArray.append(singleProduct)
        }
    }
    
    func getSimplProductArray() {
        for i in 0..<CommonController.shared.individualItemArray.count {
            var singleProduct : [String : Any] = [:]
            singleProduct["product"] = Int(CommonController.shared.individualItemArray[i].productID!)
            singleProduct["price"] = Int(CommonController.shared.individualItemArray[i].cost!)
            self.simplProductArray.append(singleProduct)
        }
    }
    
    // LOCATION MANAGER DELEGATES AND FUNCTIONS
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation : CLLocationCoordinate2D = manager.location!.coordinate
        latitude = lastLocation.latitude
        longitude = lastLocation.longitude
        locationManager.stopUpdatingLocation()
    }
}

extension MachineDetailsVC : CloseCrossButton, PGTransactionDelegate {
    func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!) {
        let usableData = convertToDictionary(text: responseString)
        let transId = usableData!["TXNID"]
        self.paytmTransactionId = transId as? String
        self.paymCheckStatusApi()
    }
    
    func didCancelTrasaction(_ controller: PGTransactionViewController!) { 
        if self.walletUsed == true {
            self.walletRefundApi()
        }
        CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Payment Successful")
    }
    
    func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {
        self.errorMessage(message: "Something went wrong. Please try again")
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func closeCrossButton() {
        self.infoBtnPressed = false
        for i in 0..<machineDetails.count {
            machineDetails[i].shouldShowInfoBtn = true
        }
        self.apiCall()
    }
    
    func handlePaytmTransaction(merchantID : String, orderID : String, channelID : String, website : String, industryType : String, checksum : String, callbackUrl : String, theme : String, amount : String) {
        let mc = PGMerchantConfiguration.default()
        var orderDict = [AnyHashable : Any]()
        PGServerEnvironment.createProduction()
        let pgServer = PGServerEnvironment.init()
        orderDict["MID"] = merchantID
        orderDict["ORDER_ID"] = orderID
        orderDict["CUST_ID"] = UserDefaults.standard.string(forKey: kConstant.localKeys.customerId)!
        orderDict["MOBILE_NO"] = UserDefaults.standard.string(forKey: kConstant.localKeys.mobNumber)!
        orderDict["EMAIL"] = UserDefaults.standard.string(forKey: kConstant.localKeys.emailId)!
        orderDict["CHANNEL_ID"] = channelID
        orderDict["WEBSITE"] = website
        orderDict["TXN_AMOUNT"] = amount
        orderDict["INDUSTRY_TYPE_ID"] = industryType
        orderDict["CHECKSUMHASH"] = checksum
        orderDict["CALLBACK_URL"] = callbackUrl
        orderDict["THEME"] = theme
        print("PAytm SDK Call parameters", orderDict)
        let order = PGOrder(params: orderDict)
        pgServer.callBackURLFormat = callbackUrl
        let txnController = PGTransactionViewController.init(transactionFor: order)
        txnController?.serverType = eServerTypeProduction
        txnController?.merchant = mc
        txnController?.delegate = self
        txnController?.loggingEnabled = true
        self.show(txnController!, sender: self)
//        let vc = PaytmVC()
//        vc.show(txnController!, sender: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
//        //Step 1: Create a default merchant config object
//        let mc: PGMerchantConfiguration = PGMerchantConfiguration.default()
//        
//        //Step 2: If you have your own checksum generation and validation url set this here. Otherwise use the default Paytm urls
//        
//        mc.checksumGenerationURL = "https://pguat.paytm.com/paytmchecksum/paytmCheckSumGenerator.jsp"
//        mc.checksumValidationURL = "https://pguat.paytm.com/paytmchecksum/paytmCheckSumVerify.jsp"
//        
//        //Step 3: Create the order with whatever params you want to add. But make sure that you include the merchant mandatory params
//        var orderDict: [NSObject : AnyObject] = NSMutableDictionary() as [NSObject : AnyObject]
//        let order = PGOrder(forOrderID: "", customerID: "", amount: "", customerMail: "", customerMobile: "")
//        order!.params = ["MID": "rxazcv89315285244163",
//                        "ORDER_ID": "order1",
//                        "CUST_ID": "cust123",
//                        "MOBILE_NO": "7777777777",
//                        "EMAIL": "username@emailprovider.com",
//                        "CHANNEL_ID": "WAP",
//                        "WEBSITE": "WEBSTAGING",
//                        "TXN_AMOUNT": "100.12",
//                        "INDUSTRY_TYPE_ID": "Retail",
//                        "CHECKSUMHASH": "oCDBVF+hvVb68JvzbKI40TOtcxlNjMdixi9FnRSh80Ub7XfjvgNr9NrfrOCPLmt65UhStCkrDnlYkclz1qE0uBMOrmuKLGlybuErulbLYSQ=",
//                        "CALLBACK_URL": "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=order1"]
//        
//        //Step 4: Choose the PG server. In your production build dont call selectServerDialog. Just create a instance of the
//        //PGTransactionViewController and set the serverType to eServerTypeProduction
//        PGServerEnvironment.selectServerDialog(self.view, completionHandler: {(type: ServerType) -> Void in
//            
//            let txnController = PGTransactionViewController.init(transactionFor: order)
//            
//            
//            if type != eServerTypeNone {
//                txnController!.serverType = type
//                txnController!.merchant = mc
//                txnController!.delegate = self
//                self.show(txnController!, sender: nil)
//            }
//        })
//
    }
    func getChecksumApiCalled() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/gateways/paytm/checksum/")
        var amountToBePaid = ""
        if walletUsed == true {
            amountToBePaid = String(CommonController.shared.amountByGateway!)
        }
        else {
            amountToBePaid = String(totalCost)
        }
        let params : [String : String] = [
            "CUST_ID" : UserDefaults.standard.string(forKey: kConstant.localKeys.customerId)!,
            "TXN_AMOUNT" : amountToBePaid,
            "EMAIL" : UserDefaults.standard.string(forKey: kConstant.localKeys.emailId)!,
            "MOBILE_NO" : UserDefaults.standard.string(forKey: kConstant.localKeys.mobNumber)!,
            "machine_id" : "\(machineID)"
        ]
        print("PAytm get checksum API")
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"]
                    let orderID = jsonResponse["ORDER_ID"].stringValue
                    let merchantID = jsonResponse["paytm"]["paytm_mid"].stringValue
                    let channelID = jsonResponse["paytm"]["channel_id"].stringValue
                    let website = jsonResponse["paytm"]["paytm_website"].stringValue
                    let industryType = jsonResponse["paytm"]["industry_type_id"].stringValue
                    let callbackURL = jsonResponse["paytm"]["callback_url"].stringValue
                    let checksum = jsonResponse["CHECKSUMHASH"].stringValue
                    let theme = jsonResponse["paytm"]["theme"].stringValue
                    self.paytmOrderId = orderID
                    self.handlePaytmTransaction(merchantID: merchantID, orderID: orderID, channelID: channelID, website: website, industryType: industryType, checksum: checksum, callbackUrl: callbackURL, theme : theme, amount : amountToBePaid)
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
        }
    }

    
    func paymCheckStatusApi() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/gateways/paytm/check/status/")
        let params : [String : Any] = [
//            String “ORDER_ID” Integer “machine_id”
            "ORDER_ID" : paytmOrderId,
            "machine_id" : Int(machineID)!
        ]
        print("PAytm check status API")
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess == true {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    if self.walletUsed == true {
                        self.transactionCaptureApi(otherMethodUsed: "wallet+paytm")
                    }
                    else {
                        self.transactionCaptureApi(otherMethodUsed: "paytm")
                    }
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
        }
    }
}

extension MachineDetailsVC : RazorpayPaymentCompletionProtocol {
    
    func onPaymentError(_ code: Int32, description str: String) {
        self.navigationController?.isNavigationBarHidden = true
        if walletUsed == true {
            self.walletRefundApi()
        }
        CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Payment Failed")
        print("Razorpay failed")
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        self.navigationController?.isNavigationBarHidden = true
        self.razorpayTransactionId = payment_id
        if walletUsed == true {
            self.transactionCaptureApi(otherMethodUsed: "wallet+razorpay")
        }
        else {
            CommonController.shared.amountByGateway = totalCost
            self.transactionCaptureApi(otherMethodUsed: "razorpay")
        }
        print("Razorpay Success")
    }

}
