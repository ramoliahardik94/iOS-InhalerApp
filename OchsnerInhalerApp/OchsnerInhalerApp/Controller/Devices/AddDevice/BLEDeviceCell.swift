//
//  BLEDeviceCell.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 19/01/22.
//

import UIKit

class BLEDeviceCell: UITableViewCell {
    @IBOutlet weak var lblDeviceName: UILabel!    
    @IBOutlet weak var btnConnect: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblDeviceName.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        lblDeviceName.text = "Ochsner Inhaler"
        btnConnect.setButtonView(StringAddDevice.connect)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
