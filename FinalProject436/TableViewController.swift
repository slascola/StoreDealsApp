//
//  TableViewController.swift
//  FinalProject436
//
//  Created by Megan Pieczynski on 2/25/18.
//  Copyright © 2018 Megan Pieczynski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation
import UserNotifications


class TableViewController: UITableViewController, CLLocationManagerDelegate {

    var ourStores = [Stores.detailedStore]()
    var ref : DatabaseReference?
    let locationManager = CLLocationManager()
    var mySavedStores = [String]()
    var myBlockedStores = [String]()
    var filtered = [Stores.detailedStore]()
   
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : hexStringToUIColor(hex: "#FFFFFF"), NSAttributedStringKey.font: UIFont(name: "Kefa", size: 20)!]
         let ref1 =  Database.database().reference()
        let userRef = Auth.auth().currentUser
        ref1.child("users").child(userRef!.uid).observe(.value, with: { snapshot in
            let savedDict = snapshot.value as! NSDictionary
            let savedStores = savedDict["Saved Stores"] as! NSArray
            let newStores = savedStores as! [String]
            self.mySavedStores = newStores
            
        })
        
        ref1.child("users").child(userRef!.uid).observe(.value, with: { snapshot in
            let blockedDict = snapshot.value as! NSDictionary
            let blockedStores = blockedDict["Blocked Stores"] as! NSArray
            let newStores = blockedStores as! [String]
            self.myBlockedStores = newStores
            self.filtered = self.ourStores.filter{self.myBlockedStores.contains($0.name!) == false}
            self.tableView.reloadData()
        })
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                
        }
        )
        
        let button: UIButton = UIButton(type: UIButtonType.custom)
        button.setImage(UIImage(named: "profile.png"), for: UIControlState.normal)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        button.widthAnchor.constraint(equalToConstant: 47.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 47.0).isActive = true
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
       
        fillStores(lat:35.8050097, lon:-120.9646882)
        
        ref = Database.database().reference().child("Stores")
        
        for store in ourStores {
            let storeName = store.name
            self.ref!.child(storeName!).setValue(store.toAnyObject())
        }
        
        navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "#9D4B4C")
        self.tableView.backgroundColor = hexStringToUIColor(hex: "F4EDE9")
    }
    
    @objc func buttonAction(sender: UIButton!) {
        performSegue(withIdentifier: "personalSettingsSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        ourStores.removeAll()
        filtered.removeAll()
        fillStores(lat:lat, lon:lon)
        filtered = ourStores.filter{myBlockedStores.contains($0.name!) == false}
        tableView.reloadData()
        for store in ourStores {
            let storeLat = store.latitude
            let storeLon = store.longitude
            let storeName = store.name
            let firstCoupon = store.coupons[0].couponName
            if (mySavedStores.count != 0) {
                for s in mySavedStores {
                    if (s  == storeName) {
                        if (storeRange(storeLat: storeLat! , storeLon: storeLon!, curLat: lat, curLon: lon) != false) {
                            print(storeName!)
                            createNotification(name: storeName!, coupon: firstCoupon!)
                        }
                    }
                }
            }
            
        }
        
    }
    
    func storeRange(storeLat: Double, storeLon: Double, curLat: Double, curLon: Double) -> Bool {
        let coor1 = CLLocation(latitude: storeLat, longitude: storeLon)
        let coor2 = CLLocation(latitude: curLat, longitude: curLon)
        
        let distance = coor1.distance(from: coor2)
        
        if(distance <= 1609) {
            return true
        }
        else {
            return false
        }
    }
    
    func createNotification(name: String, coupon: String) {
        let content = UNMutableNotificationContent()
        content.title = "Fast Deals Update"
        content.subtitle = name
        content.body = coupon
        
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 2,
            repeats:false
        )
        
        let request = UNNotificationRequest(
            identifier: name,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(
            request, withCompletionHandler: nil)
    
    }
    
    func fillStores(lat:Double?, lon:Double?) {
        let sephoraLat = 35.2813459
        let sephoraLon = -120.6630879
        let sephoraMiles = calculateMilesAway(lat:lat, lon:lon, storeLat:sephoraLat, storeLon:sephoraLon)
        var sephoraCoupon = [Stores.detailedStore.Coupons]()
        sephoraCoupon.append(Stores.detailedStore.Coupons(name: "Free Trial Eye Cream", expDate: "NA"))
        sephoraCoupon.append(Stores.detailedStore.Coupons(name: "40% Off BECCA Coverage Concealer ", expDate: "NA"))
        sephoraCoupon.append(Stores.detailedStore.Coupons(name: "Free Trial Size Foundation ", expDate: "NA"))
        ourStores.append(Stores.detailedStore(name: "Sephora", numDeals: 3, milesAway: round(sephoraMiles * 10)/10, website: "sephora.com", latitude: sephoraLat, longitude: sephoraLon, address: "1090 Court St, San Luis Obispo, CA 93401", coupons: sephoraCoupon))
        
        let abLat = 35.281064
        let abLon = -120.6633454
        let abMiles = calculateMilesAway(lat:lat, lon:lon, storeLat:abLat, storeLon:abLon)
        var abCoupon = [Stores.detailedStore.Coupons]()
        abCoupon.append(Stores.detailedStore.Coupons(name: "All Jeans 50% Off", expDate: "Limited Time"))
        abCoupon.append(Stores.detailedStore.Coupons(name: "Women's Tees 2 for 30 dollars", expDate: "Beginning March 20 "))
        ourStores.append(Stores.detailedStore(name: "Abercrombie", numDeals: 2, milesAway: round(abMiles * 10)/10, website: "abercrombie.com", latitude: abLat, longitude: abLon, address: "980 Higuera St, San Luis Obispo, CA 93401", coupons: abCoupon))
        
        
        let exLat = 35.2802493
        let exLon = -120.6640401
        var exCoupon = [Stores.detailedStore.Coupons]()
        let exMiles = calculateMilesAway(lat:lat, lon:lon, storeLat:exLat, storeLon:exLon)
        exCoupon.append(Stores.detailedStore.Coupons(name: "All Men's Sweaters 40% Off", expDate: "3/26/18"))
        exCoupon.append(Stores.detailedStore.Coupons(name: "Women's Dresses 30% Off", expDate: "3/25/18"))
        exCoupon.append(Stores.detailedStore.Coupons(name: "Women's Tops BOGO 50%", expDate: "3/28/18"))
        ourStores.append(Stores.detailedStore(name: "Express", numDeals: 3, milesAway: round(exMiles * 10)/10, website: "express.com", latitude: exLat, longitude: exLon, address: "887 Higuera St, San Luis Obispo, CA 93401", coupons: exCoupon))
        
        let gapLat = 35.2800633
        let gapLon = -120.6641944
        let gapMiles = calculateMilesAway(lat:lat, lon:lon, storeLat:gapLat, storeLon:gapLon)
        var gapCoupon = [Stores.detailedStore.Coupons]()
        gapCoupon.append(Stores.detailedStore.Coupons(name: "40% Off Everything Code: SOGOOD", expDate: "Valid One Day Only 4/12/18"))
        ourStores.append(Stores.detailedStore(name: "Gap", numDeals: 1, milesAway: round(gapMiles * 10)/10, website: "gap.com", latitude: gapLat, longitude: gapLon, address: "879 Higuera St, San Luis Obispo, CA 93401", coupons: gapCoupon))
        
        let birkLat = 35.2795682
        let birkLon = -120.666151
        let birkMiles = calculateMilesAway(lat:lat, lon:lon, storeLat:birkLat, storeLon:birkLon)
        var birkCoupon = [Stores.detailedStore.Coupons]()
        birkCoupon.append(Stores.detailedStore.Coupons(name: "15% Off Birkenstock Leather", expDate: "4/1/18"))
        ourStores.append(Stores.detailedStore(name: "Birkenstock", numDeals: 1, milesAway: round(birkMiles * 10)/10, website: "birkenstock.com/us", latitude: birkLat, longitude: birkLon, address: "746 Higuera St, San Luis Obispo, CA 93401", coupons: birkCoupon))
        
        let bathLat = 35.2800504
        let bathLon = -120.6650303
        let bathMiles = calculateMilesAway(lat:lat, lon:lon, storeLat:bathLat, storeLon:bathLon)
        var bathCoupon = [Stores.detailedStore.Coupons]()
        bathCoupon.append(Stores.detailedStore.Coupons(name: "3 Wick Candles 12", expDate: "3/26/18"))
        bathCoupon.append(Stores.detailedStore.Coupons(name: "6 for 25 dollars - Hand Soaps", expDate: "3/24/18"))
        bathCoupon.append(Stores.detailedStore.Coupons(name: "3 for 12 dollars - Face Masks", expDate: "3/27/18"))
        bathCoupon.append(Stores.detailedStore.Coupons(name: "2 for 6 dollars - Creams", expDate: "3/29/18"))
        bathCoupon.append(Stores.detailedStore.Coupons(name: "2 for 18 dollars - Active Skincare", expDate: "4/4/18"))
        ourStores.append(Stores.detailedStore(name: "Bath & Body Works", numDeals: 5, milesAway: round(bathMiles * 10)/10, website: "bathandbodyworks.com", latitude: bathLat, longitude: bathLon, address: "842 Higuera St, San Luis Obispo, CA 93401", coupons: bathCoupon))
        
        let victLat = 35.2803355
        let victLon = -120.6615987
        let victMiles = calculateMilesAway(lat:lat, lon:lon, storeLat:victLat, storeLon:victLon)
        var victCoupon = [Stores.detailedStore.Coupons]()
        victCoupon.append(Stores.detailedStore.Coupons(name: "Free 20 dollar reward card", expDate: "5/6/18"))
        victCoupon.append(Stores.detailedStore.Coupons(name: "Panties 6 dollars", expDate: "4/16/18"))
        victCoupon.append(Stores.detailedStore.Coupons(name: "Favorite Bras 35 dollars", expDate: "4/2/18"))
        victCoupon.append(Stores.detailedStore.Coupons(name: "Free Bag with 50 dollar purchase", expDate: "3/25/18"))
        ourStores.append(Stores.detailedStore(name: "Victoria's Secret", numDeals: 4, milesAway: round(victMiles * 10)/10, website: "victoriassecret.com", latitude: victLat, longitude: victLon, address: "898 Higuera St, San Luis Obispo, CA 93401", coupons: victCoupon))
        
        let hmLat = 35.2802808
        let hmLon = -120.6619368
        let hmMiles = calculateMilesAway(lat:lat, lon:lon, storeLat:hmLat, storeLon:hmLon)
        var hmCoupon = [Stores.detailedStore.Coupons]()
        hmCoupon.append(Stores.detailedStore.Coupons(name: "70% off Women's wear", expDate: "3/26/18"))
        hmCoupon.append(Stores.detailedStore.Coupons(name: "30% off Beauty Products", expDate: "3/26/18"))
        ourStores.append(Stores.detailedStore(name: "H&M", numDeals: 2, milesAway: round(hmMiles * 10)/10, website: "hm.com", latitude: hmLat, longitude: hmLon, address: "886 Monterey St, San Luis Obispo, CA 93401", coupons: hmCoupon))
        
        let urbanLat = 35.2816843
        let urbanLon = -120.6629926
        let urbanMiles = calculateMilesAway(lat:lat, lon:lon, storeLat:urbanLat, storeLon:urbanLon)
        var urbanCoupon = [Stores.detailedStore.Coupons]()
        urbanCoupon.append(Stores.detailedStore.Coupons(name: "30% off all Dresses and Rompers", expDate: "3/28/18"))
        urbanCoupon.append(Stores.detailedStore.Coupons(name: "30% Curved Hem Tees", expDate: "4/2/18"))
        urbanCoupon.append(Stores.detailedStore.Coupons(name: "25% off Sandals", expDate: "4/16/18"))
        urbanCoupon.append(Stores.detailedStore.Coupons(name: "Women's tops 10 dollars", expDate: "3/29/18"))
        ourStores.append(Stores.detailedStore(name: "Urban Outfitters", numDeals: 4, milesAway: round(urbanMiles * 10)/10, website: "urbanoutfitters.com", latitude: urbanLat, longitude: urbanLon, address: "962 Monterey St, San Luis Obispo, CA 93401", coupons: urbanCoupon))
        
        
        ourStores = ourStores.sorted(by: {$0.milesAway! < $1.milesAway!})
        
    }
    
    func calculateMilesAway(lat:Double?, lon:Double?, storeLat:Double, storeLon:Double) -> Double {
        let coord1 = CLLocation(latitude: lat!, longitude: lon!)
        let coord2 = CLLocation(latitude: storeLat, longitude: storeLon)
        
        let distanceInMeters = coord1.distance(from: coord2)
        let distanceInMiles = distanceInMeters / 1609.34
        return distanceInMiles
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (myBlockedStores.count == 0) {
            return ourStores.count
        }
        else {
            return filtered.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! TableViewCell
        cell.storeLabel.numberOfLines = 0
        cell.storeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.storeLabel.textColor = hexStringToUIColor(hex: "#572219")
        cell.numDealsLabel.textColor = hexStringToUIColor(hex: "#572219")
        cell.milesLabel.textColor = hexStringToUIColor(hex: "#572219")
        // Configure the cell...
      
        if (myBlockedStores.count == 0) {
            let thisStore = ourStores[indexPath.row]
            cell.storeLabel?.text = thisStore.name
            cell.numDealsLabel?.text = String(describing: thisStore.numDeals!)
            cell.milesLabel?.text = String(describing: thisStore.milesAway!)
        }
        else {
            let thisStore = filtered[indexPath.row]
            cell.storeLabel?.text = thisStore.name
            cell.numDealsLabel?.text = String(describing: thisStore.numDeals!)
            cell.milesLabel?.text = String(describing: thisStore.milesAway!)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = hexStringToUIColor(hex: "EADBCF")
        }
        else {
            cell.backgroundColor = hexStringToUIColor(hex: "F4EDE9")
        }
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "storeSegue" {
            let destVC = segue.destination as! StoreInfoViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            if (myBlockedStores.count == 0) {
                destVC.ourCoupons = ourStores[(selectedIndexPath?.row)!].coupons
                destVC.storeName = ourStores[(selectedIndexPath?.row)!].name
                destVC.location = ourStores[(selectedIndexPath?.row)!].address
                destVC.website = ourStores[(selectedIndexPath?.row)!].website
                destVC.lat = ourStores[(selectedIndexPath?.row)!].latitude
                destVC.lon = ourStores[(selectedIndexPath?.row)!].longitude
                destVC.curLat = locationManager.location?.coordinate.latitude
                destVC.curLon = locationManager.location?.coordinate.longitude
            }
            else {
                destVC.ourCoupons = filtered[(selectedIndexPath?.row)!].coupons
                destVC.storeName = filtered[(selectedIndexPath?.row)!].name
                destVC.location = filtered[(selectedIndexPath?.row)!].address
                destVC.website = filtered[(selectedIndexPath?.row)!].website
                destVC.lat = filtered[(selectedIndexPath?.row)!].latitude
                destVC.lon = filtered[(selectedIndexPath?.row)!].longitude
                destVC.curLat = locationManager.location?.coordinate.latitude
                destVC.curLon = locationManager.location?.coordinate.longitude
            }
           
        }
    }
 

}
