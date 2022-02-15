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
    @IBOutlet weak var viewState: UIView!
    @IBOutlet weak var viewBettery: UIView!
    @IBOutlet weak var lblBettery: UILabel!
    @IBOutlet weak var lblBetteryTitle: UILabel!
    @IBOutlet weak var lblstatus: UILabel!
    var device = DeviceModel() {
        didSet {            
            /// Rescue=1 Mantainance=2
            lblUsage.textColor = device.medTypeID ==  1 ?  #colorLiteral(red: 0.8784313725, green: 0.1254901961, blue: 0.1254901961, alpha: 1) :  #colorLiteral(red: 0.137254902, green: 0.7568627451, blue: 0.3294117647, alpha: 1)
            lblDeviceName.text  = device.medication.medName!
            lblNCDCode.text = "NDC Code: \(device.medication.ndc!)"
            lblUsage.text = device.medTypeID ==  1 ?  "Rescue" :  "Maintenance"
            lblDose.text = "1 Dose = \(device.puffs) Puffs"
            let str = device.useTimes.joined(separator: "\n")
            lblNoOfDose.text =  device.medTypeID ==  1 ? StringCommonMessages.rescueDose : str
            lblUsageLabel.text = StringDevices.usage
            ivInhaler.image  =  device.medTypeID ==  1 ?  UIImage(named: "inhaler_blue") : UIImage(named: "inhaler_red")
            lblstatus.text = BLEHelper.shared.addressMAC == device.internalID ? StringCommonMessages.connected : StringCommonMessages.disconnect
            lblBettery.text = device.batteryLevel
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblDeviceName.setFont(type: .semiBold, point: 17)
        lblNCDCode.setFont(type: .regular, point: 17)
        lblUsageLabel.setFont(type: .regular, point: 17)
        lblUsage.setFont(type: .bold, point: 17)
        lblDose.setFont(type: .regular, point: 17)
        lblNoOfDose.setFont(type: .regular, point: 17)
        lblBettery.setFont(type: .semiBold, point: 14)
        lblBetteryTitle.setFont(type: .regular, point: 14)
        lblBetteryTitle.text = StringCommonMessages.battery
        lblstatus.setFont(type: .regular, point: 14)
        btnRemoveDevice.setButtonView(StringDevices.removeDevice, 17, AppFont.AppRegularFont)
        btnEditDirection.setButtonView(StringDevices.editDirection, 17, AppFont.AppRegularFont)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
