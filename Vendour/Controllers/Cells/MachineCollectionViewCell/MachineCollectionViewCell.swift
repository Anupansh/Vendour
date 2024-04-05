//
//  MachineCollectionViewCell.swift
//  Vendour
//
//  Created by Clixlogix on 31/12/18.
//  Copyright © 2018 Test. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import SwiftyJSON


class MachineCollectionViewCell: UICollectionViewCell , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var inventoryView: UIView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet var viewRoot : UIView!
    @IBOutlet var labelMachineDescription : UILabel!
    @IBOutlet var labelDistance : UILabel!
    @IBOutlet var buttonShowInventory : UIButton!
    @IBOutlet var collectionViewInventory : UICollectionView!
    @IBOutlet weak var inventoryViewBtn: UIButton!
    
    var cvcMachineID = ""
    var shouldGetInventoryData = true
    var inventoryFilled : Bool?
    var navigationClosure : (() -> ())?
    
    var arrayInventory = [MachineInventoryModel]()
    override func awakeFromNib() {
        collectionViewInventory.delegate = self
        collectionViewInventory.dataSource = self
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNavigationView))
//        navigationView.addGestureRecognizer(tapGesture)
    }
   
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    //MARK: Get inventory api
    
//    
//    @objc func handleNavigationView() {
//        navigationClosure!()
//    }
    
    func getInventoryWithAlamofire(machineId : Int){
        
        if shouldGetInventoryData == false{
            return
        }
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/inventory/\(machineId)/")

        print(serviceName)

        Alamofire.request(serviceName, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in

            
            self.shouldGetInventoryData = false
            guard response.result.isSuccess else {
                print("Error while fetching data : \(String(describing: response.result.error))")
                return
            }
            guard let dict = response.result.value as? NSDictionary else{
                print("Malformed data received ")
                return
            }
            print(response.result.value)
            let message = (dict.object(forKey: "message") as! String)
            guard let status = dict["status"] as? Int else{return}
            if  Int(status) == 200 {
                
                let json = JSON(response.result.value!)
                let jsonResponse = json["response"]
                for i in 0..<jsonResponse.count {
                    let object = MachineInventoryModel()
                    object.image = jsonResponse[i]["product_detail"]["image"].stringValue
                    object.qty = jsonResponse[i]["qty"].stringValue
                    object.price = jsonResponse[i]["product_detail"]["price"].stringValue
                    self.arrayInventory.append(object)
                }
//                 let inventoryList = dict["response"] as! NSArray
//                 print(inventoryList)
//                for inventory in inventoryList{
//                    let object = MachineInventoryModel()
//                    print(inventory)
////                    let json = JSON(response.result.value!)
////                    let jsonResponse = json["response"]
//                    let inventoryDetails = (inventory as AnyObject).object(forKey: "product_detail")
//
//                    object.brand = ((inventoryDetails as AnyObject).object(forKey: "brand") as! Int)
//                    object.brand_name = ((inventoryDetails as AnyObject).object(forKey: "brand_name") as! String)
//                    object.brand_name = ((inventoryDetails as AnyObject).object(forKey: "brand_name") as! String)
//                    object.category = ((inventoryDetails as AnyObject).object(forKey: "category") as! Int)
//                    object.category_name = ((inventoryDetails as AnyObject).object(forKey: "category_name") as! String)
//                    object.category_name = ((inventoryDetails as AnyObject).object(forKey: "category_name") as! String)
////                    object.country = ((inventoryDetails as AnyObject).object(forKey: "country") as! Int)
//                    object.flavour = ((inventoryDetails as AnyObject).object(forKey: "flavour") as! String)
//                    object.id = ((inventoryDetails as AnyObject).object(forKey: "id") as! Int)
//                    object.image = ((inventoryDetails as AnyObject).object(forKey: "image") as! String)
//                    object.price = ((inventoryDetails as AnyObject).object(forKey: "price") as! Float)
//                    object.product_name = ((inventoryDetails as AnyObject).object(forKey: "product_name") as! String)
////                    object.product_type = ((inventoryDetails as AnyObject).object(forKey: "product_type") as! String)
//                    object.product_uid =  ((inventoryDetails as AnyObject).object(forKey: "product_uid") as! String)
//                    object.unit =  ((inventoryDetails as AnyObject).object(forKey: "unit") as! String)
////                    object.weight =  ((inventoryDetails as AnyObject).object(forKey: "weight") as! String)
//                    object.qty =  ((inventoryDetails as AnyObject).object(forKey: "qty") as! Any)
//                    object.qty = jsonResponse["qty"].stringValue
//                    print(object.qty)
////                    if ((inventoryDetails as AnyObject).object(forKey: "qty")) != nil {
////                        object.qty = ((inventoryDetails as AnyObject).object(forKey: "qty")) as? Int
////                    }
////                    else {
////                        object.qty = 0
////                    }
////                    object.staff = ((inventoryDetails as AnyObject).object(forKey: "staff") as! Int)
////                    object.staff_first_name = ((inventoryDetails as AnyObject).object(forKey: "staff_first_name") as! String)
////                    object.staff_last_name =  ((inventoryDetails as AnyObject).object(forKey: "staff_last_name") as! String)
//
//                    self.arrayInventory.append(object)
//                }
            }
            self.collectionViewInventory.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if arrayInventory.count == 0 {
            self.collectionViewInventory.setEmptyMessage("No inventory in machine")
            print("Inside zero")
        }
        else {
            self.collectionViewInventory.restore()
        }
        return arrayInventory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionViewInventory.dequeueReusableCell(withReuseIdentifier: "InventoryCollectionCell", for: indexPath) as! InventoryCollectionCell
       // cell.contentView.backgroundColor = .yellow
//        cell.imageviewProduct.image = UIImage(named: "")
//        cell.labelPrice.text = "10"
//        cell.labelQuantity.text = "Qty. 11"
//        cell.labelQuantity.text = "Qty. 10"
//        if arrayInventory.count == 0 {
//            self.collectionViewInventory.setEmptyMessage("No inventory in machine")
//            print("Inside zero")
//        }
//        else {
            self.collectionViewInventory.restore()
        cell.labelQuantity.text = "Qty." + arrayInventory[indexPath.row].qty
            cell.imageviewProduct.contentMode = .scaleAspectFit
            cell.imageviewProduct.sd_setImage(with: URL(string: arrayInventory[indexPath.row].image), completed: nil)
            cell.labelPrice.text = "₹" + String(arrayInventory[indexPath.row].price)
            print("Outside zero")
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 55, height: 80)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 5
//    }
    
}



extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "System", size: 15)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
