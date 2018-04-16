//
//  PersonalSettingsViewController.swift
//  FinalProject436
//
//  Created by Megan Pieczynski on 3/12/18.
//  Copyright © 2018 Megan Pieczynski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PersonalSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var savedCouponsHeading: UILabel!
    
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var savedStoresHeading: UILabel!
    
    @IBOutlet weak var blockedStoresHeading: UILabel!
    @IBOutlet weak var tableView2: UITableView!
    
    @IBOutlet weak var tableView3: UITableView!
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
       
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    let ref =  Database.database().reference()
    let userRef = Auth.auth().currentUser
    var mySavedStores = [String]()
    var myBlockedStores = [String]()
    var mySavedCoupons = [String:String]()
    
    override func viewDidLoad() {
         super.viewDidLoad()
         navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : hexStringToUIColor(hex: "#FFFFFF"), NSAttributedStringKey.font: UIFont(name: "Kefa", size: 20)!]
        
        ref.child("users").child(userRef!.uid).observe(.value, with: { snapshot in
            let savedDict = snapshot.value as! NSDictionary
            let savedStores = savedDict["Saved Stores"] as! NSArray
            let newStores = savedStores as! [String]
            self.mySavedStores = newStores
            
            self.tableView1.reloadData()
            
        })
        
        ref.child("users").child(userRef!.uid).observe(.value, with: { snapshot in
            let blockedDict = snapshot.value as! NSDictionary
            let blockedStores = blockedDict["Blocked Stores"] as! NSArray
            let newStores = blockedStores as! [String]
            self.myBlockedStores = newStores
            
            self.tableView2.reloadData()
            
        })
        
        ref.child("users").child(userRef!.uid).observe(.value, with: { snapshot in
            let couponDict = snapshot.value as! NSDictionary
            let coupons = couponDict["Saved Coupons"] as! NSDictionary
            let newCoupons = coupons as! [String:String]
            self.mySavedCoupons = newCoupons
            
            self.tableView3.reloadData()
            
        })

        self.tableView1.layer.borderWidth = 2.0
        self.tableView2.layer.borderWidth = 2.0
        self.tableView3.layer.borderWidth = 2.0
        self.tableView1.backgroundColor = hexStringToUIColor(hex: "#F4EDE9")
        self.tableView2.backgroundColor = hexStringToUIColor(hex: "#F4EDE9")
        self.tableView3.backgroundColor = hexStringToUIColor(hex: "#F4EDE9")
        
        self.view.backgroundColor = hexStringToUIColor(hex: "#F4EDE9")
        savedStoresHeading.textColor = hexStringToUIColor(hex: "#572219")
        blockedStoresHeading.textColor = hexStringToUIColor(hex: "#572219")
        savedCouponsHeading.textColor = hexStringToUIColor(hex: "#572219")
        savedStoresHeading.font = UIFont.boldSystemFont(ofSize: 16.0)
        blockedStoresHeading.font = UIFont.boldSystemFont(ofSize: 16.0)
        savedCouponsHeading.font = UIFont.boldSystemFont(ofSize: 16.0)

        // Do any additional setup after loading the view.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
   
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if (tableView == self.tableView1){
            if (mySavedStores.count == 0) {
                return 0
            }
            else {
                return mySavedStores.count
            }
        }
        else if (tableView == self.tableView2) {
            if (myBlockedStores.count == 0) {
                return 0
            }
            else {
                return myBlockedStores.count
            }
        }
        else if (tableView == self.tableView3) {
            if (mySavedCoupons.count == 0) {
                return 0
            }
            else {
                return mySavedCoupons.count
            }
        }
        else {
            return 1
        }
      
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = hexStringToUIColor(hex: "EADBCF")
        }
        else {
            cell.backgroundColor = hexStringToUIColor(hex: "F4EDE9")
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
        
       if (tableView == self.tableView1) {
           let cell = tableView.dequeueReusableCell(withIdentifier: "savedCell", for: indexPath) as? SavedTableViewCell
            let row = indexPath.row
            if (mySavedStores[row] != "temp") {
                cell?.savedStoreLabel.text = mySavedStores[row]
            }
            else {
               cell?.savedStoreLabel.text = ""
            }
            return cell!
        }
        else if (tableView == self.tableView3) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "couponCell", for: indexPath) as? CouponTableViewCell
            let row = indexPath.row
            let keyName = Array(mySavedCoupons.keys)[row]
            if (keyName != "temp") {
                cell?.couponNameLabel.text = keyName
                cell?.expDateLabel.text = mySavedCoupons[keyName]
            }
            else {
                 cell?.couponNameLabel.text = ""
                 cell?.expDateLabel.text = ""
            }
            return cell!
        }
       else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "blockedCell", for: indexPath) as? BlockedTableViewCell
            let row = indexPath.row
            if (myBlockedStores[row] != "temp") {
                cell?.blockedLabel.text = myBlockedStores[row]
            }
            else {
                cell?.blockedLabel.text = ""
            }
            return cell!
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let ref =  Database.database().reference()
        let userRef = Auth.auth().currentUser
        let filterQuery = ref.child("users").child(userRef!.uid)
        
        if editingStyle == .delete {
            if tableView == self.tableView1 {
                filterQuery.observeSingleEvent(of: .value, with: {(snapshot) in
                    let retrieveDict = snapshot.value as! NSDictionary
                    let savedArray = retrieveDict["Saved Stores"] as! NSArray
                    var newSavedStores = [String]()
                    for i in 0 ..< savedArray.count {
                        print(savedArray[i])
                        if (savedArray[i] as! String) == self.mySavedStores[indexPath.row] {
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
                    self.mySavedStores = newSavedStores
                    ref.child("users").child(userRef!.uid).updateChildValues(["Saved Stores": self.mySavedStores])
                    self.tableView1.reloadData()
                })
            }
            else if (tableView == self.tableView2) {
                filterQuery.observeSingleEvent(of: .value, with: {(snapshot) in
                    let retrieveDict = snapshot.value as! NSDictionary
                    let blockedArray = retrieveDict["Blocked Stores"] as! NSArray
                    var newBlockedStores = [String]()
                    for i in 0 ..< blockedArray.count {
                        
                        if (blockedArray[i] as! String) == self.myBlockedStores[indexPath.row] {
                        }
                        else if (blockedArray[i] as! String) == "temp" {
                            
                        }
                        else {
                            newBlockedStores.append(blockedArray[i] as! String)
                        }
                    }
                    if (newBlockedStores.count == 0) {
                        newBlockedStores.append("temp")
                    }
                    self.myBlockedStores = newBlockedStores
                    ref.child("users").child(userRef!.uid).updateChildValues(["Blocked Stores": self.myBlockedStores])
                    self.tableView2.reloadData()
                })
            }
           
        }
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
