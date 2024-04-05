//
//  HomeScreen.swift
//  Vendour
//
//  Created by AppDev on 18/12/18.
//  Copyright © 2018 Test. All rights reserved.
//


//  let url = NSURL(string: "\("https://maps.googleapis.com/maps/api/directions/json")?origin=\("17.521100"),\("78.452854")&destination=\("15.1393932"),\("76.9214428")")

import UIKit
import SWRevealViewController
import GoogleMaps
import Alamofire
import CoreLocation
import CoreBluetooth
import SwiftyJSON

enum TypeOfCommand {
    case crypto
    case transactionHandshake
    case clearTransaction
    case eventHandshake
    case clearEvent
    case inventoryInfo
}


class HomeScreen: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate  , GMUClusterRendererDelegate  , GMUClusterManagerDelegate , GMSMapViewDelegate{
    
    @IBOutlet weak var searchingMachineLabel: UILabel!
    @IBOutlet var drawerBtnL: UIButton!
    @IBOutlet var myMapView : GMSMapView!
    @IBOutlet var bottomView : UIView!
    @IBOutlet var bottomAnchorBottomView : NSLayoutConstraint!
    @IBOutlet var heightAnchorBottomView : NSLayoutConstraint!
    @IBOutlet var buttonRefresh : UIButton!
    @IBOutlet var buttonCrossBottomView : UIButton!
    @IBOutlet var collectionViewMachines : UICollectionView!
    @IBOutlet weak var machineInfoCollectionView: UICollectionView! {
        didSet {
            machineInfoCollectionView.delegate = self
            machineInfoCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var searchCrossBtn: UIButton!
    
    var pushDone : Bool = false
    var peripheralArray = [CBPeripheral]()
    var machineInfoArray = [MachineInfo]()
    var hardWareIdArray = [Int]()
    var latitude : Double!
    var longitude : Double!
    var selectedMachineIndex : Int = 0
    let locationManager = CLLocationManager()
    var arrayMachinesNearBy = [NearestMachineDataModel]()
    private var clusterManager: GMUClusterManager!
    let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    var centralManager = CBCentralManager()
    var machinePerpheral : CBPeripheral? = nil
    let ServiceUUID = CBUUID(string: "49535343-FE7D-4AE5-8FA9-9FAFD205E455")
    let readCharactersticUUID = CBUUID(string: "49535343-1E4D-4BD9-BA61-23C647249616")
    let writeCharactersticUUID = CBUUID(string: "49535343-1E4D-4BD9-BA61-23C647249616")
    var markers = [GMSMarker]()
    var shouldMapAnimate : Bool = true
    var bluetoothConnectedCheck : Bool = false
    var stringHardwareId = ""
    var hardwareID : Int?
    var machineHardwareType = ""
    var readCharacterstic : CBCharacteristic?
    var writeCharacterstic : CBCharacteristic?
    var systemDate = ""
    var recievedCryptoString = ""
    var writeEnabled : Bool = false
    var readEnabled : Bool = false
    var nextIsCrypto : Bool = false
    var nextIsHandshake : Bool = false
    var nextIsEvent : Bool = false
    var nextIsInventoryInfo : Bool = false
    var typeOfCommand : TypeOfCommand = .crypto
    var handshakeResponse : String = ""
    var eventResponse : String = ""
    var inventoryResponse : String = ""
    var selectedHardwareId : Int?
    var byteArray : [UInt8] = []
    var cutIndex : Int?
    var bluetoothInventory = [MachineDetails]()
    var inventoryMap = [String : [String]]()
    var localMachineId : String = ""
    var searchProductArray = [SearchProduct]()
    var machineIdArray : [Int] = []
    var searchMachineIdArray : [Int] = []
    var searchEnabled : Bool = false
    var viewAppeared : Bool = false
    var timer = Timer()
    var seconds = 60
    var commandsHandled : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseViews()
        getTimeApiCalled()
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = .up
        bottomView.addGestureRecognizer(swipeUp)
        DispatchQueue.main.async {
            if self.revealViewController() != nil {
                self.drawerBtnL.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
                //            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
                self.revealViewController()?.panGestureRecognizer()
                //            self.revealViewController()?.tapGestureRecognizer()
            }
        }
        centralManager.delegate = self
        searchCrossBtn.isHidden = true
        heightAnchorBottomView.constant = 2 * SH / 3
        bottomAnchorBottomView.constant = -heightAnchorBottomView.constant + 60
        tableView.isHidden = true
        searchTf.autocorrectionType = .no
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(manageTimer), userInfo: nil, repeats: true)
    }
    
    func initialiseViews(){
        buttonRefresh.rotate360Degrees()
        //buttonRefresh.layer.removeAllAnimations()
        
        
        collectionViewMachines.delegate = self
        collectionViewMachines.dataSource = self
                
       // if CLLocationManager.locationServicesEnabled() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
//        navigateToGoogleMaps()
       // }
    }
    
    
    @objc func manageTimer() {
        if seconds == 0 {
            buttonRefresh.layer.removeAllAnimations()
            if hardWareIdArray.count == 0 {
                searchingMachineLabel.text = "No machines in vicnity."
            }
            timer.invalidate()
        }
        else {
            seconds -= 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        machineInfoCollectionView.reloadData()
        collectionViewMachines.reloadData()
        commandsHandled = false
    }
    
    // MARK: UICollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       if collectionView == machineInfoCollectionView{
            return 1
        }
        else {
            return self.arrayMachinesNearBy.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       if collectionView == machineInfoCollectionView {
            return machineInfoArray.count
       }
        else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionViewMachines {
            self.navigateToGoogleMaps(with: arrayMachinesNearBy[indexPath.row].latitude, longitude: arrayMachinesNearBy[indexPath.row].longitude)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == machineInfoCollectionView{
            let cell = machineInfoCollectionView.dequeueReusableCell(withReuseIdentifier: "MachineInfoCollectionCell", for: indexPath) as! MachineInfoCollectionCell
            cell.machineImage.sd_setImage(with: URL(string: machineInfoArray[indexPath.row].machineImage!), completed: nil)
            UIView.animate(withDuration: 0.5, animations: {
                cell.machineImage.frame.origin.y -= 20
            }){_ in
                UIView.animateKeyframes(withDuration: 0.5, delay: 0.1, options: [.autoreverse, .repeat], animations: {
                    cell.machineImage.frame.origin.y += 20
                })
            }
            if machineInfoArray.count == 1 {
                cell.leftArrow.isHidden = true
                cell.rightArrow.isHidden = true
            }
            else {
                if indexPath.row == 0 {
                    cell.rightArrow.isHidden = false
                    cell.leftArrow.isHidden = true
                }
                else if indexPath.row == machineInfoArray.count - 1 {
                    cell.leftArrow.isHidden = false
                    cell.rightArrow.isHidden = true
                }
                else {
                    cell.leftArrow.isHidden = false
                    cell.rightArrow.isHidden = false
                }
            }
            cell.machineImageTopConstraint.constant = 45
            cell.machineUid.text = machineInfoArray[indexPath.row].machineUid
            cell.operatorName.text = machineInfoArray[indexPath.row].operatorName
            cell.jumpToVCClosure = {
                self.machinePerpheral = self.peripheralArray[indexPath.row]
                CommonController.shared.peripheral = self.peripheralArray[indexPath.row]
                CommonController.shared.selectionFlow = self.machineInfoArray[indexPath.row].k_Type!
                CommonController.shared.machineHardwareType = self.machineInfoArray[indexPath.row].machineHardwareType
                CommonController.shared.machineId = self.machineInfoArray[indexPath.row].machineID!
                if self.machineInfoArray[indexPath.row].machineHardwareType != "Normal" && self.machineInfoArray[indexPath.row].cryptoCommandSent == false {
                    self.machineInfoArray[indexPath.row].cryptoCommandSent = true
                    self.peripheralArray[indexPath.row].delegate = self
                    self.typeOfCommand = .crypto
                }
                else {
                    self.peripheralArray[indexPath.row].delegate = self
                    self.typeOfCommand = .transactionHandshake
                }
                self.selectedHardwareId = self.hardWareIdArray[indexPath.row]
                self.centralManager.connect(self.peripheralArray[indexPath.row], options: nil)
                CommonController.shared.showHud(title: "Connecting to machine", sender: self.view)
                self.localMachineId = self.machineInfoArray[indexPath.row].machineID!
                    cell.machineImageTopConstraint.constant = -130
                    UIView.animate(withDuration: 0.2) {
                        self.view.layoutIfNeeded()
                    }
            }
            return cell
        }
        else {
            let cell = collectionViewMachines.dequeueReusableCell(withReuseIdentifier: "MachineCollectionViewCell", for: indexPath) as! MachineCollectionViewCell
//            if arrayMachinesNearBy[indexPath.section]
            cell.viewRoot.layer.cornerRadius = 10
            cell.viewRoot.clipsToBounds = true
            cell.buttonShowInventory.tag = indexPath.section
            cell.inventoryViewBtn.tag = indexPath.section
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMachineInventory))
            cell.inventoryView.addGestureRecognizer(tapGesture)
            cell.buttonShowInventory.addTarget(self, action: #selector(handleMachineInventory), for: .touchUpInside)
            cell.inventoryViewBtn.addTarget(self, action: #selector(handleMachineInventory), for: .touchUpInside)
            if arrayMachinesNearBy[indexPath.section].isInventoryOpened == true {
                cell.buttonShowInventory.setImage(UIImage(named: "downCaret"), for: .normal)
            }
            else {
                cell.buttonShowInventory.setImage(UIImage(named: "upCaret"), for: .normal)
            }
            cell.labelMachineDescription.text = arrayMachinesNearBy[indexPath.section].machine_description
            cell.labelDistance.text = arrayMachinesNearBy[indexPath.section].distance
            cell.getInventoryWithAlamofire(machineId: arrayMachinesNearBy[indexPath.section].id)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            if collectionView == machineInfoCollectionView{
            return CGSize(width: self.view.frame.width, height: (2 * self.view.frame.height / 3) - 60 )
        }
        else {
        if collectionView == collectionViewMachines{
            let object = arrayMachinesNearBy[indexPath.section]
            if object.isInventoryOpened == true{
                 return CGSize.init(width: self.collectionViewMachines.frame.width, height: 200)
            }
            else {
                    return CGSize.init(width: self.collectionViewMachines.frame.width, height: 107)
                }
            }
            return CGSize.init(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        if collectionView == machineInfoCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        else {
            if collectionView == collectionViewMachines && arrayMachinesNearBy.count > 0{
                let object = arrayMachinesNearBy[section]
                if object.isInventoryOpened == true{
                    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }
                else {
                 return UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
                }
            }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
       if collectionView == machineInfoCollectionView {
        
       }
        else {
//        if let selectedMarker = myMapView.selectedMarker {
//            selectedMarker.icon = GMSMarker.markerImage(with: nil)
//        }
        
//        // select new marker and make green
//        myMapView.selectedMarker = markers[indexPath.row]
//        markers[indexPath.row].icon = GMSMarker.markerImage(with: UIColor.green)
        
        // deselect the selected marker
        

            if shouldMapAnimate == true{
                if searchEnabled {
                    
                }
                else {
                    if let selectedMarker = myMapView.selectedMarker {
                        // selectedMarker.icon = GMSMarker.markerImage(with: nil)
                        selectedMarker.icon = UIImage(named: "map_point_stroke")
                    }
                    // select new marker
                    // marker.icon = GMSMarker.markerImage(with: UIColor.green)
                    myMapView.selectedMarker = markers[indexPath.section]
                    markers[indexPath.section].icon =  UIImage(named: "map_point_fill")
                }
            
                let camera = GMSCameraPosition.camera(withLatitude: Double(arrayMachinesNearBy[indexPath.section].latitude) ,longitude: Double(arrayMachinesNearBy[indexPath.section].longitude) , zoom: 13.5)
                myMapView.animate(to: camera)
            }
//        let clusters = clusterManager.algorithm.clusters(atZoom: 1.0)
//
//        for markers in clusters{
//            let marker = markers.items
//            for item in marker{
//                if let poiItem = item as? POIItem{
//                    print(poiItem.name)
//                    if poiItem.name == "\(indexPath.row)"{
//
//                    }
//                }
//            }
//        }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pushDone = false
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        shouldMapAnimate = true
    }
    
    //MARK: API
    func getNearestMachinesWithAlamofire(lat: Double , long: Double) {
        let serviceName = getFullServiceGisUrl(serviceName: "/nearest/locations/")

        //TODO: Change the request parameters
        let requestParam : [String : Any] = ["longitude" : 77.391029 , "latitude" : 28.535517]
       // let requestParam : [String : Any] = ["longitude" : lat , "latitude" : long]

        print("Get nearest machine API", serviceName)
        print(requestParam)
        CommonController.shared.showHud(title: "", sender: self.view)
        Alamofire.request(serviceName, method: .post, parameters: requestParam, encoding: JSONEncoding.default , headers : CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON{
            response in
            CommonController.shared.hideHud()
            guard response.result.isSuccess else {
        
                CommonController.shared.ShowAlert(self, msg_title: "", message_heading: "Error while fetching data ")
                return
            }
            guard let dict = response.result.value as? NSDictionary else{

                return
            }
            print(response.result.value!)
            let message = (dict.object(forKey: "message") as! String)
            guard let status = dict["status"] as? Int else{return}
            if  Int(status) == 200 {
                guard let machineList = dict["response"] as? NSArray else{return}
    
                for i in 0..<machineList.count{
                    let object = NearestMachineDataModel()
                    object.countryId = ((machineList[i] as AnyObject).object(forKey: "country_id") as! Int)
                    object.displacement = ((machineList[i] as AnyObject).object(forKey: "displacement") as! Double)
                    object.distance = ((machineList[i] as AnyObject).object(forKey: "distance") as! String)
                    object.eta = ((machineList[i] as AnyObject).object(forKey: "eta") as! String)
                    object.id = ((machineList[i] as AnyObject).object(forKey: "id") as! Int)
                    object.is_v2d2 = ((machineList[i] as AnyObject).object(forKey: "is_v2d2") as! Bool)
                    object.latitude = Double((machineList[i] as AnyObject).object(forKey: "latitude") as! String)!
                    object.location_type = ((machineList[i] as AnyObject).object(forKey: "location_type") as! String)
                    object.longitude = Double((machineList[i] as AnyObject).object(forKey: "longitude") as! String)!
                    object.machine_description = ((machineList[i] as AnyObject).object(forKey: "machine_description") as! String)
                    object.machine_type = ((machineList[i] as AnyObject).object(forKey: "machine_type") as! String)
                    object.machine_uid = ((machineList[i] as AnyObject).object(forKey: "machine_uid") as! String)
                    object.reverse_geocode = ((machineList[i] as AnyObject).object(forKey: "reverse_geocode") as! String)
                    self.arrayMachinesNearBy.append(object)
                    
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: object.latitude, longitude: object.longitude))
                    marker.userData = i
                    marker.icon = UIImage(named: "map_point_stroke")
                    marker.title = "ETA";
                    marker.snippet = object.eta;
                    self.markers.append(marker)
                    marker.map = self.myMapView
                }
                for i in 0..<self.arrayMachinesNearBy.count {
                    self.machineIdArray.append(self.arrayMachinesNearBy[i].id)
                }
                self.collectionViewMachines.reloadData()
             //   self.generateMarkerCluster()
            }else{
                CommonController.shared.ShowAlert(self, msg_title: "", message_heading: message)
            }
        }
    }
    
////    MARK: MapView Delegates
//    func generateMarkerCluster(){
//        // Set up the cluster manager with default icon generator and renderer.
//        let iconGenerator = GMUDefaultClusterIconGenerator()
//
//        let renderer = GMUDefaultClusterRenderer(mapView: myMapView, clusterIconGenerator: iconGenerator)
//        renderer.delegate = self
//        clusterManager = GMUClusterManager(map: myMapView, algorithm: algorithm, renderer: renderer)
//        // Generate and add random items to the cluster manager.
//        generateClusterItems()
//        // Call cluster() after items have been added to perform the clustering and rendering on map.
//        clusterManager.cluster()
//        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
//        clusterManager.setDelegate(self, mapDelegate: self)
//    }
//
//    // MARK: - Private
//    /// Randomly generates cluster items within some extent of the camera and adds them to the
//    /// cluster manager.
//    private func generateClusterItems() {
//        for index in 0..<arrayMachinesNearBy.count {
//            let name = "\(index)"
//            var lat = Double()
//            var long = Double()
//            if let latDouble = NumberFormatter().number(from: (arrayMachinesNearBy[index].latitude))?.doubleValue {
//                lat = latDouble
//            }
//            if let longDouble = NumberFormatter().number(from: (arrayMachinesNearBy[index].longitude))?.doubleValue {
//                long = longDouble
//            }
//            let item = POIItem(position: CLLocationCoordinate2DMake(lat, long), name: name)
//            clusterManager.add(item)
//        }
//    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // Get the arrayIndex of selected marker
        
        if let selectedIndex = marker.userData as? Int {
            // Show collectionView
           self.collectionViewMachines.isHidden = false
            // Focus mapView camera to the marker as center
            let camera = GMSCameraPosition.camera(withLatitude: Double(arrayMachinesNearBy[selectedIndex].latitude) ,longitude: Double(arrayMachinesNearBy[selectedIndex].longitude) , zoom: 14)
            myMapView.animate(to: camera)
            
            let visibleIndexOfCollection = collectionViewMachines.indexPathsForVisibleItems
            if visibleIndexOfCollection.count > 0 {
                let indexOfFirstVisibleCell = visibleIndexOfCollection.first
                if indexOfFirstVisibleCell?.row != selectedIndex{
                    shouldMapAnimate = false
                }
            }
            // Scroll the collectionView to the selectIndex
            collectionViewMachines.scrollToItem(at: IndexPath(item: 0, section: selectedIndex), at: .centeredHorizontally, animated: true)
        }
        
        // deselect the selected marker
        if searchEnabled {
            
        }
        else {
            if let selectedMarker = mapView.selectedMarker {
               // selectedMarker.icon = GMSMarker.markerImage(with: nil)
                 selectedMarker.icon = UIImage(named: "map_point_stroke")
                }
            // select new marker
            mapView.selectedMarker = marker
            // marker.icon = GMSMarker.markerImage(with: UIColor.green)
            marker.icon =  UIImage(named: "map_point_fill")
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // deselect the selected marker
        if searchEnabled {
            
        }
        else {
            if let selectedMarker = mapView.selectedMarker {
                // selectedMarker.icon = GMSMarker.markerImage(with: nil)
                selectedMarker.icon = UIImage(named: "map_point_stroke")
            }
        }
        // select new marker
        mapView.selectedMarker = nil
        collectionViewMachines.isHidden = true
    }
    
    //MARK: CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.latitude = locValue.latitude
        self.longitude = locValue.longitude
        let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude ,longitude: locValue.longitude , zoom: 6)
        myMapView.camera = camera
        myMapView.isMyLocationEnabled = true
        myMapView.delegate = self
        getNearestMachinesWithAlamofire(lat: locValue.latitude, long: locValue.longitude)
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }

    @objc func respondToSwipeGesture(){
        self.buttonCrossBottomView.isHidden = false
        self.bottomAnchorBottomView.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        if peripheralArray.count == 0 {
            searchingMachineLabel.text = "No machine in vicnity"
        }
    }
    
    @objc func handleMachineInventory(_ sender : UIButton){
        arrayMachinesNearBy[sender.tag].isInventoryOpened  = !arrayMachinesNearBy[sender.tag].isInventoryOpened
        collectionViewMachines.reloadData()
    }
    
    @IBAction func handleBottomView(){
        self.buttonCrossBottomView.isHidden = true
        self.bottomAnchorBottomView.constant = -heightAnchorBottomView.constant + 60
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func errorMessage(message : String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func getTimeApiCalled() {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/v1/events/get/time/")
        Alamofire.request(serviceName, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"]
                    self.systemDate = jsonResponse["system_date"].stringValue
                    CommonController.shared.systemDate = self.systemDate
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
    
    @IBAction func searchTfEditingBegan(_ sender: UITextField) {
        if (sender.text?.count)! > 2 {
            tableView.isHidden = false
            searchProductArray.removeAll()
            self.searchProductApi(recievedString: sender.text!)
        }
        else {
            tableView.isHidden = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchProductArray.removeAll()
        tableView.reloadData()
        tableView.isHidden = true
    }
    
    @IBAction func searchCrossBtnPressed(_ sender: Any) {
        searchTf.text = ""
        searchTf.isEnabled = true
        searchCrossBtn.isHidden = true
        tableView.isHidden = true
        searchEnabled = false
        for i in 0..<arrayMachinesNearBy.count {
            markers[i].icon =  UIImage(named: "map_point_stroke")
        }
        collectionViewMachines.isHidden = true
    }
    
}

extension HomeScreen : CBCentralManagerDelegate,CBPeripheralDelegate {
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Bluetooth in unknown state")
        case .resetting:
            print("Bluetooth in resetting state")
        case .unsupported:
            print("Bluetooth in unsupoported state")
        case .unauthorized:
            print("Bluetooth unauthorzied")
        case .poweredOff:
            if !bluetoothConnectedCheck {
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Please turn on your bluetooth to find the nearby machines")
                bluetoothConnectedCheck = true
            }
            machineInfoArray.removeAll()
            machineInfoCollectionView.reloadData()
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let peripheralName = advertisementData["kCBAdvDataLocalName"] as? String {
            if isVendourMachine(peripheralName: peripheralName) {
                (stringHardwareId , machineHardwareType) = getHardwareId(from: peripheralName)
                if machineHardwareType == "Normal" {
                    hardwareID = Int(stringHardwareId)
                    if hardWareIdArray.contains(hardwareID!) {
                        
                    }
                    else {
                        Thread.sleep(forTimeInterval: 1.0)
                        hardWareIdArray.append(hardwareID!)
                        peripheralArray.append(peripheral)
                        self.machineInfoApiCalled(machinHardwareType: machineHardwareType, hardwareId: hardwareID!, perpheralName: peripheral)
                    }
                    if hardWareIdArray.count == 1 {
                        searchingMachineLabel.text = "1  Machine found"
                    }
                    else {
                        searchingMachineLabel.text = "\(String(hardWareIdArray.count)) Machines found"
                    }
                    //                if peripheralArray.contains(peripheral) {
                    //                    print("Already there")
                    //                }
                    //                else {
                    //                    peripheralArray.append(peripheral)
                    //                }
                    //                buttonRefresh.layer.removeAllAnimations()
                    if peripheralArray.count == 1 {
                        self.respondToSwipeGesture()
                    }
                    //                machineInfoApiCalled(machinHardwareType: machineHardwareType)
                    //                centralManager.connect(peripheral, options: nil)
                }
                else {
                    print("Security or Crypto type")
                }
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([ServiceUUID])
        peripheral.delegate = self
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {return}
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
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
                if commandsHandled == false {
                    commandsHandled = true
                    self.handleCommands()
                }
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic == writeCharacterstic {
//            let recievedString = String(data: characteristic.value!, encoding: String.Encoding.utf8)
            if let recievedValue = characteristic.value {
                if let recievedString = String.init(data: recievedValue, encoding: .ascii) {
                    switch typeOfCommand {
                    case .crypto:
                        self.handleCryptoResponse(recievedString: recievedString)
                    case .transactionHandshake:
                        self.handleTransactionHandshakeResponse(recievedString: recievedString)
                    case .clearTransaction:
                        self.handleClearTransactionResponse(recievedString: recievedString)
                    case .eventHandshake:
                        self.handleEventHandshakeResponse(recievedString: recievedString)
                    case .clearEvent:
                        typeOfCommand = .inventoryInfo
                        self.handleCommands()
                    case .inventoryInfo:
                        let myArray = [UInt8](characteristic.value!)
                        self.handleInventoryHandshake(recievedArray: myArray)
                    }
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            peripheral.readValue(for: characteristic)
    }
    
    func handleCommands() {
//        machinePerpheral!.writeValue(Data("@P$".utf8), for: writeCharacterstic!, type: CBCharacteristicWriteType.withResponse)
        switch typeOfCommand {

        case .crypto:
            machinePerpheral!.writeValue(Data("@D\(self.systemDate)$".utf8), for: writeCharacterstic!, type: CBCharacteristicWriteType.withResponse)
//            print("Crypto Command Sent : ","@D\(self.systemDate)$" )
        case .transactionHandshake:
            if CommonController.shared.machineHardwareType == "Normal" {
                machinePerpheral!.writeValue(Data("@H$".utf8), for: writeCharacterstic!, type: CBCharacteristicWriteType.withResponse)
                print("Transaction Handshake Command:","@H$")
            }
            else {
                machinePerpheral!.writeValue(Data("@HTXNHX$".utf8), for: writeCharacterstic!, type: CBCharacteristicWriteType.withResponse)
                print("Transaction Handshake Command:","@HTXNHX$")
            }
        case .clearTransaction:
            if CommonController.shared.machineHardwareType == "Normal" {
                machinePerpheral!.writeValue(Data("@HCLEAR$".utf8), for: writeCharacterstic!, type: CBCharacteristicWriteType.withResponse)
                print("Clear Transaction Handshake Command:","@HCLEAR$")
            }
            else {
                machinePerpheral!.writeValue(Data("@HTXNCLEAR$".utf8), for: writeCharacterstic!, type: CBCharacteristicWriteType.withResponse)
                 print("Clear Transaction Handshake Command:","@HTXNCLEAR$")
            }
        case .eventHandshake:
            machinePerpheral!.writeValue(Data("@E$".utf8), for: writeCharacterstic!, type: CBCharacteristicWriteType.withResponse)
            print("Event Handshake:", "@E$" )
        case .clearEvent:
            machinePerpheral!.writeValue(Data("@ECLEAR$".utf8), for: writeCharacterstic!, type: CBCharacteristicWriteType.withResponse)
//            print("Clear Event:", "@ECLEAR$")
        case .inventoryInfo:
            machinePerpheral!.writeValue(Data("@P$".utf8), for: writeCharacterstic!, type: CBCharacteristicWriteType.withResponse)
            print("Bluetooth get inventory :", "@P$")
        }
    }
    
    func handleCryptoResponse(recievedString : String) {
        if recievedString == "*U" {
            nextIsCrypto = true
        }
        else if recievedString == "#" {
//            print("Crypto Combined Response ", "*U\(recievedCryptoString)#")
            CommonController.shared.crypto = recievedCryptoString
            Thread.sleep(forTimeInterval: 0.5)
            typeOfCommand = .transactionHandshake
            self.handleCommands()
            return
        }
        else {
            if nextIsCrypto == true {
                recievedCryptoString = recievedString
                nextIsCrypto = false
            }
        }
    }
    
    func handleTransactionHandshakeResponse(recievedString : String) {
        if recievedString == "*H" {
            nextIsHandshake = true
            Thread.sleep(forTimeInterval: 0.1)
        }
        else if recievedString == "#" {
            if handshakeResponse == "" {
                print("Transaction Handshake Combined Response")
                print("*H\(handshakeResponse)#")
                Thread.sleep(forTimeInterval: 0.5)
                self.typeOfCommand = .eventHandshake
                self.handleCommands()
            }
            else {
                print("Transaction Handshake Combined Response")
                print("*H\(handshakeResponse)#")
                self.transactionHandshakeApi()
//                self.typeOfCommand = .clearTransaction
//                self.handleCommands()
            }
            return
        }
        else {
            if nextIsHandshake == true {
                if recievedString.count == 5 {

                }
                else {
                    handshakeResponse = recievedString
                    nextIsHandshake = false
                }
            }
        }
    }
    
    func handleClearTransactionResponse(recievedString : String) {
        if recievedString == "*HCLEARED#" {
            print("*HCLEARED#")
            Thread.sleep(forTimeInterval: 0.5)
            typeOfCommand = .eventHandshake
            self.handleCommands()
        }
    }
    
    func handleEventHandshakeResponse(recievedString : String) {
        if recievedString == "*E" {
            nextIsEvent = true
        }
        else if recievedString == "#" {
            if eventResponse == "" {
                print("Event handshake Response")
                print("*E#")
                Thread.sleep(forTimeInterval: 0.5)
                self.typeOfCommand = .inventoryInfo
                self.handleCommands()
            }
            else {
                print("Event handshake Response")
                print( "*E#")
                self.eventHandshakeApi()
//                self.typeOfCommand = .clearEvent
//                self.handleCommands()
            }
            return
        }
        else {
            if nextIsEvent == true {
                eventResponse = recievedString
                nextIsEvent = false
            }
        }
    }
    
    func handleInventoryHandshake(recievedArray : [UInt8]) {
        print(recievedArray)
        if recievedArray[0] == 42 && recievedArray[1] == 80 {
            nextIsInventoryInfo = true
            byteArray = byteArray + recievedArray
        }
        else if recievedArray[recievedArray.count - 1] == 35 {
            nextIsInventoryInfo = false
            byteArray = byteArray + recievedArray
            self.decodeInventoryInfo()
        }
        else {
            if nextIsInventoryInfo {
                byteArray = byteArray + recievedArray
            }
        }
    }
    
    func decodeInventoryInfo() {
        // - Finding index of 10 consecutive zeroes
        print("Bluetooth Inventory Response", byteArray)
        var zeroCount = 0
        for i in 0..<byteArray.count {
            if byteArray[i] == 0 {
                zeroCount += 1
                if zeroCount == 10 {
                    cutIndex = i - 9
                    break
                }
            }
            else {
                zeroCount = 0
            }
        }
        // - Cutting the array from the first index of ten consecutive 0
        var newByteArray : [UInt8] = []
        for i in 2..<cutIndex! {
            newByteArray.append(byteArray[i])
        }
        // - Checking if length is not multiple 10
        if newByteArray.count % 10 != 0 {
            let remainder = newByteArray.count % 10
            for i in newByteArray.count..<newByteArray.count + 11 - remainder {
                newByteArray[i] = 0
            }
        }
        // - MAking model/list
        var i = 0
        while i < newByteArray.count {
            let singleResponse = MachineDetails()
            var cellNumber = String(bytes: newByteArray[(i+1)..<(i+4)], encoding: .utf8)
            let fourthElement = Int(newByteArray[i+4] & 0b11111111)
            let fifthElement = Int(newByteArray[i+5] & 0b11111111)
            let sixthElement = Int(newByteArray[i+6] & 0b11111111)
            let seventhElement = Int(newByteArray[i+7] & 0b11111111)
            if let kCellNumber = cellNumber {
//                let numberString = "00123456"
//                let numberAsInt = Int(numberString)
//                let backToString = "\(numberAsInt!)"
                let clean = kCellNumber.replacingOccurrences(of: "^0*", with: "", options: .regularExpression)
                cellNumber = clean
            }
//            let productId = ((newByteArray[i+4] & 0b11111111) << 24) + ((newByteArray[i+5] & 0b11111111) << 16) + ((newByteArray[i+6] & 0b11111111) << 8) + (newByteArray[i+7] & 0b11111111)
            let productId = (fourthElement << 24) + (fifthElement << 16) + (sixthElement << 8) + seventhElement
            let quantity = newByteArray[i+8]
            let status = newByteArray[i+9]
            singleResponse.cellNumber = cellNumber
            singleResponse.productID = String(productId)
            singleResponse.maxQuantity = String(quantity)
            singleResponse.status = String(status)
            bluetoothInventory.append(singleResponse)
            i += 10
        }
        
        // - Making map/dictionary
        
        for i in 0..<bluetoothInventory.count {
            var cellArray = [String]()
            if bluetoothInventory[i].status == "1" && bluetoothInventory[i].maxQuantity! > "0" {
                let intMaxQuantity = Int(bluetoothInventory[i].maxQuantity!)
                for _ in 0..<intMaxQuantity! {
                    cellArray.append(bluetoothInventory[i].cellNumber!)
                }
            }
            if cellArray != [] {
                inventoryMap[bluetoothInventory[i].productID!] = cellArray
            }
        }
        let vc = MachineDetailsVC()
        vc.inventoryMap = self.inventoryMap
        vc.machineID = self.localMachineId
//        if !(self.navigationController!.viewControllers.contains(vc)){
//            self.navigationController?.pushViewController(vc, animated:true)
//            print("Executed")
//        }
        if !pushDone {
            if CommonController.shared.selectionFlow == "0" {
                vc.machineID = self.localMachineId
                let vc = NoSelectionFlowVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            pushDone = true
            Thread.sleep(forTimeInterval: 1)
        }
    }
    
    func getHardwareId(from peripheralName : String) -> (String , String) {
        if (peripheralName.range(of: "VENDOUR-V3P0-VENDING-2-") != nil) {
            return (peripheralName.replacingOccurrences(of: "VENDOUR-V3P0-VENDING-2-", with: ""),"Security")
        }
        else if (peripheralName.range(of: "VENDOUR-V3P0-VENDING-") != nil) {
            return (peripheralName.replacingOccurrences(of: "VENDOUR-V3P0-VENDING-", with: ""),"Crypto")
        }
        else {
            return (peripheralName.replacingOccurrences(of: "VENDOUR-V3P0-", with: ""),"Normal")
        }
    }
    
    func isVendourMachine(peripheralName : String) -> Bool {
        if (peripheralName.range(of: "VENDOUR-V3P0-") != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    func transactionHandshakeApi() {
        let serviceName = getFullServiceUrl(serviceName: "/api/v1/transaction/handshake/")
        let params : [String : Any] = [
            "hardware_id" : selectedHardwareId!,
            "transactions" : self.handshakeResponse
        ]
        print("Transaction Handshake API",serviceName)
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    Thread.sleep(forTimeInterval: 0.5)
                    self.handshakeResponse = ""
                    self.typeOfCommand = .clearTransaction
                    self.handleCommands()
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
    
    func eventHandshakeApi() {
        let serviceName = getFullServiceUrl(serviceName: "/api/v1/events/handshake/")
        let params : [String : Any] = [
            "hardware_id" : selectedHardwareId!,
            "events" : self.eventResponse
        ]
//        print("Event handshake API", serviceName)
//        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
//                print(json)
                let message = json["message"].stringValue
                if response.response?.statusCode == 200 {
                    self.typeOfCommand = .clearEvent
                    self.handleCommands()
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
    
    func machineInfoApiCalled(machinHardwareType : String, hardwareId : Int, perpheralName : CBPeripheral) {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/v1/machine/info/")
        let params : [String : Int] = ["hardware_id" : hardwareID!]
        print("Machine Info API", serviceName)
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                if response.response?.statusCode == 200 {
//                    self.hardWareIdArray.append(self.hardwareID!)
//                    self.peripheralArray.append(perpheralName)
//                    if self.hardWareIdArray.count == 1 {
//                        self.searchingMachineLabel.text = "1  Machine found"
//                    }
//                    else {
//                        self.searchingMachineLabel.text = "\(String(self.hardWareIdArray.count)) Machines found"
//                    }
//                    if self.peripheralArray.count == 1 {
//                        self.respondToSwipeGesture()
//                    }
                    let response = json["response"]
                    let singleMachineInfo = MachineInfo(with: response)
                    singleMachineInfo.machineHardwareType = machinHardwareType
                    self.machineInfoArray.append(singleMachineInfo)
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
                    self.hardWareIdArray.remove(at: self.hardWareIdArray.count - 1)
                    self.peripheralArray.remove(at: self.peripheralArray.count - 1)
                    if self.hardWareIdArray.count == 1 {
                        self.searchingMachineLabel.text = "1  Machine found"
                    }
                    else {
                        self.searchingMachineLabel.text = "\(String(self.hardWareIdArray.count)) Machines found"
                    }
                }
            }
            else {
                self.errorMessage(message: "No Internet Connection")
            }
            self.machineInfoCollectionView.reloadData()
            CommonController.shared.hideHud()
        }
    }
}

extension HomeScreen : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchProductArray.count == 0 {
            tableView.isHidden = true
        }
        else {
            tableView.isHidden = false
        }
        return searchProductArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchItemCell") as! SearchItemCell
        cell.itemName.text = searchProductArray[indexPath.row].productName
        cell.itemImage.sd_setImage(with: URL(string: searchProductArray[indexPath.row].productImage!), completed: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchEnabled = true
        searchTf.text = searchProductArray[indexPath.row].productName
        searchCrossBtn.isHidden = false
        searchTf.isEnabled = false
        tableView.isHidden = true
        self.getMachineApi(with: searchProductArray[indexPath.row].productId!)
        searchProductArray.removeAll()
        tableView.reloadData()
    }
    
    
    
    func searchProductApi(recievedString : String) {
        CommonController.shared.showHud(title: "", sender: self.view)
        let serviceName = getFullServiceUrl(serviceName: "/api/v1/products/search/?product_name=\(recievedString)")
        print("Search Product API",serviceName)
        Alamofire.request(serviceName, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                print(json)
                let jsonResponse = json["response"]
                if response.response?.statusCode == 200 {
                    for i in 0..<jsonResponse.count {
                        let singleResponse = SearchProduct.init(with: jsonResponse[i])
                        self.searchProductArray.append(singleResponse)
                    }
                    self.tableView.reloadData()
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
                    
                }
            }
            else {
                CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "No Internet Conenction")
            }
            CommonController.shared.hideHud()
        }
        print(searchProductArray.count)
    }
    
    func getMachineApi(with productId : String) {
        let serviceName = getFullServiceUrl(serviceName: "/api/vendour/v1/machines/products/\(productId)/")
        let params = [
            "machines" : machineIdArray
        ]
        print("Get machine API", serviceName)
        print(params)
        Alamofire.request(serviceName, method: .post, parameters: params, encoding: JSONEncoding.default, headers: CommonController.shared.getHeadersForAuthenticatedUser()).responseJSON { (response) in
            if response.result.isSuccess {
                let json = response.result.value as! [String : Any]
                print(json)
                let message = json["message"] as! String
                if response.response?.statusCode == 200 {
                    let jsonResponse = json["response"] as! [Int]
                    self.searchMachineIdArray = jsonResponse
                    self.generateSearchMarkers()
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
    
    func generateSearchMarkers() {
        for i in 0..<arrayMachinesNearBy.count {
            if searchMachineIdArray.contains(arrayMachinesNearBy[i].id){
                markers[i].icon =  UIImage(named: "map_point_stroke")
                
            }
            else {
                markers[i].icon =  UIImage(named: "grayMarker")
//                markers[i].icon = [self]
            }
        }
    }
    
    func navigateToGoogleMaps(with latitude : Double, longitude : Double){
        let url = URL(string: "comgooglemaps://?center=&zoom=10&views=&saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving")
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }else{
            CommonController.shared.ShowAlert(self, msg_title: "Vendour", message_heading: "Google maps are not installed in this devices.")
        }
    }
}


class SearchProduct {
    var productName : String?
    var productImage : String?
    var productId : String?
    init() {}
    init(with json : JSON) {
        productName = json["_source"]["product_name"].stringValue
        productImage = json["_source"]["image"].stringValue
        productId = json["_source"]["id"].stringValue
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
