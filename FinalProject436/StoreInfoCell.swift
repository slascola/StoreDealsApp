//
//  StoreInfoCell.swift
//  FinalProject436
//
//  Created by Local Account 436-03 on 2/28/18.
//  Copyright © 2018 Megan Pieczynski. All rights reserved.
//

import UIKit
import GeoFire
import CoreLocation
import MapKit

class StoreInfoCell: UITableViewCell {

    @IBOutlet weak var couponNameLabel: UILabel!
    @IBOutlet weak var expDateLabel: UILabel!
    
    
    @IBOutlet weak var savedCouponLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
