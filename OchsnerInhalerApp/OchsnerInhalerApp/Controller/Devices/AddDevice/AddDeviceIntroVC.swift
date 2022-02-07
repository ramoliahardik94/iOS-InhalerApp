//
//  AddDeviceIntro.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 17/01/22.
//

import UIKit

class AddDeviceIntroVC: BaseVC {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblScanList: UITableView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var viewDeviceList: UIView!
    @IBOutlet weak var btnStartSetUp: UIButton!
    @IBOutlet weak var lblAddDevice: UILabel!
    @IBOutlet weak var lblGreat: UILabel!
    @IBOutlet weak var lbldeviceInfo: UILabel!
    @IBOutlet weak var imgAddDevice: UIImageView!
    @IBOutlet weak var paringLoader: UIActivityIndicatorView!
    var step: AddDeviceSteps = .step1
    var isFromAddAnother = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setVC()

    }
    
    func setUpUIBaseonStep() {
        paringLoader.isHidden = true
        switch step {
        case .step1:
            lblAddDevice.isHidden  = false
            lblGreat.text = StringAddDevice.great
            imgAddDevice.image = #imageLiteral(resourceName: "inhealer")
            lblAddDevice.text = StringAddDevice.addDevice
            let attributedString = attributedText(withString: StringAddDevice.addDeviceInto, boldString: StringAddDevice.ConnectedInhalerSensor, font: UIFont(name: AppFont.AppRegularFont, size: 17)!)
            lbldeviceInfo.attributedText = attributedString
            btnStartSetUp.setButtonView(StringAddDevice.startSetup)
           
        case .step2:
            lblGreat.text = StringAddDevice.removeIsolationTag
            imgAddDevice.image = #imageLiteral(resourceName: "removeTag")
            // lblAddDevice.text = ""
            lblAddDevice.isHidden  = true
            lbldeviceInfo.text = StringAddDevice.removeIsolationTaginfo
            btnStartSetUp.setButtonView(StringAddDevice.next)
     
        case .step3:
            paringLoader.isHidden = false
            lblGreat.text = StringAddDevice.connectDevice
            imgAddDevice.image = #imageLiteral(resourceName: "pairDevice")
            lblAddDevice.isHidden  = true
            lbldeviceInfo.text = StringAddDevice.connectDeviceInfo
            btnStartSetUp.setButtonView(StringAddDevice.pareDevice)
            btnStartSetUp.isEnabled = false
            
            btnStartSetUp.backgroundColor = .gray
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerFound(notification:)), name: .BLEFound, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerNotFound(notification:)), name: .BLENotFound, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEConnect, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerNotConnect(notification:)), name: .BLENotConnect, object: nil)
            
            scanBLE()
            
        case .step4:
            lblGreat.text = StringAddDevice.mountDevice
            imgAddDevice.image = #imageLiteral(resourceName: "mount")
          //  lblAddDevice.text = ""
            lblAddDevice.isHidden  = true
            lbldeviceInfo.text = StringAddDevice.mountDeviceInfo
            btnStartSetUp.setButtonView(StringAddDevice.next)
           
            
        case .step5:
            lblGreat.text = StringAddDevice.great
            imgAddDevice.image = #imageLiteral(resourceName: "medication")
            let attributedString = attributedText(withString: StringAddDevice.medicationInfo, boldString: StringAddDevice.ConnectedInhalerSensor, font: UIFont(name: AppFont.AppRegularFont, size: 17)!)
            lbldeviceInfo.attributedText = attributedString
            lblAddDevice.text = StringAddDevice.medication
            btnStartSetUp.setButtonView(StringAddDevice.selectMedication)
        }
    }
    
    func setVC() {
        btnBack.isHidden = !isFromAddAnother
        lbldeviceInfo.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        lblGreat.font = UIFont(name: AppFont.AppBoldFont, size: 34)
        lblAddDevice.font = UIFont(name: AppFont.AppBoldFont, size: 34)
        viewDeviceList.isHidden = true
        setUpUIBaseonStep()
        
    }
    
    func scanBLE() {
        paringLoader.isHidden = false
        paringLoader.startAnimating()
        btnStartSetUp.isEnabled = false
        
        btnStartSetUp.backgroundColor = .gray
        BLEHelper.shared.scanPeripheral()
    }
    @objc func inhalerFound(notification: Notification) {
        btnStartSetUp.isEnabled = true
        btnStartSetUp.backgroundColor = .ButtonColorBlue
        paringLoader.stopAnimating()
        paringLoader.isHidden = false
    }
    @objc func inhalerNotConnect(notification: Notification) {
        btnStartSetUp.isEnabled = false
        
        btnStartSetUp.backgroundColor = .gray
        paringLoader.stopAnimating()
        paringLoader.isHidden = true
        CommonFunctions.showMessageYesNo(message: ValidationMsg.bleNotPair, cancelTitle: "Cancel", okTitle: "TryAgain") { isTryAgain in
            if isTryAgain! {
                self.scanBLE()
            } else {
                // TODO: After testing remove this code
                NotificationCenter.default.post(name: .BLEConnect, object: nil)
            }
        }
    }
    @objc func inhalerNotFound(notification: Notification) {
        btnStartSetUp.isEnabled = false
        
        btnStartSetUp.backgroundColor = .gray
        paringLoader.stopAnimating()
        paringLoader.isHidden = true
        CommonFunctions.showMessageYesNo(message: ValidationMsg.bleNotfound, cancelTitle: "Cancel", okTitle: "TryAgain") { isTryAgain in
            if isTryAgain! {
                self.scanBLE()
            } else {
                // TODO: After testing remove this code
                NotificationCenter.default.post(name: .BLEConnect, object: nil)
            }
        }
    }
    
    @objc func inhalerConnected(notification: Notification) {
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        addDeviceIntroVC.step = .step4
        addDeviceIntroVC.isFromAddAnother = isFromAddAnother
        pushVC(controller: addDeviceIntroVC)
    }
    @IBAction func btnBackClick(_ sender: Any) {
        popVC()
    }
    
    @IBAction func btnNextClick(_ sender: UIButton) {
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        switch step {
        case .step1:
            addDeviceIntroVC.step = .step2
            addDeviceIntroVC.isFromAddAnother = isFromAddAnother
            pushVC(controller: addDeviceIntroVC)
        case .step2:
            addDeviceIntroVC.step = .step3
            addDeviceIntroVC.isFromAddAnother = isFromAddAnother
            pushVC(controller: addDeviceIntroVC)
        case .step3:
            BLEHelper.shared.connectPeriPheral()
            paringLoader.isHidden = false
            paringLoader.startAnimating()
            btnStartSetUp.isEnabled = false
            btnStartSetUp.backgroundColor = .gray
            BLEHelper.shared.scanPeripheral()
        case .step4:
            addDeviceIntroVC.step = .step5
            addDeviceIntroVC.isFromAddAnother = isFromAddAnother
            pushVC(controller: addDeviceIntroVC)
        case .step5:
            let medicationVC = MedicationVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
            pushVC(controller: medicationVC)
            
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btnConnectClick(_ sender: UIButton) {
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        addDeviceIntroVC.step = .step4
        addDeviceIntroVC.isFromAddAnother = isFromAddAnother
        pushVC(controller: addDeviceIntroVC)
    }
}
