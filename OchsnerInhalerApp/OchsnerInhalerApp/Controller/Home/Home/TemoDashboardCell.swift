//
//  TemoDashboardCell.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 08/02/22.
//

import UIKit

class TemoDashboardCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNDCCode: UILabel!
    @IBOutlet weak var lblMacAddressLabel: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblBattery: UILabel!
    @IBOutlet weak var lblBatteryPercentage: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var lblMacAddress: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
