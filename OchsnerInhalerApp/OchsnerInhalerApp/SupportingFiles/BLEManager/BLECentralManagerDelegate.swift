//
//  BLECentralManagerDelegate.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 02/02/22.
//

import Foundation
import CoreBluetooth
import UIKit
// MARK: - CBCentralManager Delegate
extension BLEHelper: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // ... so start working with the peripheral
            isAllow = true
            bleConnect()
          
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .BLEOnOff, object: nil)
                NotificationCenter.default.post(name: .BLEChange, object: nil)
            }
            
        case .poweredOff:
            isAllow = false
            bleConnect()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .BLEOnOff, object: nil)
                NotificationCenter.default.post(name: .BLEChange, object: nil)
                NotificationCenter.default.post(name: .BLEDisconnect, object: nil)
            }
            // CommonFunctions.showMessagePermission(message: StringPermissions.turnOn, cancelTitle: StringCommonMessages.cancel, okTitle: StringProfile.settings, isOpenBluetooth: true)
            // In a real app, you'd deal with all the states accordingly
            return
        case .resetting:
            // In a real app, you'd deal with all the states accordingly
            return
        case .unauthorized:
            // In a real app, you'd deal with all the states accordingly
            if #available(iOS 13.0, *) {
                switch CBManager.authorization {
                case .denied:
                    isAllow = false
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .BLEChange, object: nil)
                    }
                    CommonFunctions.showMessagePermission(message: StringPermissions.blePermissionMsg, cancelTitle: StringCommonMessages.cancel, okTitle: StringProfile.settings, isOpenBluetooth: false) { _ in
                    }
                case .restricted:
                    isAllow = false
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .BLEChange, object: nil)
                    }
                case.notDetermined :
                    _ = CBManager.authorization
                default:
                    break
                }
            } else {
                // Fallback on earlier versions
            }
            return
        case .unknown:
            // In a real app, you'd deal with all the states accordingly
            return
        case .unsupported:
#if targetEnvironment(simulator)
            // your simulator code
            isAllow = true
#else
            // your real device code
            isAllow = false
#endif
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .BLEChange, object: nil)
            }
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        
        guard RSSI.intValue >= -55
        else {
            print("Discovered perhiperal \(String(describing: peripheral.name))  \(peripheral.identifier) not in expected range, at %d", RSSI.intValue)
            return
        }
        
        Logger.logInfo("Discovered in range \(String(describing: peripheral.name)) \(peripheral.identifier) at \(RSSI.intValue)")
        
        let devicelist = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email).map({$0.udid})
        
        if let name =  peripheral.name {
            debugPrint("Service : \(String(describing: peripheral.services))")
            
            if name.lowercased() == Constants.deviceName {
                let device = devicelist.filter({$0?.trimmingCharacters(in: .whitespacesAndNewlines) != ""})
                
                if isAddAnother && !device.contains(where: {$0 == peripheral.identifier.uuidString}) {
                    discoveredPeripheral = peripheral
                    stopScanPeriphral()
                    stopTimer()
                    delay(isAddAnother ? 15 : 0) {
                        Logger.logInfo("isAddAnother && !device.contains(where: {$0 == peripheral.identifier.uuidString})")
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .BLEFound, object: nil)
                        }
                    }
                } else {
                    if device.count > 0 && device.contains(where: {$0 == peripheral.identifier.uuidString}) {
                        Logger.logInfo("device.count > 0 && device.contains(where: {$0 == peripheral.identifier.uuidString})")
                        discoveredPeripheral = peripheral
                        stopScanPeriphral()
                        stopTimer()
                        connectPeriPheral()
                    }
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral.state == .connected {
            macCharecteristic = nil
            charectristicWrite = nil
            stopScanPeriphral()
            peripheral.delegate = self
            peripheral.discoverServices(TransferService.serviceArray)
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .BLEChange, object: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.stopTimer()
        Logger.logError("BLENotConnect With Fail \(error?.localizedDescription ?? "")")
        isScanning = false
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .BLEChange, object: nil)
            NotificationCenter.default.post(name: .BLENotConnect, object: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if !isAddAnother && UserDefaultManager.isLogin {
            scanPeripheral(isTimer: false)
        }
        self.stopTimer()
        self.cleanup()
        isScanning = false
        Logger.logError("BLENotConnect With DidDissconnect \(error?.localizedDescription ?? "")")
        DispatchQueue.main.async {
            Logger.logInfo("BLEDisconnect,BLEChange notification fire")
            NotificationCenter.default.post(name: .BLEDisconnect, object: nil)
            NotificationCenter.default.post(name: .BLEChange, object: nil)
        }
    }
    
    func addAnotherDevice() {
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        addDeviceIntroVC.step = .step1
        addDeviceIntroVC.isFromAddAnother  = true
        addDeviceIntroVC.isFromDeviceList  = true
        BLEHelper.shared.isAddAnother = true     
        if let topVC =  UIApplication.topViewController() {
            topVC.navigationController?.pushViewController(addDeviceIntroVC, animated: true)
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        // get the handle to the peripheral already connected by the os and set ourselves as the delegate
        if centralManager.state == .poweredOn {
            let devicelist = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
            if UserDefaultManager.isLogin  && UserDefaultManager.isGrantBLE && UserDefaultManager.isGrantLaocation && UserDefaultManager.isGrantNotification && devicelist.count > 0 {
                if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
                    if (peripherals.count > 0) {
                        if let peripheral = peripherals.first(where: {$0.state == .connected}) {
                            Logger.logInfo("willRestoreState \(peripherals)")
                            discoveredPeripheral = peripheral                    
                        } else {
                            discoveredPeripheral = peripherals[0]
                        }
                        discoveredPeripheral!.delegate = self
                    }
                }
            }
        }
    }
}
