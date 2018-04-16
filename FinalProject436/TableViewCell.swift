//
//  TableViewCell.swift
//  FinalProject436
//
//  Created by Megan Pieczynski on 2/25/18.
//  Copyright © 2018 Megan Pieczynski. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var storeLabel: UILabel!
    @IBOutlet weak var numDealsLabel: UILabel!
    
    @IBOutlet weak var milesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
