//
//  BLEOTAUpgrade.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 09/05/22.
//


import RTKOTASDK
import RTKLEFoundation
import UIKit
import CoreBluetooth

class BLEOTAUpgrade: BaseVC, RTKLEProfileDelegate, RTKDFUPeripheralDelegate {
    
    private var fileName: String?
    private var otaProfile: RTKOTAProfile = RTKOTAProfile()
    private var otaPeripheral: RTKOTAPeripheral?
    private var dfuPeripheral: RTKMultiDFUPeripheral?
    var upgradeSilently = false
    private var timeUpgradeBegin: Date?
    private var images: [RTKOTAUpgradeBin] = [RTKOTAUpgradeBin]()
    private var imagesForLeftBud: [RTKOTAUpgradeBin] = [RTKOTAUpgradeBin]()
    private var imagesForRightBud: [RTKOTAUpgradeBin] = [RTKOTAUpgradeBin]()
    private var upgradeNextConnectedPeripheral = false
    @IBOutlet weak var lblOTAInfo: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMedname: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    var selectedPeripheral: CBPeripheral?
    var isUpdateAll = false
     var medname = String()
    override func viewDidLoad() {
        otaProfile = RTKOTAProfile()
        otaProfile.delegate = self
        lblOTAInfo.text = ""
        progressView.progress = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startConnection()
    }
    
    func startConnection() {
        progressView.progress = 0.10
        self.otaPeripheral = otaProfile.otaPeripheral(from: selectedPeripheral!)
        lblOTAInfo.text = "Updating...(10%)"
        if let type = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email).first(where: {$0.udid == selectedPeripheral?.identifier.uuidString}) {
            self.medname = "\(type.medname!) (\(type.medtypeid ==  1 ?  StringUserManagement.strRescue :  StringUserManagement.strMaintenance))"
        }
        
        lblMedname.text = "\(self.medname) "
        lblOTAInfo.setFont(type: .regular, point: 17)
        lblTitle.setFont(type: .bold, point: 20)
        lblMedname.setFont(type: .bold, point: 34)
        lblInfo.setFont(type: .regular, point: 17)
        lblTitle.text = OTAMessages.titleUpgrade
        lblInfo.text = OTAMessages.info
        if otaPeripheral != nil {
            otaProfile.connect(to: otaPeripheral!)
        } else {
            closeVC()
        }
    }
    
    @IBAction func btnCloseClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func toUpgradeimages() -> [RTKOTAUpgradeBin]? {
        guard let `otaPeripheral` = otaPeripheral else { return nil }
        
        // According to the current brank situation of the device, filter out the images that do not match
        switch otaPeripheral.activeBank {
        case RTKOTABankTypeBank0:
            return images.filter({$0.upgradeBank == RTKOTAUpgradeBank.unknown || $0.upgradeBank == RTKOTAUpgradeBank.bank1})
        case RTKOTABankTypeBank1:
            return images.filter({$0.upgradeBank == RTKOTAUpgradeBank.unknown  || $0.upgradeBank == RTKOTAUpgradeBank.singleOrBank0 })
        case RTKOTABankTypeSingle:
                let imageForBank1 = self.images.filter({$0.upgradeBank == RTKOTAUpgradeBank.bank1})
                if (imageForBank1.count > 0) {
                    Logger.logInfo("Mismatched file: dualbank pack file - single bank chip")
                    return nil
                } else {
                    return self.images
                }
        default:
            return  images
        }
    }
  
    func onFileHasSelected(_ fileName: String?) {
        guard let `otaPeripheral` = otaPeripheral else {return }
        self.fileName = fileName
        if let binFile = Bundle.main.path(forResource: Constants.firmwareFileName, ofType: ".bin") {
            var priBins: NSArray?
            var secBins: NSArray?
            if otaPeripheral.notEngaged || otaPeripheral.isRWS {
                let err =  RTKOTAUpgradeBin.extractCombinePackFile(withFilePath: binFile, toPrimaryBudBins: &priBins, secondaryBudBins: &secBins)
                if err == nil {
                   switch otaPeripheral.budType {
                    case RTKOTAEarbudPrimary:
                       images = priBins as! [RTKOTAUpgradeBin]
                    case RTKOTAEarbudSecondary:
                       images = secBins as! [RTKOTAUpgradeBin]
                   default:
                       break
                    }
                    if (images.count == 1 && !images.last!.icDetermined) {
                        images.last?.assertAvailable(for: otaPeripheral)
                    }
                }
            } else {
           do {
               images = try RTKOTAUpgradeBin.imagesExtracted(fromMPPackFilePath: binFile)
                if images.count == 1 && !images.last!.icDetermined {
                    images.last?.assertAvailable(for: otaPeripheral)
                }
            } catch {
                Logger.logInfo("OTA imagesExtract \(error.localizedDescription)")
            }
            }
            
        }
        if (toUpgradeimages() != nil && toUpgradeimages()!.count == 0) {
            Logger.logInfo(" OTA MSG:The selected file is invalid or does not match" )
            lblOTAInfo.text = "Updating...(20%)"
        }
        
        startOTA()
    }
    
    func removeLastSelectImages() {
        images = [RTKOTAUpgradeBin]()
        imagesForLeftBud = [RTKOTAUpgradeBin]()
        imagesForRightBud = [RTKOTAUpgradeBin]()
    }

    // MARK: - RTKLEProfileDelegate
    
    func profileManagerDidUpdateState(_ profile: RTKLEProfile) {
        if profile.centralManager.state == .poweredOn {
           // otaProfile.scanForPeripherals()
        }
    }
    
    func profile(_ profile: RTKLEProfile, didDiscover peripheral: RTKLEPeripheral) {
        if peripheral.cbPeripheral.identifier.uuidString == selectedPeripheral!.identifier.uuidString {
            otaProfile.connect(to: peripheral)
            otaProfile.stopScan()
        }
    }
    
    func profile(_ profile: RTKLEProfile, didConnect peripheral: RTKLEPeripheral) {
        
        guard let `otaPeripheral` = otaPeripheral else {return }
        if peripheral == otaPeripheral {
            // Another headset is connected again, directly start the upgrade
            // 再次连接的是另一只耳机，直接启动升级
            if self.otaPeripheral!.isRWS && upgradeNextConnectedPeripheral {
                upgradeSilently = true
                upgradeNextConnectedPeripheral = false
                let DFUPeripheral = otaProfile.dfuPeripheral(of: otaPeripheral)
                DFUPeripheral?.delegate = self
                otaProfile.connect(to: DFUPeripheral!)
                dfuPeripheral = DFUPeripheral as? RTKMultiDFUPeripheral
                Logger.logInfo(" OTA MSG:please wait") // 请稍后
                lblOTAInfo.text = "Updating...(20%)"
                return
            }
            DispatchQueue.main.async {
                CommonFunctions.hideGlobalProgressHUD(UIApplication.topViewController()!)
            }
        } else if (peripheral == self.dfuPeripheral) {
            if toUpgradeimages() != nil {
                print(toUpgradeimages()!)
                dfuPeripheral!.upgradeImages(toUpgradeimages()!, inOTAMode: !upgradeSilently)
                DispatchQueue.main.async(execute: { [self] in
                    timeUpgradeBegin = Date()
                    Logger.logInfo(" OTA MSG:Updating...")
                    lblOTAInfo.text = "Updating...(20%)"
                })
            }
        }
        onFileHasSelected(Constants.firmwareFileName)
        progressView.progress = 0.15
        lblOTAInfo.text = "Updating...(15%)"
    }
    
    func profile(_ profile: RTKLEProfile, didDisconnectPeripheral peripheral: RTKLEPeripheral, error: Error?) {
        Logger.logInfo("RTKLEPeripheral \(peripheral.cbPeripheral.identifier.uuidString)")
        if peripheral == otaPeripheral {
            if error == nil {
                otaPeripheral = nil
            }
        }
    }
    
    func profile(_ profile: RTKLEProfile, didFailToConnect peripheral: RTKLEPeripheral, error: Error?) {
        DispatchQueue.main.async(execute: { [self] in
            Logger.logInfo(" OTA MSG:Failed to connect peripheral \(String(describing: error!.localizedDescription))") // "连接外设失败"
//            lblOTAInfo.textColor = .ColorHomeIconRed
//            lblOTAInfo.text = "Failed to connect peripheral. \(String(describing: error!.localizedDescription))"
            closeVC()
        })
    }
    

// MARK: - RTKMultiDFUPeripheralDelegate
    
    func dfuPeripheral(_ peripheral: RTKDFUPeripheral, didSend length: UInt, totalToSend totalLength: UInt) {
        if peripheral.upgradingImage != nil {
            let totalFile = self.dfuPeripheral?.upgradeImages?.count ?? 1
            let index = dfuPeripheral?.upgradeImages?.firstIndex(of: peripheral.upgradingImage!) ?? 0
            let innerUpdate = (Float(length) / Float(totalLength) ) / 100
            let currentProgress = progressView.progress
            progressView.progress = currentProgress + innerUpdate
            if Float(length) / Float(totalLength) == 1 {
                progressView.progress = ((Float((index + 1) * 100 / (totalFile ))/100 ))
            }
            Logger.logInfo("progress : \(progressView.progress) Updating... \((index) + 1) / \(totalFile)")
            lblOTAInfo.text = "Updating... (\(Int(progressView.progress * 100))%) "
        }
    }
    
    func presentTransmissionSpeed() {
        DispatchQueue.main.async(execute: { [self] in
            var lengthTotalImages = 0
            let arr = toUpgradeimages()!
            for bin in arr {
                lengthTotalImages += bin.data.count
            }
            let interval = Date().timeIntervalSince(timeUpgradeBegin!)
            Logger.logInfo(" OTA MSG:update completed." + String(format: "average rate：%.2f KB/s", (Double(lengthTotalImages) / 1000.0) / interval))
            lblOTAInfo.text = "Update Successfuly.(100%)"
            closeVC(isSuccess: true)
           
        })
    }
    
    func dfuPeripheral(_ peripheral: RTKDFUPeripheral, didFinishWithError err: Error?) {
        if err != nil {
            Logger.logInfo(" OTA MSG:Upgrade failed. \(err!.localizedDescription)")
         //   lblOTAInfo.text = "Upgrade failed. \(err!.localizedDescription)"
            closeVC()
            // 升级失败
        } else {
            // Calculate the total transfer rate // 计算总传输速率
            presentTransmissionSpeed()
        }
    }
    
    func  startOTA() {
        if let upgradeImages = toUpgradeimages() {
            guard let  `otaPeripheral` = otaPeripheral else {return }
            if upgradeImages.count > 0 {
                if otaPeripheral.isRWS {
                    OTAUpgradeRWS()
                } else if otaPeripheral.canEnterOTAMode && otaPeripheral.canUpgradeSliently {
                    let alert = UIAlertController()
                    alert.addAction(UIAlertAction(title: "Normal upgrade", style: .default, handler: { [self] _ in // 普通升级
                        OTAUpgradeNormally()
                    }))
                    
                    alert.addAction(UIAlertAction(title: "silent upgrade", style: .default, handler: { [self] _ in // 静默升级
                        OTAUpgradeSilently()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil)) // 取消
                    UIApplication.topViewController()!.present(alert, animated: true)
                } else if otaPeripheral.canEnterOTAMode {
                    OTAUpgradeNormally()
                } else if otaPeripheral.canUpgradeSliently {
                    OTAUpgradeSilently()
                }
            }
        }
    }
    
    func OTAUpgradeRWS() {
        guard let  `otaPeripheral` = otaPeripheral else {return }
        upgradeSilently = true
        upgradeNextConnectedPeripheral = true
        let DFUPeripheral = otaProfile.dfuPeripheral(of: otaPeripheral)
        DFUPeripheral?.delegate = self
        otaProfile.connect(to: DFUPeripheral!)
        dfuPeripheral = DFUPeripheral as? RTKMultiDFUPeripheral
        Logger.logInfo(" OTA MSG:please wait")
       // lblOTAInfo.text = "Please wait" // 请稍后
    }
    
    func OTAUpgradeSilently() {
        guard let  `otaPeripheral` = otaPeripheral else {return }
        upgradeSilently = true
        Logger.logInfo(" OTA MSG:please wait") // 请稍后
      //  lblOTAInfo.text = "Please Wait"
        let DFUPeripheral = otaProfile.dfuPeripheral(of: otaPeripheral)
        if DFUPeripheral == nil {
            Logger.logInfo(" OTA MSG:Please search for connected peripherals again") // 请重新搜索连接外设
            // lblOTAInfo.text = "Please search for connected peripherals again"
            return
        }
        DFUPeripheral?.delegate = self
        dfuPeripheral = DFUPeripheral as? RTKMultiDFUPeripheral
        otaProfile.connect(to: DFUPeripheral!)
        
    }
    func OTAUpgradeNormally() {
        guard let  `otaPeripheral` = otaPeripheral else {return }
        upgradeSilently = false
        Logger.logInfo(" OTA MSG:please wait") // 请稍后
       // lblOTAInfo.text = "Please wait"
        upgradeSilently = false
        otaProfile.translate(otaPeripheral) { [self] success, _, peripheral in
            if success {
                Logger.logInfo(" OTA MSG: Connecting peripherals in OTA mode") // 连接OTA模式下的外设
                // lblOTAInfo.text = "Connecting peripherals in OTA mode"
                dfuPeripheral = peripheral as? RTKMultiDFUPeripheral
                peripheral!.delegate = self
                otaProfile.connect(to: peripheral!)
            } else {
                Logger.logInfo(" OTA MSG: Failed to switch to OTA mode") // 切换到OTA mode失败
               // lblOTAInfo.text = "Failed to switch to OTA mode"
            }
        }
    }
    
    func closeVC(isSuccess: Bool = false) {
        let peripheral = BLEHelper.shared.connectedPeripheral.first(where: {$0.discoveredPeripheral!.identifier.uuidString == selectedPeripheral!.identifier.uuidString})
        peripheral?.isOTAUpgrade = false
        BLEHelper.shared.connectPeriPheral(peripheral: selectedPeripheral!)
        if isSuccess {
        peripheral?.version = Constants.AppContainsFirmwareVersion
            DatabaseManager.share.updateFWVersion(Constants.AppContainsFirmwareVersion, selectedPeripheral!.identifier.uuidString)
        }
        delay(5) { [self] in
            if isUpdateAll {
//                peripheral?.version = Constants.AppContainsFirmwareVersion
                if let sel = BLEHelper.shared.connectedPeripheral.first(where: {$0.discoveredPeripheral!.state == .connected && $0.version != Constants.AppContainsFirmwareVersion}) {
                    if sel  != selectedPeripheral {
                        sel.isOTAUpgrade = true
                        self.selectedPeripheral = sel.discoveredPeripheral
                        let device = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
                        self.medname =  device.first(where: {$0.udid == sel.discoveredPeripheral?.identifier.uuidString})?.medname ?? ""
                        startConnection()
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
