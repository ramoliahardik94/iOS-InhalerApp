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
    
    
    ///   Invoked whenever the central manager's state has been updated. Commands should only be issued when the state is  <code>CBCentralManagerStatePoweredOn</code>. A state below <code>CBCentralManagerStatePoweredOn</code> implies that scanning has stopped and any connected peripherals have been disconnected. If the state moves below <code>CBCentralManagerStatePoweredOff</code>, all <code>CBPeripheral</code> objects obtained from this central manager become invalid and must be retrieved or discovered again.
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
    
    /// This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. A discovered peripheral must be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager. For a list of <i>advertisementData</i> keys, see {@link CBAdvertisementDataLocalNameKey} and other similar constants.
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
//        guard RSSI.intValue >= -55
//        else {
//            print("Discovered perhiperal \(String(describing: peripheral.name))  \(peripheral.identifier) not in expected range, at %d", RSSI.intValue)
//            return
//        }
        
        let devicelist = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email).map({$0.udid})
        
        if let name =  peripheral.name {
            
            if name.lowercased() == Constants.deviceName {
                let device = devicelist.filter({$0?.trimmingCharacters(in: .whitespacesAndNewlines) != ""})
                
                if isAddAnother && !device.contains(where: {$0 == peripheral.identifier.uuidString}) {
                    Logger.logInfo("Found device for add device \(peripheral)")
                    newDeviceId = peripheral.identifier.uuidString
                    connectedPeripheral.append(PeriperalType(peripheral: peripheral))
                    stopScanPeriphral()
                    stopTimer()
                    delay(isAddAnother ? Constants.ScanningScreenDelay : 0) {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .BLEFound, object: nil)
                        }
                    }
                } else {
                    if device.count > 0 && device.contains(where: {$0 == peripheral.identifier.uuidString}) {
                        Logger.logInfo("Found device for auto connect \(peripheral)")
                        newDeviceId = ""
                        let isContenits = connectedPeripheral.contains(where: {$0.discoveredPeripheral!.identifier.uuidString == peripheral.identifier.uuidString})
                        if !isContenits {
                            connectedPeripheral.append(PeriperalType(peripheral: peripheral))
                        }
                        connectPeriPheral(peripheral: peripheral)
                        let connectedDevice = connectedPeripheral.filter({$0.discoveredPeripheral?.state == .connected || $0.discoveredPeripheral?.state == .connecting})
                        print("\(connectedDevice.count)")
                        self.countOfScanDevice += 1
                        if connectedDevice.count == device.count {
                            stopScanPeriphral()
                            stopTimer()
                        }
                    }
                }
            }
        }
    }
    
    /// This method is invoked when a connection initiated by {@link connectPeripheral:options:} has succeeded.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral.state == .connected {
            guard let discoverPeripheral = connectedPeripheral.first(where: {peripheral.identifier.uuidString == $0.discoveredPeripheral?.identifier.uuidString}) else { return }
            Logger.logInfo("Connecting \(discoverPeripheral.addressMAC)")
            discoverPeripheral.macCharecteristic = nil
            discoverPeripheral.charectristicWrite = nil
            discoverPeripheral.charectristicNotify = nil
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .BLEChange, object: nil)
        }
    }
    /// This method is invoked when a connection initiated by {@link connectPeripheral:options:} has failed to complete. As connection attempts do not timeout, the failure of a connection is atypical and usually indicative of a transient issue.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.stopTimer()
        Logger.logError("BLENotConnect With Fail \(error?.localizedDescription ?? "")")
        isScanning = false
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .BLEChange, object: nil)
            NotificationCenter.default.post(name: .BLENotConnect, object: nil)
        }
    }
    /// This method is invoked upon the disconnection of a peripheral that was connected by {@link connectPeripheral:options:}. If the disconnection was not initiated by {@link cancelPeripheralConnection}, the cause will be detailed in the <i>error</i> parameter. Once this method has been called, no more methods will be invoked on <i>peripheral</i>'s <code>CBPeripheralDelegate</code>.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let discoverPeripheral = connectedPeripheral.first(where: {peripheral.identifier.uuidString == $0.discoveredPeripheral?.identifier.uuidString}) else { return }
        if !discoverPeripheral.isOTAUpgrade {
            if !isAddAnother && UserDefaultManager.isLogin {
                Logger.logInfo("Scan with didDisconnectPeripheral \(peripheral)")
                scanPeripheral(isTimer: false)
            } else {
                self.stopTimer()
                self.cleanup(peripheral: peripheral)
                isScanning = false
            }
            Logger.logError("BLENotConnect With DidDissconnect \(discoverPeripheral.addressMAC) \(error?.localizedDescription ?? "")")
            DispatchQueue.main.async {
                Logger.logInfo("BLEDisconnect,BLEChange notification fire")
                if !self.isAddAnother || self.newDeviceId == peripheral.identifier.uuidString {
                    NotificationCenter.default.post(name: .BLEDisconnect, object: nil)
                    NotificationCenter.default.post(name: .BLEChange, object: nil)
                }
            }
        }
    }
    
    /// For apps that opt-in to state preservation and restoration, this is the first method invoked when your app is relaunched into the background to complete some Bluetooth-related task. Use this method to synchronize your app's state with the state of the Bluetooth system.
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        Logger.logInfo("willRestoreState \n\n  \(dict) ")
        let devicelist = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        if UserDefaultManager.isLogin  && UserDefaultManager.isGrantBLE && UserDefaultManager.isGrantLaocation && UserDefaultManager.isGrantNotification && devicelist.count > 0 {
            connectedPeripheral.removeAll()
            if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
                if (peripherals.count > 0) {
                    for obj in peripherals {
                        let mac = DatabaseManager.share.getMac(UDID: obj.identifier.uuidString)
                        if devicelist.first(where: {$0.mac == mac}) != nil {
                            connectedPeripheral.append(PeriperalType(peripheral: obj, mac: mac))
                            obj.delegate = self
                        } else {
                            obj.delegate = self
                            delay(2) { [self] in
                                cleanup(peripheral: obj)
                            }
                            
                        }
                    }
                }
            }
        }
    }
}
