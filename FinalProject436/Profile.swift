//
//  Profile.swift
//  FinalProject436
//
//  Created by Megan Pieczynski on 3/9/18.
//  Copyright © 2018 Megan Pieczynski. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Profile : NSObject {
    
    var savedStores : [Stores.detailedStore]
    var blockedStores : [Stores.detailedStore]
    var coupons : [Stores.detailedStore.Coupons]
    var name : String?
    //var image : URL
    var ref: DatabaseReference?
    
    init(savedStores: [Stores.detailedStore], blockedStores: [Stores.detailedStore], coupons: [Stores.detailedStore.Coupons], name: String) {
        self.savedStores = savedStores
        self.blockedStores = blockedStores
        self.coupons = coupons
        self.name = name
        self.ref = nil
    }
    
}

