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
        case .poweredOff:
            isAllow = false
            CommonFunctions.showMessagePermission(message: "Need to use Bluetooth for connection.", cancelTitle: "Cancel", okTitle: "Setting", isOpenBluetooth: true)
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
                    CommonFunctions.showMessagePermission(message: "Need Bluetooth permission for connect inhaler device", cancelTitle: "Cancel", okTitle: "Setting", isOpenBluetooth: false) { _ in
                      }
                case .restricted:
                    isAllow = false
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
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("Discovered in range \(String(describing: peripheral.name)) \(peripheral.identifier) at \(RSSI.intValue)")
        // Device is in range - have we already seen it?
        if let name =  peripheral.name {
            if name.lowercased() == "ochsner inhaler tracker" {
                discoveredPeripheral = peripheral
                stopScanPeriphral()
                peripheral.delegate = self     
                stopTimer()
                UserDefaultManager.addDevice.append(peripheral.identifier.uuidString)
                NotificationCenter.default.post(name: .BLEFound, object: nil)                
            }
        }
    }
   
}
