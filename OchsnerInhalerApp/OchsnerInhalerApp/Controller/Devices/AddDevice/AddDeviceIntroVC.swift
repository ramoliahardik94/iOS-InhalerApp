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
        NotificationCenter.default.removeObserver(self, name: .BLENotConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: .BLEFound, object: nil)
        NotificationCenter.default.removeObserver(self, name: .BLENotFound, object: nil)
        NotificationCenter.default.removeObserver(self, name: .BLEConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: .BLEDisconnect, object: nil)
        
    }
    
    // MARK: - UI SetUp functions
    /// Step2 and Step3 is combind so no need of this step2 as of now.
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
            BLEHelper.shared.stopTimer()
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
            let advTimeGif = UIImage.gifImageWithName("removeTag")
            
            imgAddDevice.image = advTimeGif
            lblAddDevice.isHidden  = true
            let attributedString = NSMutableAttributedString()
                .normal(StringAddDevice.removeAndDiscard)
                .chanageColorString(StringAddDevice.infoCharecter)
                .normalSmall(StringAddDevice.deviceNearBy)
//                .normalSmall(StringAddDevice.scanningTakeTime)
            lbldeviceInfo.attributedText = attributedString
            BLEHelper.shared.isAddAnother = true
            paringLoader.isHidden = true
            btnStartSetUp.setButtonView(StringAddDevice.scanDevice)
            btnStartSetUp.isEnabled = true
            btnStartSetUp.backgroundColor = .ButtonColorBlue
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerFound(notification:)), name: .BLEFound, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerNotFound(notification:)), name: .BLENotFound, object: nil)
           
                      
        case .step4:
            lblGreat.text = StringAddDevice.connectDevice
//            imgAddDevice.image = #imageLiteral(resourceName: "pairDevice")
            let advTimeGif = UIImage.gifImageWithName("Tap-Animation")
            imgAddDevice.image = advTimeGif
            lblAddDevice.isHidden  = true
            NotificationCenter.default.removeObserver(self, name: .BLEFound, object: nil)
            NotificationCenter.default.removeObserver(self, name: .BLENotFound, object: nil)            
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEConnect, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerNotConnect(notification:)), name: .BLENotConnect, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerNotConnect(notification:)), name: .BLEDisconnect, object: nil)
 
            
            let attributedString = NSMutableAttributedString()
                .normal(StringAddDevice.pairScreenStringArray[0])
                .bold(StringAddDevice.pairScreenStringArray[1])
                .normal(StringAddDevice.pairScreenStringArray[2])
                .bold(StringAddDevice.pairScreenStringArray[3])
                .normal(StringAddDevice.pairScreenStringArray[4])
                //.normalSmall(StringAddDevice.paringTakeTime)
            lbldeviceInfo.attributedText = attributedString
            
           // lbldeviceInfo.text = StringAddDevice.pairScreen
            // lbldeviceInfo.textAlignment = .center
            
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
//        btnBack.isHidden = !isFromAddAnother
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
        Logger.logInfo("Scan with scanBLE")
        BLEHelper.shared.scanPeripheral(isTimer: true)
    }
   // MARK: - IBActions related Functions
    @IBAction func btnBackClick(_ sender: Any) {
        if step == .step1 {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let homeTabBar  = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
            homeTabBar.selectedIndex = 1
            DispatchQueue.main.async {
                self.rootVC(controller: homeTabBar)
            }
        } else if BLEHelper.shared.isScanning {
            BLEHelper.shared.isScanning = false
            BLEHelper.shared.stopTimer()
            BLEHelper.shared.stopScanPeriphral()
            popVC()
        } else if let index = BLEHelper.shared.connectedPeripheral.firstIndex(where: {$0.discoveredPeripheral?.identifier.uuidString == BLEHelper.shared.uuid}) {
            let peripheral = BLEHelper.shared.connectedPeripheral[index].discoveredPeripheral!
            if  btnStartSetUp.titleLabel?.text == StringAddDevice.pairingDevice  || step == .step5 {
                
                CommonFunctions.showMessageYesNo(message: StringAddDevice.skipFlowAdd, cancelTitle: StringAddDevice.continuebtn, okTitle: StringAddDevice.skipbtn) { [weak self] isYes in
                    if isYes {
                        guard let `self` = self else { return }
                        NotificationCenter.default.removeObserver(self, name: .BLEDisconnect, object: nil)
                        BLEHelper.shared.cleanup(peripheral: peripheral)
                        BLEHelper.shared.connectedPeripheral.remove(at: index)
                        self.movetoDashboard()
                    }
                }
            } else {
                if step == .step4 {
                    BLEHelper.shared.connectedPeripheral.remove(at: index)
                }
                popVC()
            }
        } else {
            popVC()
        }
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
            let attributedString = NSMutableAttributedString()
                .normal(StringAddDevice.removeAndDiscard)
                .chanageColorString(StringAddDevice.infoCharecter)
                .normalSmall(StringAddDevice.deviceNearBy)
                .normalSmall(StringAddDevice.scanningTakeTime)
            lbldeviceInfo.attributedText = attributedString
        case .step4:
            BLEHelper.shared.stopTimer()
            BLEHelper.shared.connectPeriPheral(peripheral: BLEHelper.shared.connectedPeripheral.last!.discoveredPeripheral!)
            paringLoader.isHidden = false
            paringLoader.startAnimating()
            btnStartSetUp.setButtonView(StringAddDevice.pairingDevice)
            btnStartSetUp.isEnabled = false
            btnStartSetUp.backgroundColor = .ButtonColorBlue
            let attributedString = NSMutableAttributedString()
                .normal(StringAddDevice.pairScreenStringArray[0])
                .bold(StringAddDevice.pairScreenStringArray[1])
                .normal(StringAddDevice.pairScreenStringArray[2])
                .bold(StringAddDevice.pairScreenStringArray[3])
                .normal(StringAddDevice.pairScreenStringArray[4])
                .normalSmall(StringAddDevice.paringTakeTime)
            lbldeviceInfo.attributedText = attributedString
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
                pushVC(controller: medicationVC)
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
        
        NotificationCenter.default.removeObserver(self, name: .BLEFound, object: nil)
        NotificationCenter.default.removeObserver(self, name: .BLENotFound, object: nil)
        paringLoader.isHidden = true
        paringLoader.stopAnimating()
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        addDeviceIntroVC.step = .step4
        addDeviceIntroVC.isFromAddAnother = isFromAddAnother
        addDeviceIntroVC.isFromDeviceList = isFromDeviceList
        pushVC(controller: addDeviceIntroVC)
        


    }
    @objc func inhalerNotConnect(notification: Notification) {
        if self.step == .step4 {
            btnStartSetUp.isEnabled = false
            btnStartSetUp.backgroundColor = .gray
            paringLoader.stopAnimating()
            paringLoader.isHidden = true
            CommonFunctions.showMessageYesNo(message: ValidationMsg.bleNotPair, okTitle: ValidationButton.tryAgain) { [weak self] isContinue in
                guard let `self` = self else { return }
                if isContinue {
                    BLEHelper.shared.connectPeriPheral(peripheral: BLEHelper.shared.connectedPeripheral.last!.discoveredPeripheral!)
                    self.paringLoader.isHidden = false
                    self.paringLoader.startAnimating()
                    self.btnStartSetUp.isEnabled = false
                    self.btnStartSetUp.backgroundColor = .ButtonColorBlue
                } else {
                    if let index = BLEHelper.shared.connectedPeripheral.firstIndex(where: {$0.discoveredPeripheral?.identifier.uuidString == BLEHelper.shared.uuid}) {
                        BLEHelper.shared.connectedPeripheral.remove(at: index)
                    }
                    self  .movetoDashboard()
                }
            }
            
        } else if self.step == .step3 {
          //  inhalerNotFound(notification: Notification(name: .BLENotFound))
        }
    }
    @objc func inhalerNotFound(notification: Notification) {
        btnStartSetUp.isEnabled = false
        btnStartSetUp.backgroundColor = .gray
        paringLoader.stopAnimating()
        paringLoader.isHidden = true
        CommonFunctions.showMessageYesNo(message: ValidationMsg.bleNotfound, okTitle: ValidationButton.tryAgain) { [weak self] isContinue in
            guard let `self` = self else { return }
            if isContinue {
                self.scanBLE()
            } else {
                self.movetoDashboard()
            }
        }
        
    }
    
    @objc func inhalerConnected(notification: Notification) {
        print("inhalerConnected")
        NotificationCenter.default.removeObserver(self, name: .BLENotConnect, object: nil)
        NotificationCenter.default.removeObserver(self, name: .BLEConnect, object: nil)
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        guard let discoverPeripheral = BLEHelper.shared.connectedPeripheral.first(where: {BLEHelper.shared.uuid == $0.discoveredPeripheral?.identifier.uuidString}) else { return }
        BLEHelper.shared.setRTCTime(uuid: (discoverPeripheral.discoveredPeripheral?.identifier.uuidString)!)
        BLEHelper.shared.getBetteryLevel(peripheral: discoverPeripheral)
        addDeviceIntroVC.step = .step5
        addDeviceIntroVC.isFromAddAnother = isFromAddAnother
        addDeviceIntroVC.isFromDeviceList = isFromDeviceList
        pushVC(controller: addDeviceIntroVC)
    }
    
    func movetoDashboard() {
        if self.isFromDeviceList {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let homeTabBar  = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
            rootVC(controller: homeTabBar)
            let deviceList = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
            if deviceList.count == 0 {
            homeTabBar.selectedIndex = 1
            }
            self.rootVC(controller: homeTabBar)
        }
    }
}
