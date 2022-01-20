//
//  HomeDeviceCell.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 19/01/22.
//

import UIKit

class HomeDeviceCell: UITableViewCell {

    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblDeviceType: UILabel!
    @IBOutlet weak var lblConnected: UILabel!
    @IBOutlet weak var lblBattery: UILabel!
    @IBOutlet weak var lblBatteryPercentage: UILabel!
    @IBOutlet weak var lblToday: UILabel!
    @IBOutlet weak var lblTodayData: UILabel!
    @IBOutlet weak var lblThisWeekData: UILabel!
    @IBOutlet weak var lblThisWeek: UILabel!
    @IBOutlet weak var lblThisMonthData: UILabel!
    @IBOutlet weak var lblThisMonth: UILabel!
    @IBOutlet weak var viewToday: UIView!
    @IBOutlet weak var viewAdherance: UIView!
    @IBOutlet weak var lblAdherance: UILabel!
    @IBOutlet weak var viewNextDose: UIView!
    @IBOutlet weak var lblNextDose: UILabel!
    @IBOutlet weak var ivThisWeek: UIImageView!
    @IBOutlet weak var ivThisMonth: UIImageView!
    @IBOutlet weak var ivBattery: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
