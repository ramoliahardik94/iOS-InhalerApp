//
//  ManageDeviceCell.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 19/01/22.
//

import UIKit
protocol ManageDeviceDelegate: AnyObject {
    func editDirection(index: Int)
    func removeDevice(index: Int)
}
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
    @IBOutlet weak var lblBettery: UILabel!
    @IBOutlet weak var lblBetteryTitle: UILabel!
    @IBOutlet weak var lblstatus: UILabel!
    weak var delegate: ManageDeviceDelegate?
    
    var device = DeviceModel() {
        didSet {            
            /// Rescue=1 Mantainance=2
            lblUsage.textColor = device.medTypeID ==  1 ?  #colorLiteral(red: 0.8784313725, green: 0.1254901961, blue: 0.1254901961, alpha: 1) :  #colorLiteral(red: 0.137254902, green: 0.7568627451, blue: 0.3294117647, alpha: 1)
            lblDeviceName.text  = device.medication.medName!
            lblNCDCode.text = "NDC Code: \(device.medication.ndc!)"
            lblUsage.text = device.medTypeID ==  1 ?  "Rescue" :  "Maintenance"
            lblDose.text = "1 Dose = \(device.puffs) Puffs"
            lblDose.isHidden = device.medTypeID == 1
            let str = device.useTimes.joined(separator: "\n")
            lblNoOfDose.text =  (device.medTypeID ==  1 || device.useTimes.count == 0) ? StringCommonMessages.rescueDose : str
            lblUsageLabel.text = StringDevices.usage
            ivInhaler.image  =  device.medTypeID !=  1 ?  UIImage(named: "inhaler_blue") : UIImage(named: "inhaler_red")
            var textStatus =  StringCommonMessages.disconnect
            if BLEHelper.shared.isScanning {
                textStatus = StringCommonMessages.scanning
            } else {
                if BLEHelper.shared.addressMAC == device.internalID {
                    print("BLE State:\(BLEHelper.shared.discoveredPeripheral!)")
                    if BLEHelper.shared.discoveredPeripheral != nil {
                        switch BLEHelper.shared.discoveredPeripheral!.state {
                        case .connected :
                            textStatus = StringCommonMessages.connected
                        case .disconnected :
                            textStatus = StringCommonMessages.disconnect
                        case .connecting :
                            textStatus = StringCommonMessages.connecting
                        case .disconnecting:
                            textStatus = StringCommonMessages.disconnect
                        @unknown default:
                            textStatus = StringCommonMessages.connecting
                        }
                    } else {
                        textStatus = StringCommonMessages.disconnect
                    }
                }
            }
            lblstatus.text = textStatus
            
            lblBettery.text = "\(BLEHelper.shared.addressMAC == device.internalID ? (BLEHelper.shared.bettery != "0" ? "\(BLEHelper.shared.bettery)%" : device.batteryLevel ): device.batteryLevel)"
            btnEditDirection.isHidden = device.medTypeID ==  1
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
    
    @IBAction func btnEditDirection(sender: UIButton) {
        if delegate != nil {
            delegate?.editDirection(index: sender.tag)
        }
    }
    
    @IBAction func btnRemoveDevice(sender: UIButton) {
        if delegate != nil {
            delegate?.removeDevice(index: sender.tag)
        }
    }
}
