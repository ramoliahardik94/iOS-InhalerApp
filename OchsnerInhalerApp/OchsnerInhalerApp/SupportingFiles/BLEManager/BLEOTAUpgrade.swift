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
    var selectedPeripheral: CBPeripheral?
     
    override func viewDidLoad() {
        otaProfile = RTKOTAProfile()
        otaProfile.delegate = self
        lblOTAInfo.text = ""
        progressView.progress = 0
    }
    override func viewDidAppear(_ animated: Bool) {
        
        self.otaPeripheral = otaProfile.otaPeripheral(from: selectedPeripheral!)
        lblOTAInfo.text = "Connecting device in OTA mode"
        if otaPeripheral != nil {
            otaProfile.connect(to: otaPeripheral!)
        } else {
            closeVC()
        }
    }
    
    func imagesUserSelected() -> [RTKOTAUpgradeBin] {
        guard let `otaPeripheral` = otaPeripheral else { return [RTKOTAUpgradeBin]()}
        if otaPeripheral.isRWS {
            return otaPeripheral.budType == RTKOTAEarbudLeft ? imagesForLeftBud : imagesForRightBud
        }
        return images
    }
    
    func toUpgradeimages() -> [RTKOTAUpgradeBin]? {
        guard let `otaPeripheral` = otaPeripheral else { return nil }
        // 根据设备目前brank情况，过滤掉不符合的image
        // According to the current brank situation of the device, filter out the images that do not match
        let arr = imagesUserSelected()
        return arr
        switch otaPeripheral.freeBank {
        case 0x00:
            return arr.filter({$0.bank == .unknown || $0.bank == .bank0})
        case 0x01:
            return arr.filter({$0.bank == .unknown || $0.bank == .bank1})
        default:
            return imagesUserSelected()
        }
    }
  
    
    
    func onFileHasSelected(_ fileName: String?) {
        guard let `otaPeripheral` = otaPeripheral else {return }
        self.fileName = fileName
        if let binFile = Bundle.main.path(forResource: Constants.firmwareFileName, ofType: ".bin") {
            if otaPeripheral.isRWS {
                var primaryBins: NSArray?
                var secondaryBins: NSArray?
                let err = RTKOTAUpgradeBin.extractCombinePackFile(withFilePath: binFile, toPrimaryBins: &primaryBins, secondaryBins: &secondaryBins)
                if (err != nil) {
                    imagesForLeftBud = primaryBins as! [RTKOTAUpgradeBin]
                    imagesForRightBud = secondaryBins as! [RTKOTAUpgradeBin]
                    
                    if imagesForLeftBud.count == 1 && !imagesForLeftBud.last!.icDetermined {
                        imagesForLeftBud.last?.assertAvailable(for: otaPeripheral)
                    }
                    if imagesForRightBud.count == 1 && !imagesForRightBud.last!.icDetermined {
                        imagesForRightBud.last?.assertAvailable(for: otaPeripheral)
                    }
                }
            } else if (otaPeripheral.notEngaged) {
                var primaryBins: NSArray?
                var secondaryBins: NSArray?
                let err = RTKOTAUpgradeBin.extractCombinePackFile(withFilePath: binFile, toPrimaryBins: &primaryBins, secondaryBins: &secondaryBins)
                if (err != nil) {
                    switch otaPeripheral.budType {
                    case RTKOTAEarbudLeft:
                        images = primaryBins as! [RTKOTAUpgradeBin]
                    case RTKOTAEarbudRight:
                        images = secondaryBins as! [RTKOTAUpgradeBin]
                    default :
                        break
                    }
                    if (images.count == 1 && !images.last!.icDetermined) {
                        images.last?.assertAvailable(for: otaPeripheral)
                    }
                } else {
                    
                    do {
                        images = try RTKOTAUpgradeBin.imagesExtract(fromMPPackFilePath: binFile)
                        if images.count == 1 && !images.last!.icDetermined {
                            images.last?.assertAvailable(for: otaPeripheral)
                        }
                    } catch {
                        Logger.logInfo("OTA imagesExtract \(error.localizedDescription)")
                    }
                }
            } else {
                do {
                    images = try RTKOTAUpgradeBin.imagesExtract(fromMPPackFilePath: binFile)
                    if images.count == 1 && !images.last!.icDetermined {
                        images.last?.assertAvailable(for: otaPeripheral)
                    }
                } catch {
                    Logger.logInfo("OTA imagesExtract \(error.localizedDescription)")
                }
            }
            if (toUpgradeimages() != nil && toUpgradeimages()!.count == 0) {
                Logger.logInfo(" OTA MSG:The selected file is invalid or does not match" ) // 选择的文件无效或不匹配
                lblOTAInfo.text = "The selected file is invalid or does not match"
            }
            startOTA()
        }
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
                lblOTAInfo.text = "Please wait"
                return
            }
            DispatchQueue.main.async {
                CommonFunctions.hideGlobalProgressHUD(UIApplication.topViewController()!)
            }
        } else if (peripheral == self.dfuPeripheral) {
            print(toUpgradeimages()!)
            dfuPeripheral!.upgradeImages(toUpgradeimages()!, inOTAMode: !upgradeSilently)
            DispatchQueue.main.async(execute: { [self] in
                timeUpgradeBegin = Date()
                Logger.logInfo(" OTA MSG:Updating...")
                lblOTAInfo.text = "Updating..."
            })
        }
        onFileHasSelected(Constants.firmwareFileName)
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
            lblOTAInfo.text = "Failed to connect peripheral. \(String(describing: error!.localizedDescription))"
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
            print("progress : \(progressView.progress)")
            lblOTAInfo.text = "Updating... \((index) + 1) / \(totalFile) "
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
            lblOTAInfo.text = "Update Successfuly."
            delay(1) {
                self.lblOTAInfo.text = "Conneting with new firmware."
            }
            closeVC()
           
        })
    }
    
    func dfuPeripheral(_ peripheral: RTKDFUPeripheral, didFinishWithError err: Error?) {
        if err != nil {
            Logger.logInfo(" OTA MSG:Upgrade failed. \(err!.localizedDescription)")
            lblOTAInfo.text = "Upgrade failed. \(err!.localizedDescription)"
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
                  //  assert(otaPeripheral.canUpgradeSliently, "RWS peripheral only support silent OTA upgrade.")
                    upgradeSilently = true
                    upgradeNextConnectedPeripheral = true
                    let DFUPeripheral = otaProfile.dfuPeripheral(of: otaPeripheral)
                    DFUPeripheral?.delegate = self
                    otaProfile.connect(to: DFUPeripheral!)
                    dfuPeripheral = DFUPeripheral as? RTKMultiDFUPeripheral
                    Logger.logInfo(" OTA MSG:please wait")
                    lblOTAInfo.text = "Please wait" // 请稍后
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
    func OTAUpgradeSilently() {
        guard let  `otaPeripheral` = otaPeripheral else {return }
        upgradeSilently = true
        Logger.logInfo(" OTA MSG:please wait") // 请稍后
        lblOTAInfo.text = "Please Wait"
        let DFUPeripheral = otaProfile.dfuPeripheral(of: otaPeripheral)
        if DFUPeripheral == nil {
            Logger.logInfo(" OTA MSG:Please search for connected peripherals again") // 请重新搜索连接外设
            lblOTAInfo.text = "Please search for connected peripherals again"
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
        lblOTAInfo.text = "Please wait"
        upgradeSilently = false
        otaProfile.translate(otaPeripheral) { [self] success, _, peripheral in
            if success {
                Logger.logInfo(" OTA MSG: Connecting peripherals in OTA mode") // 连接OTA模式下的外设
                lblOTAInfo.text = "Connecting peripherals in OTA mode"
                 
                dfuPeripheral = peripheral as? RTKMultiDFUPeripheral
                peripheral!.delegate = self
                otaProfile.connect(to: peripheral!)
            } else {
                Logger.logInfo(" OTA MSG: Failed to switch to OTA mode") // 切换到OTA mode失败
                lblOTAInfo.text = "Failed to switch to OTA mode"
            }
        }
    }
    
    func closeVC() {
        let peripheral = BLEHelper.shared.connectedPeripheral.first(where: {$0.discoveredPeripheral!.identifier.uuidString == selectedPeripheral!.identifier.uuidString})
        peripheral?.isOTAUpgrade = false
        let device = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        let deviceUUID = device.filter({$0.udid?.trimmingCharacters(in: .whitespacesAndNewlines) != ""}).map({UUID(uuidString: $0.udid!)!})
        let arrDevice = BLEHelper.shared.centralManager.retrievePeripherals(withIdentifiers: deviceUUID)
        for obj in arrDevice where obj.state != .connected {
            Logger.logInfo("Connect to:\(device.first(where: {$0.udid == obj.identifier.uuidString})!.mac ?? "\(obj.identifier.uuidString)")")
            BLEHelper.shared.connectPeriPheral(peripheral: obj)
        }
        delay(5) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
