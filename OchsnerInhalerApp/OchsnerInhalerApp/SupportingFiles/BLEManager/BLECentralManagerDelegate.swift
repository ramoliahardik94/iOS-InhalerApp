//
//  BLECentralManagerDelegate.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 02/02/22.
//

import Foundation
import CoreBluetooth

// MARK: - CBCentralManager Delegate
extension BLEHelper: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // ... so start working with the peripheral
            isAllow = true
            NotificationCenter.default.post(name: .BLEChange, object: nil)
        case .poweredOff:
            isAllow = false
            NotificationCenter.default.post(name: .BLEChange, object: nil)
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
                    NotificationCenter.default.post(name: .BLEChange, object: nil)
                    CommonFunctions.showMessagePermission(message: StringPermissions.blePermissionMsg, cancelTitle: StringCommonMessages.cancel, okTitle: StringProfile.settings, isOpenBluetooth: false) { _ in
                      }
                case .restricted:
                    isAllow = false
                    NotificationCenter.default.post(name: .BLEChange, object: nil)
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
            NotificationCenter.default.post(name: .BLEChange, object: nil)
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        Logger.logInfo("Discovered in range \(String(describing: peripheral.name)) \(peripheral.identifier) at \(RSSI.intValue)")
        // Device is in range - have we already seen it?
        if let name =  peripheral.name {
            if name.lowercased() == "ochsner inhaler tracker" {
                if UserDefaultManager.addDevice.contains(where: {$0 == peripheral.identifier.uuidString}) {
                    discoveredPeripheral = peripheral
                    stopScanPeriphral()
                    stopTimer()
                    connectPeriPheral()
                } else {
                    discoveredPeripheral = peripheral
                    stopScanPeriphral()
                    stopTimer()                   
                    NotificationCenter.default.post(name: .BLEFound, object: nil)
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Logger.logInfo("Peripheral Connected")
        if peripheral.state == .connected {
            Logger.logInfo("Scanning stopped")
            stopScanPeriphral()
            peripheral.delegate = self
            peripheral.discoverServices([TransferService.otaServiceUUID, TransferService.inhealerUTCservice])
        }
    }
        
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Logger.logInfo("DidFail")
        NotificationCenter.default.post(name: .BLENotConnect, object: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Logger.logInfo("state \(peripheral.state.rawValue)")
        NotificationCenter.default.post(name: .BLEDisconnect, object: nil)
        Logger.logInfo("DidDissconnect")
    }
    
    
   
}
