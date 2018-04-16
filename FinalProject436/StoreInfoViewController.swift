//
//  StoreInfoViewController.swift
//  FinalProject436
//
//  Created by Local Account 436-03 on 2/28/18.
//  Copyright © 2018 Megan Pieczynski. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import GeoFire
import CoreLocation

class StoreInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var savedStores = [String]()
    var blockedStores = [String]()
    var mySavedCoupons = [String:String]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    @IBOutlet weak var addressView: UITextView!
    
    @IBOutlet weak var websiteView: UITextView!
    
    @IBOutlet weak var block: UIButton!
    
    @IBOutlet weak var save: UIButton!
   
    
    @IBAction func SaveStore(_ sender: UIButton) {
        //query firebase using snapshot
        let ref =  Database.database().reference()
        let userRef = Auth.auth().currentUser
        let filterQuery = ref.child("users").child(userRef!.uid)
        filterQuery.observeSingleEvent(of: .value, with: {(snapshot) in
            let retrieveDict = snapshot.value as! NSDictionary
            let savedArray = retrieveDict["Saved Stores"] as! NSArray
            
            var val = 0;
            for i in 0 ..< savedArray.count {
                if (savedArray[i] as! String) == self.storeName! {
                    val = 1; break
                }
                else if (savedArray[i] as! String) == "temp" {
                       self.savedStores = self.savedStores.filter{$0 != "temp"}
                }
                else {
                    if (self.savedStores.contains(savedArray[i] as! String) == false) {
                        self.savedStores.append(savedArray[i] as! String)
                    }
               
                }
            }
      
            if val != 1 {
                self.savedStores.append(self.storeName)
                ref.child("users").child(userRef!.uid).updateChildValues(["Saved Stores": self.savedStores])
            }
        })
        filterQuery.observeSingleEvent(of: .value, with: {(snapshot) in
            let retrieveDict = snapshot.value as! NSDictionary
            let blockedArray = retrieveDict["Blocked Stores"] as! NSArray
            
            for i in 0 ..< blockedArray.count {
                if (blockedArray[i] as! String) == self.storeName! {
                    self.blockedStores = self.blockedStores.filter{$0 != self.storeName}; break
                }
                else if (blockedArray[i] as! String) == "temp" {
                    
                }
                else {
                    if (self.blockedStores.contains(blockedArray[i] as! String) == false) {
                        self.blockedStores.append(blockedArray[i] as! String)
                    }
                    
                }
            }
            if (self.blockedStores.count == 0) {
                self.blockedStores.append("temp")
            }
            ref.child("users").child(userRef!.uid).updateChildValues(["Blocked Stores": self.blockedStores])
        })
        
    }
    
    @IBAction func BlockStore(_ sender: UIButton) {
        //query firebase using snapshot
       
        let ref =  Database.database().reference()
        let userRef = Auth.auth().currentUser
        let filterQuery = ref.child("users").child(userRef!.uid)
        filterQuery.observeSingleEvent(of: .value, with: {(snapshot) in
            let retrieveDict = snapshot.value as! NSDictionary
            let blockedArray = retrieveDict["Blocked Stores"] as! NSArray

            var val = 0;
            for i in 0 ..< blockedArray.count {
                if (blockedArray[i] as! String) == self.storeName! {
                    val = 1; break
                }
                else if (blockedArray[i] as! String) == "temp" {
                    self.blockedStores = self.blockedStores.filter{$0 != "temp"}
                }
                else {
                    if (self.blockedStores.contains(blockedArray[i] as! String) == false) {
                        self.blockedStores.append(blockedArray[i] as! String)
                    }
                }

            }
            if val != 1 {
                self.blockedStores.append(self.storeName)
                ref.child("users").child(userRef!.uid).updateChildValues(["Blocked Stores": self.blockedStores])
            }
        })
        filterQuery.observeSingleEvent(of: .value, with: {(snapshot) in
            let retrieveDict = snapshot.value as! NSDictionary
            let savedArray = retrieveDict["Saved Stores"] as! NSArray
            var newSavedStores = [String]()
            for i in 0 ..< savedArray.count {
                if (savedArray[i] as! String) == self.storeName! {
                }
                else if (savedArray[i] as! String) == "temp" {
                    
                }
                else {
                    newSavedStores.append(savedArray[i] as! String)
                }
            }
            if (newSavedStores.count == 0) {
                newSavedStores.append("temp")
            }
            self.savedStores = newSavedStores
            ref.child("users").child(userRef!.uid).updateChildValues(["Saved Stores": self.savedStores])
        })
    }
    var storeName : String!
    var website : String?
    var location : String?
    var lat : Double?
    var lon : Double?
    var curLat : Double?
    var curLon : Double?
    var ourCoupons = [Stores.detailedStore.Coupons]()
    var ref : DatabaseReference?
    var geoFire : GeoFire?
    var regionQuery : GFRegionQuery?
    let startingLoc = CLLocationCoordinate2D(latitude: 35.279871, longitude: -120.6635881)
    let locationManager = CLLocationManager()
    
    @IBAction func getDirections(_ sender: AnyObject) {
        if (curLat != nil) {
            let curLoc = CLLocationCoordinate2D(latitude: curLat!, longitude: curLon!)
            let storeLoc = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            let startLocPlacemark = MKPlacemark(coordinate: curLoc)
            let storeLocPlacemark = MKPlacemark(coordinate: storeLoc)
            
            let currentMapItem = MKMapItem(placemark: startLocPlacemark)
            let storeMapItem = MKMapItem(placemark: storeLocPlacemark)
            
            let mapItems = [currentMapItem,storeMapItem]
            let directionOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
            MKMapItem.openMaps(with: mapItems, launchOptions: directionOptions)
        }
    }
    
    override func viewDidLoad() {
        block.layer.borderWidth = 2.0
        block.layer.cornerRadius = 4.0
        save.layer.borderWidth = 2.0
        save.layer.cornerRadius = 4.0
        self.addressView.backgroundColor = hexStringToUIColor(hex: "#F4EDE9")
        self.websiteView.backgroundColor = hexStringToUIColor(hex: "#F4EDE9")
        self.tableViewOutlet.backgroundColor = hexStringToUIColor(hex: "#F4EDE9")
        self.tableViewOutlet.layer.borderWidth = 2.0
        super.viewDidLoad()
        self.title = storeName
        addressView.text = "Location: " + location!
        websiteView.text = "http://" + website!
        self.view.backgroundColor = hexStringToUIColor(hex: "#F4EDE9")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : hexStringToUIColor(hex: "#FFFFFF"), NSAttributedStringKey.font: UIFont(name: "Kefa", size: 20)!]
    
        ref = Database.database().reference().child("Stores")
        geoFire = GeoFire(firebaseRef: Database.database().reference().child("GeoFire"))
        configureLocationManager()
        
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        let newRegion = MKCoordinateRegion(center: startingLoc, span: span)
        mapView.setRegion(newRegion, animated: true)

        
        //oneTimeInit()
        
        // Do any additional setup after loading the view.
    }
    
    
    func configureLocationManager() {
        CLLocationManager.locationServicesEnabled()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 100.0
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        curLat = location.coordinate.latitude
        curLon = location.coordinate.longitude
    }


    
//    func oneTimeInit() {
//        ref?.queryOrdered(byChild: "Stores").observe(.value, with:
//            { snapshot in
//
//                var newStores = [StoresClass]()
//
//                for item in snapshot.children {
//                    newStores.append(StoresClass(snapshot: item as! DataSnapshot))
//
//
//                }
//
//                for next in newStores {
//                    self.geoFire?.setLocation(CLLocation(latitude:next.latitude!,longitude:next.longitude!), forKey: next.name!)
//
//                }
//        })
//    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        updateRegionQuery()
    }
    
    
    func updateRegionQuery() {
        if let oldQuery = regionQuery {
            oldQuery.removeAllObservers()
        }
        
        regionQuery = geoFire?.query(with: mapView.region)
        
        regionQuery?.observe(.keyEntered, with: { (key, location) in
            self.ref?.queryOrderedByKey().queryEqual(toValue: key).observe(.value, with: { snapshot in
                
            
                let newStore = StoresClass(key:key,snapshot:snapshot)
                self.addStore(newStore)
            })
        })
    }
    
    func addStore(_ store : StoresClass) {
        if store.name == storeName {
            DispatchQueue.main.async {
                self.mapView.addAnnotation(store)
            
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ourCoupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeInfoCell", for: indexPath) as! StoreInfoCell
        cell.savedCouponLabel.numberOfLines = 0
        cell.savedCouponLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.expDateLabel.numberOfLines = 0
        cell.expDateLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        let object = ourCoupons[indexPath.row]
        cell.couponNameLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        cell.couponNameLabel.text = object.couponName
        cell.expDateLabel.text = "Exp Date: " + object.expDate
        cell.savedCouponLabel.textColor = hexStringToUIColor(hex: "#9D4B4C")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        _ = tableView.dequeueReusableCell(withIdentifier: "storeInfoCell", for: indexPath) as! StoreInfoCell
        let object = ourCoupons[indexPath.row]
        
        let ref =  Database.database().reference()
        let userRef = Auth.auth().currentUser
        let filterQuery = ref.child("users").child(userRef!.uid).child("Saved Coupons")
        filterQuery.observeSingleEvent(of: .value, with: {(snapshot) in
            var val = 0
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                let value = snap.value as? String
                
                if (key == object.couponName) {
                    val = 1; break
                }
                else if (key == "temp") {
                    
                }
                else {
                    self.mySavedCoupons[key] = value
                    
                }

            }
            if (val != 1) {
                self.mySavedCoupons[object.couponName] = object.expDate
                 ref.child("users").child(userRef!.uid).updateChildValues(["Saved Coupons": self.mySavedCoupons])
                
            }
        })

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = hexStringToUIColor(hex: "EADBCF")
        }
        else {
            cell.backgroundColor = hexStringToUIColor(hex: "F4EDE9")
        }
        
    }
    
  
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.title!! == storeName {
            let annotationView = MKPinAnnotationView()
            annotationView.pinTintColor = .red
            annotationView.annotation = annotation
            annotationView.canShowCallout = true
            annotationView.animatesDrop = true
        
            return annotationView
        }
        
        return nil
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
