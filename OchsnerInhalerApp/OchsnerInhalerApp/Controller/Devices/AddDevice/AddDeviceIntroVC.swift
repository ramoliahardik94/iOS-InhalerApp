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
    var step : AddDeviceSteps = .Step1
    var isFromAddAnother = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setVC()

    }
    
    func setUpUIBaseonStep(){
        paringLoader.isHidden = true
        switch step {
        case .Step1:
            lblAddDevice.isHidden  = false
            lblGreat.text = StringAddDevice.great
            imgAddDevice.image = #imageLiteral(resourceName: "inhealer")
            lblAddDevice.text = StringAddDevice.addDevice
            let attributedString = attributedText(withString: StringAddDevice.addDeviceInto, boldString: StringAddDevice.Connected_Inhaler_Sensor, font: UIFont(name: AppFont.AppRegularFont, size: 17)!)
            lbldeviceInfo.attributedText = attributedString
            btnStartSetUp.setButtonView(StringAddDevice.startSetup)
            break
        case .Step2:
            lblGreat.text = StringAddDevice.removeIsolationTag
            imgAddDevice.image = #imageLiteral(resourceName: "removeTag")
            //lblAddDevice.text = ""
            lblAddDevice.isHidden  = true
            lbldeviceInfo.text = StringAddDevice.removeIsolationTaginfo
            btnStartSetUp.setButtonView(StringAddDevice.next)
     
        case .Step3:
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
            
        case .Step4:
            lblGreat.text = StringAddDevice.mountDevice
            imgAddDevice.image = #imageLiteral(resourceName: "mount")
          //  lblAddDevice.text = ""
            lblAddDevice.isHidden  = true
            lbldeviceInfo.text = StringAddDevice.mountDeviceInfo
            btnStartSetUp.setButtonView(StringAddDevice.next)
           
            
        case .Step5:
            lblGreat.text = StringAddDevice.great
            imgAddDevice.image = #imageLiteral(resourceName: "medication")
            let attributedString = attributedText(withString: StringAddDevice.medicationInfo, boldString: StringAddDevice.Connected_Inhaler_Sensor, font: UIFont(name: AppFont.AppRegularFont, size: 17)!)
            lbldeviceInfo.attributedText = attributedString
            lblAddDevice.text = StringAddDevice.medication
            btnStartSetUp.setButtonView(StringAddDevice.selectMedication)
        }
    }
    
    func setVC(){
        btnBack.isHidden = !isFromAddAnother
        lbldeviceInfo.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        lblGreat.font = UIFont(name: AppFont.AppBoldFont, size: 34)
        lblAddDevice.font = UIFont(name: AppFont.AppBoldFont, size: 34)
        viewDeviceList.isHidden = true
        setUpUIBaseonStep()
        
    }
    
    func scanBLE(){
        paringLoader.isHidden = false
        paringLoader.startAnimating()
        btnStartSetUp.isEnabled = false
        
        btnStartSetUp.backgroundColor = .gray
        BLEHelper.shared.scanPeripheral()
    }
    @objc func inhalerFound(notification:Notification) {
        btnStartSetUp.isEnabled = true
        btnStartSetUp.backgroundColor = .Button_Color_Blue
        paringLoader.stopAnimating()
        paringLoader.isHidden = false
    }
    @objc func inhalerNotConnect(notification:Notification) {
        btnStartSetUp.isEnabled = false
        
        btnStartSetUp.backgroundColor = .gray
        paringLoader.stopAnimating()
        paringLoader.isHidden = true
        CommonFunctions.showMessageYesNo(message: ValidationMsg.bleNotPair, cancelTitle: "Cancel", okTitle: "TryAgain") { isTryAgain in
            if isTryAgain! {
                self.scanBLE()
            }else{
                //TODO: After testing remove this code
                NotificationCenter.default.post(name: .BLEConnect, object: nil)
            }
        }
    }
    @objc func inhalerNotFound(notification:Notification) {
        btnStartSetUp.isEnabled = false
        
        btnStartSetUp.backgroundColor = .gray
        paringLoader.stopAnimating()
        paringLoader.isHidden = true
        CommonFunctions.showMessageYesNo(message: ValidationMsg.bleNotfound, cancelTitle: "Cancel", okTitle: "TryAgain") { isTryAgain in
            if isTryAgain! {
                self.scanBLE()
            }else{
                //TODO: After testing remove this code
                NotificationCenter.default.post(name: .BLEConnect, object: nil)
            }
        }
    }
    
    @objc func inhalerConnected(notification:Notification) {
        let vc = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        vc.step = .Step4
        vc.isFromAddAnother = isFromAddAnother
        pushVC(vc: vc)
    }
    @IBAction func btnBackClick(_ sender: Any) {
        popVC()
    }
    
    @IBAction func btnNextClick(_ sender: UIButton) {
        let vc = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        switch step {
        case .Step1:
            vc.step = .Step2
            vc.isFromAddAnother = isFromAddAnother
            pushVC(vc: vc)
        case .Step2:
            vc.step = .Step3
            vc.isFromAddAnother = isFromAddAnother
            pushVC(vc: vc)
        case .Step3:
            BLEHelper.shared.connectPeriPheral()
            paringLoader.isHidden = false
            paringLoader.startAnimating()
            btnStartSetUp.isEnabled = false
            btnStartSetUp.backgroundColor = .gray
            BLEHelper.shared.scanPeripheral()
        case .Step4:
            vc.step = .Step5
            vc.isFromAddAnother = isFromAddAnother
            pushVC(vc: vc)
        case .Step5:
                let vc = MedicationVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                 pushVC(vc: vc)
            
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
        let vc = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        vc.step = .Step4
        vc.isFromAddAnother = isFromAddAnother
        pushVC(vc: vc)
    }
    
}

