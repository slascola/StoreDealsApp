//
//  SchoolClass.swift
//  FinalProject436
//
//  Created by Megan Pieczynski on 2/28/18.
//  Copyright © 2018 Megan Pieczynski. All rights reserved.
//

import Foundation
import MapKit
import FirebaseDatabase

class StoresClass : NSObject, MKAnnotation {
    
    let ref: DatabaseReference?
    var name : String?
    var latitude : Double?
    var longitude : Double?
    var address : String?
   
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
    }
        
    
        
    init(name: String, latitude: Double, longitude: Double, address: String) {
            self.name = name
            self.latitude = latitude
            self.longitude = longitude
            self.address = address
            self.ref = nil
        }
    
    init(key: String,snapshot: DataSnapshot) {
        name = key
        
        let snaptemp = snapshot.value as! [String : AnyObject]
        let snapvalues = snaptemp[key] as! [String : AnyObject]
        
        name = snapvalues["name"] as? String ?? "N/A"
        latitude = snapvalues["latitude"] as? Double ?? 0.0
        longitude = snapvalues["longitude"] as? Double ?? 0.0
        address = snapvalues["address"] as? String ?? "N/A"
        
        ref = snapshot.ref
        
        super.init()
        
    }
    
    init(snapshot: DataSnapshot) {
        name = snapshot.key
        let snaptemp = snapshot.value as! [String : AnyObject]
        
        name = snaptemp["name"] as? String
        latitude = snaptemp["latitude"] as? Double ?? 0.0
        longitude = snaptemp["longitude"] as? Double ?? 0.0
        address = snaptemp["address"] as? String
        
        ref = snapshot.ref
        
    }
    
}

