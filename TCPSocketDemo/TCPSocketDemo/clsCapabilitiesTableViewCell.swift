//
//  clsCapabilitiesTableViewCell.swift
//  TCPSocketDemo
//
//  Created by Ravi Jayaraman on 22/07/18.
//  Copyright © 2018 Vivek Gajbe. All rights reserved.
//

import UIKit

class clsCapabilitiesTableViewCell: UITableViewCell {

    //Outlet declaration
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
