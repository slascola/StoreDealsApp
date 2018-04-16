//
//  Stores.swift
//  FinalProject436
//
//  Created by Megan Pieczynski on 2/25/18.
//  Copyright © 2018 Megan Pieczynski. All rights reserved.
//

import Foundation
import MapKit

struct Stores : Codable {
    var downtownStores : [detailedStore]
    
    mutating func add(store: detailedStore) {
        downtownStores.append(store)
    }
    
    struct detailedStore: Codable {
        var name : String?
        var numDeals : Int?
        var milesAway : Double?
        var coupons = [Coupons]()
        var website : String?
        var latitude : Double?
        var longitude : Double?
        var address : String?
        
        
        struct Coupons : Codable {
            var couponName : String!
            var expDate : String!
            
            init(name: String, expDate: String) {
                self.couponName = name
                self.expDate = expDate
            }
            
            func retCouponName() -> String {
                let name = couponName
                return name!
            }
            
            func retExpDate() -> String {
                let exp = expDate
                return exp!
            }
            func fixCoupons() -> [String : String] {
                let finalReturn = [
                    "name" : couponName ?? "NA",
                    "expDate" : expDate ?? "NA"

            ]
                return finalReturn
            }
            
        }
    
    
        init(name: String, numDeals: Int, milesAway: Double, website: String, latitude: Double, longitude: Double, address: String, coupons: [Coupons]) {
            self.name = name
            self.numDeals = numDeals
            self.milesAway = milesAway
            self.website = website
            self.latitude = latitude
            self.longitude = longitude
            self.address = address
            self.coupons = coupons
        }
        func toAnyObject() -> Any {
          
            var newReturn = [
                "name" : name ?? "NA",
                "numDeals" : numDeals ?? 0,
                "milesAway" : milesAway ?? 0.0
                
                ] as [String : Any]
                newReturn["website"] = website ?? "NA"
                newReturn["latitude"] = latitude ?? 0.0
                newReturn["longitude"] = longitude ?? 0.0
                newReturn["address"] = address ?? "NA"
            
            var temp = [[String : String]]()
            for coupon in coupons {
                temp.append(coupon.fixCoupons())
            }
            newReturn["coupons"] = temp
            
            
            return newReturn
        }
    }
    
    
}

