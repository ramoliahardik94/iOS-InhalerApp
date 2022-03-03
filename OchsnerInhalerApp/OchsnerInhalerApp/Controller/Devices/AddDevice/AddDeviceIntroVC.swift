//
//  AddDeviceIntro.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 17/01/22.
//

import UIKit

class AddDeviceIntroVC: BaseVC {

    @IBOutlet weak var imgTemp: UIImageView!
    @IBOutlet weak var lblTitleCenter: NSLayoutConstraint!
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
    var isFromDeviceList = false
    // MARK: - ViewController lifeCycal Functions
     override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setVC()
    }
    
    
    deinit {
        BLEHelper.shared.stopTimer()
        NotificationCenter.default.removeObserver(self, name: .BLENotConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: .BLEFound, object: nil)
        NotificationCenter.default.removeObserver(self, name: .BLENotFound, object: nil)
        NotificationCenter.default.removeObserver(self, name: .BLEConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: .BLEDisconnect, object: nil)
        
    }
    
    // MARK: - UI SetUp functions
    /// Step2 and Step3 is combind so no need of this step as of now.
    func setUpUIBaseonStep() {
        self.navigationController?.isNavigationBarHidden = true
        paringLoader.isHidden = true
        switch step {
        case .step1:
            lblTitleCenter.constant = -20
            lblAddDevice.isHidden  = false
            lblGreat.text = StringAddDevice.great
            imgAddDevice.image = #imageLiteral(resourceName: "Inhaler Graphic")
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
            lblGreat.text = StringAddDevice.removeIsolationTag
            imgAddDevice.image = #imageLiteral(resourceName: "removeTag")
            lblAddDevice.isHidden  = true
            lbldeviceInfo.text = StringAddDevice.removeIsolationTagWithScan
            BLEHelper.shared.isAddAnother = true
            BLEHelper.shared.discoveredPeripheral = nil
            
//            lbldeviceInfo.text = StringAddDevice.scanInstructionOne // StringAddDevice.connectDeviceInfo
//            lblGreat.text = StringAddDevice.scanDevicetitle
            
            paringLoader.isHidden = true
            btnStartSetUp.setButtonView(StringAddDevice.scanDevice)
            btnStartSetUp.isEnabled = true
            btnStartSetUp.backgroundColor = .ButtonColorBlue
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerFound(notification:)), name: .BLEFound, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerNotFound(notification:)), name: .BLENotFound, object: nil)
                      
        case .step4:
            lblGreat.text = StringAddDevice.connectDevice
            imgAddDevice.image = #imageLiteral(resourceName: "pairDevice")
//            let advTimeGif = UIImage.gifImageWithName("gifanimated")
//            imgAddDevice.image = advTimeGif
            lblAddDevice.isHidden  = true
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEConnect, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerNotConnect(notification:)), name: .BLENotConnect, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerNotConnect(notification:)), name: .BLEDisconnect, object: nil)
 
            
            lbldeviceInfo.text = StringAddDevice.pairScreen
            lbldeviceInfo.textAlignment = .center
            
            btnStartSetUp.setButtonView(StringAddDevice.pairDevice)
            btnStartSetUp.isEnabled = true
            btnStartSetUp.backgroundColor = .ButtonColorBlue
            paringLoader.isHidden = true
            paringLoader.stopAnimating()
            
        case .step5:
            lblGreat.text = StringAddDevice.mountDevice
            imgAddDevice.image = #imageLiteral(resourceName: "mount")
            lblAddDevice.isHidden  = true
            lbldeviceInfo.text = StringAddDevice.mountDeviceInfo
            btnStartSetUp.setButtonView(StringAddDevice.next)
                       
        case .step6:
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
        btnStartSetUp.backgroundColor = .ButtonColorBlue
        BLEHelper.shared.isAddAnother = true
        BLEHelper.shared.scanPeripheral(isTimer: true)
    }
   // MARK: - IBActions related Functions
    @IBAction func btnBackClick(_ sender: Any) {
        popVC()
    }
    
    @IBAction func btnNextClick(_ sender: UIButton) {
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        switch step {
        case .step1:
            addDeviceIntroVC.step = .step3
            addDeviceIntroVC.isFromAddAnother = isFromAddAnother
            addDeviceIntroVC.isFromDeviceList = isFromDeviceList
            pushVC(controller: addDeviceIntroVC)
        case .step2:
            addDeviceIntroVC.step = .step3
            addDeviceIntroVC.isFromAddAnother = isFromAddAnother
            addDeviceIntroVC.isFromDeviceList = isFromDeviceList
            pushVC(controller: addDeviceIntroVC)
        case .step3:
                BLEHelper.shared.scanPeripheral(isTimer: true)
                btnStartSetUp.setButtonView(StringAddDevice.scanningDevice)
                btnStartSetUp.isEnabled = false
                btnStartSetUp.backgroundColor = .ButtonColorBlue
                paringLoader.isHidden = false
                paringLoader.startAnimating()
                BLEHelper.shared.scanPeripheral()
        case .step4:
            BLEHelper.shared.stopTimer()
            BLEHelper.shared.connectPeriPheral()
            paringLoader.isHidden = false
            paringLoader.startAnimating()
            btnStartSetUp.setButtonView(StringAddDevice.pairingDevice)
            btnStartSetUp.isEnabled = false
            btnStartSetUp.backgroundColor = .ButtonColorBlue
        case .step5:
            addDeviceIntroVC.step = .step6
            addDeviceIntroVC.isFromAddAnother = isFromAddAnother
            addDeviceIntroVC.isFromDeviceList = isFromDeviceList
            pushVC(controller: addDeviceIntroVC)
        case .step6:
            let medicationVC = MedicationVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
            medicationVC.isFromDeviceList = isFromDeviceList
            if isFromDeviceList {
                pushVC(controller: medicationVC)
            } else {
                rootVC(controller: medicationVC)
            }
            
        }
        
    }
    
    @IBAction func btnConnectClick(_ sender: UIButton) {
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        addDeviceIntroVC.step = .step4
        addDeviceIntroVC.isFromAddAnother = isFromAddAnother
        pushVC(controller: addDeviceIntroVC)
    }

}
// MARK: - Notification Functions
extension AddDeviceIntroVC {
    @objc func inhalerFound(notification: Notification) {
        
//        btnStartSetUp.setButtonView(StringAddDevice.next)
//        btnStartSetUp.isEnabled = true
//        btnStartSetUp.backgroundColor = .ButtonColorBlue
//        lbldeviceInfo.text = StringAddDevice.scanInstructionTwo //        btnStartSetUp.setButtonView(StringAddDevice.pairDevice)
        paringLoader.isHidden = true
        paringLoader.stopAnimating()
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        addDeviceIntroVC.step = .step4
        addDeviceIntroVC.isFromAddAnother = isFromAddAnother
        addDeviceIntroVC.isFromDeviceList = isFromDeviceList
        pushVC(controller: addDeviceIntroVC)
        


    }
    @objc func inhalerNotConnect(notification: Notification) {
        btnStartSetUp.isEnabled = false
        
        btnStartSetUp.backgroundColor = .gray
        paringLoader.stopAnimating()
        paringLoader.isHidden = true
        CommonFunctions.showMessage(message: ValidationMsg.bleNotPair, titleOk: ValidationButton.tryAgain) { [weak self] _ in
            BLEHelper.shared.connectPeriPheral()
            guard let weakSelf = self else { return }
            weakSelf.paringLoader.isHidden = false
            weakSelf.paringLoader.startAnimating()
            weakSelf.btnStartSetUp.isEnabled = false
            weakSelf.btnStartSetUp.backgroundColor = .ButtonColorBlue
        }
    }
    @objc func inhalerNotFound(notification: Notification) {
        btnStartSetUp.isEnabled = false
        btnStartSetUp.backgroundColor = .gray
        paringLoader.stopAnimating()
        paringLoader.isHidden = true
        CommonFunctions.showMessage(message: ValidationMsg.bleNotfound, titleOk: ValidationButton.tryAgain) { [weak self] _ in
            guard let `self` = self else { return }
            self.scanBLE()
        }
    }
    
    @objc func inhalerConnected(notification: Notification) {
        print("inhalerConnected")
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        BLEHelper.shared.setRTCTime()
        BLEHelper.shared.getBetteryLevel()
        addDeviceIntroVC.step = .step5
        addDeviceIntroVC.isFromAddAnother = isFromAddAnother
        addDeviceIntroVC.isFromDeviceList = isFromDeviceList
        pushVC(controller: addDeviceIntroVC)
    }
}
