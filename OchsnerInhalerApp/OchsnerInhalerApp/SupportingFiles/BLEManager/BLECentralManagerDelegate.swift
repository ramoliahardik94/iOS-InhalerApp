//
//  BLECentralManagerDelegate.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 02/02/22.
//

import Foundation
import CoreBluetooth

//MARK:- CBCentralManager Delegate
extension BLEHelper : CBCentralManagerDelegate {
    
    //MARK: - Step:4 SetDelegate method For Bloototh Status
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // ... so start working with the peripheral
            print("CBManager is powered on")
            isAllow = true
        case .poweredOff:
            print("CBManager is not powered on")
            isAllow = false
            CommonFunctions.showMessagePermission(message: "Need to use Bluetooth for connection.", cancelTitle: "Cancel", okTitle: "Setting",isOpenBluetooth: true) { isClick in
                 
            }
            // In a real app, you'd deal with all the states accordingly
            return
        case .resetting:
            print("CBManager is resetting")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unauthorized:
            // In a real app, you'd deal with all the states accordingly
            if #available(iOS 13.0, *) {
                switch CBManager.authorization {
                case .denied:
                    print("You are not authorized to use Bluetooth")
                    isAllow = false
                    CommonFunctions.showMessagePermission(message: "Need Bluetooth permission for connect inhaler device", cancelTitle: "Cancel", okTitle: "Setting" , isOpenBluetooth: false) { isClick in
                      }
                case .restricted:
                    isAllow = false
                    print("Bluetooth is restricted")
                    
                case.notDetermined :
                    _ = CBManager.authorization
                default:
                    print("Unexpected authorization")
                }
            } else {
                // Fallback on earlier versions
            }
            return
        case .unknown:
            print("CBManager state is unknown")
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
            print("Bluetooth is not supported on this device")
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            print("A previously unknown central manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Reject if the signal strength is too low to attempt data transfer.
        // Change the minimum RSSI value depending on your app’s use case.
//        guard RSSI.intValue >= -80
//            else {
//                print("Discovered perhiperal not in expected range, at %d", RSSI.intValue)
//                return
//        }
        print("Discovered in range \(String(describing: peripheral.name)) \(peripheral.identifier) at \(RSSI.intValue)")
        // Device is in range - have we already seen it?
      
        if peripheral.state == .disconnected {
            discoveredPeripheral = peripheral
            //MARK: Step:6 Connect to peripheral
            NotificationCenter.default.post(name: .BLEFound, object: nil)
            print(UserDefaultManager.addDevice.count)
            UserDefaultManager.addDevice.insert(peripheral, at: UserDefaultManager.addDevice.count)
        }
    }
   
}
