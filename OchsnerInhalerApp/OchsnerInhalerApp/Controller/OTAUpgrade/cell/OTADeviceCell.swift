//
//  OTADeviceCell.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 19/05/22.
//

import UIKit
protocol OTAUpgradeDelegate: AnyObject {
    func upgradeDevice(peripheral: PeriperalType, medName: String)
}
class OTADeviceCell: UITableViewCell {

    @IBOutlet weak var viewbottom: UIView!
    @IBOutlet weak var lblMedname: UILabel!
    @IBOutlet weak var btnUpgrade: UIButton!
    var delegate: OTAUpgradeDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblMedname.setFont(type: .semiBold, point: 17)
        btnUpgrade.setButtonView(OTAMessages.upgrade, 14, AppFont.AppRegularFont, isBlankBG: true)
      
    }
    var device = Device() {
        didSet {
            lblMedname.text = "\(device.medname!) (\(device.medtypeid ==  1 ?  StringUserManagement.strRescue :  StringUserManagement.strMaintenance))"
            var isReadyToUpgrade = false
            var isUptoDate = false
            if let peripheral = BLEHelper.shared.connectedPeripheral.first(where: {$0.addressMAC == device.mac}) {
                isReadyToUpgrade = peripheral.discoveredPeripheral!.state == .connected
                isUptoDate = device.version == Constants.AppContainsFirmwareVersion
            }
            
            
            btnUpgrade.setTitleColor(.gray, for: .disabled)
            if !isReadyToUpgrade {
                btnUpgrade.isEnabled = false
                btnUpgrade.setTitle(StringCommonMessages.disconnect, for: .disabled)
            }
            if isUptoDate {
                btnUpgrade.isEnabled = false
                btnUpgrade.setTitle(OTAMessages.Installed, for: .disabled)
            }
            if isReadyToUpgrade && !isUptoDate {
                btnUpgrade.isEnabled = true
                btnUpgrade.setTitle(OTAMessages.upgrade, for: .normal)
            } else {
                
            }
            
            
            if !btnUpgrade.isEnabled {
                btnUpgrade.layer.borderColor =  (UIColor.gray).cgColor
            } else {
                btnUpgrade.layer.borderColor = (UIColor.ButtonColorBlue).cgColor
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func btnUpgradeClick(_ sender: Any) {
        if let peripheral = BLEHelper.shared.connectedPeripheral.first(where: {$0.addressMAC == device.mac}) {
            delegate?.upgradeDevice(peripheral: peripheral, medName: device.medname ?? "")
        }
    }
}
