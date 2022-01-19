//
//  ManageDeviceCell.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 19/01/22.
//

import UIKit

class ManageDeviceCell: UITableViewCell {

    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblNCDCode: UILabel!
    @IBOutlet weak var lblUsageLabel: UILabel!
    @IBOutlet weak var lblUsage: UILabel!
    @IBOutlet weak var lblDose: UILabel!
    @IBOutlet weak var lblNoOfDose: UILabel!
    @IBOutlet weak var btnRemoveDevice: UIButton!
    @IBOutlet weak var btnEditDirection: UIButton!
    
    @IBOutlet weak var ivInhaler: UIImageView!
    @IBOutlet weak var ivDescription: UIImageView!
    @IBOutlet weak var ivDose: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
