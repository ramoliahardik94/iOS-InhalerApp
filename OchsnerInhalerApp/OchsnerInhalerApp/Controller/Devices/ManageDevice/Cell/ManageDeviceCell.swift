//
//  ManageDeviceCell.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 19/01/22.
//

import UIKit
protocol ManageDeviceDelegate: AnyObject {
    func editDirection(index: Int, section: Int)
    func removeDevice(index: Int, section: Int)
}
class ManageDeviceCell: UITableViewCell {

    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var lblDeviceType: UILabel!
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
    @IBOutlet weak var viewTypeSaperator: UIView!
    @IBOutlet weak var discriptionEditView: UIView!
    @IBOutlet weak var discriptionView: UIView!
    weak var delegate: ManageDeviceDelegate?
    @IBOutlet weak var txtDiscription: UITextField!
    @IBOutlet weak var lblDiscription: UILabel!
    var device = DeviceModel() {
        didSet {
            /// Rescue=1 Mantainance=2
            lblUsage.textColor = device.medTypeID ==  1 ?  #colorLiteral(red: 0.8784313725, green: 0.1254901961, blue: 0.1254901961, alpha: 1) :  #colorLiteral(red: 0.137254902, green: 0.7568627451, blue: 0.3294117647, alpha: 1)
            lblDiscription.textColor = device.discription == "" ? #colorLiteral(red: 0.5920000076, green: 0.5920000076, blue: 0.5920000076, alpha: 1) :  #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
            lblDeviceName.text  = device.medication.medName!
            lblDiscription.text = device.discription == "" ? StringDevices.addDiscription : device.discription
            lblNCDCode.text = "NDC Code: \(device.medication.ndc!)"
            lblUsage.text = device.medTypeID ==  1 ?  StringUserManagement.strRescue :  StringUserManagement.strMaintenance
            lblDose.text = "1 Dose = \(device.puffs) Puffs"
            lblDose.isHidden = device.medTypeID == 1
            let str = device.useTimes.joined(separator: "\n")
            lblNoOfDose.text =  (device.medTypeID ==  1 || device.useTimes.count == 0) ? StringCommonMessages.rescueDose : str
            lblUsageLabel.text = StringDevices.usage
            ivInhaler.image  =  device.medTypeID !=  1 ?  UIImage(named: "inhaler_blue") : UIImage(named: "inhaler_red")
            var textStatus =  StringCommonMessages.disconnect
           
            var bettery = device.batteryLevel
                if let peripheral = BLEHelper.shared.connectedPeripheral.first(where: {$0.addressMAC == device.internalID}) {
                    bettery =  peripheral.bettery != "0" ? "\(peripheral.bettery)%" :  device.batteryLevel
                    switch peripheral.discoveredPeripheral!.state {
                    case .connected :
                        textStatus = StringCommonMessages.connected
                        print("\(Constants.AppContainsFirmwareVersion) == \(peripheral.version)")
                  
                    case .disconnected :
                        textStatus = StringCommonMessages.disconnect
                    case .connecting :
                        textStatus = StringCommonMessages.connecting
                    case .disconnecting:
                        textStatus = StringCommonMessages.disconnect
                    @unknown default:
                        textStatus = BLEHelper.shared.isScanning ? StringCommonMessages.scanning : StringCommonMessages.disconnect
                    }
                } else {
                    textStatus = BLEHelper.shared.isScanning ? StringCommonMessages.scanning : StringCommonMessages.disconnect
                }
            lblstatus.text = textStatus
            lblBettery.text = bettery
            btnEditDirection.isHidden = device.medTypeID ==  1
        }
    }
    
    @IBAction func editok(_ sender: Any) {
        self.endEditing(true)

        device.discription = txtDiscription.text ?? ""
        lblDiscription.text =  device.discription == "" ? StringDevices.addDiscription : device.discription
        lblDiscription.textColor = device.discription == "" ? #colorLiteral(red: 0.5920000076, green: 0.5920000076, blue: 0.5920000076, alpha: 1) :  #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        let updateDevice = MedicationVM()
        updateDevice.macAddress = device.internalID
        updateDevice.selectedMedication = device.medication        
        updateDevice.medTypeId = device.medTypeID
        updateDevice.puff = device.puffs
        updateDevice.totalDose = device.arrTime.count
        updateDevice.description = device.discription
        updateDevice.arrTime = device.arrTime
        if let deviceDB = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email).first(where: {$0.mac == device.internalID}) {
            updateDevice.apiAddDevice(isreminder: deviceDB.reminder, date: nil) { [weak self] result in
                guard self != nil else { return }
                switch result {
                case .success:
                    break
                case .failure(let message):
                    CommonFunctions.showMessage(message: message)
                }
            }
        }
        self.discriptionEditView.isHidden = true
        self.discriptionView.isHidden = false
        
    }
    @IBAction func editCancel(_ sender: Any) {
        self.endEditing(true)
        lblDiscription.text =  device.discription == "" ? StringDevices.addDiscription : device.discription
        lblDiscription.textColor = device.discription == "" ? #colorLiteral(red: 0.5920000076, green: 0.5920000076, blue: 0.5920000076, alpha: 1) :  #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        self.discriptionEditView.isHidden = true
        self.discriptionView.isHidden = false
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblDeviceType.setFont(type: .semiBold, point: 20)
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
        txtDiscription.delegate = self
    }
    @IBAction func editDiscriptionClick(_ sender: Any) {
        txtDiscription.text = device.discription
        txtDiscription.placeholder = StringDevices.addDiscription
        lblDiscription.textColor = device.discription == "" ? #colorLiteral(red: 0.5920000076, green: 0.5920000076, blue: 0.5920000076, alpha: 1) :  #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        self.discriptionEditView.isHidden = false
        self.discriptionView.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnEditDirection(sender: UIButton) {
        if delegate != nil {
            delegate?.editDirection(index: sender.tag, section: Int(sender.accessibilityValue ?? "0") ?? 0)
        }
    }
    
 
    @IBAction func btnRemoveDevice(sender: UIButton) {
        if delegate != nil {
            delegate?.removeDevice(index: sender.tag, section: Int(sender.accessibilityValue ?? "0") ?? 0)
        }
    }
}
extension ManageDeviceCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let acceptableChar = "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz0123456789"
        let set = CharacterSet(charactersIn: acceptableChar)
        let inverted = set.inverted
        let filtered = string.components(separatedBy: inverted).joined(separator: "")
        let maxLength = 50
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return (filtered == string)  && (newString.count <= maxLength)
    }
}
