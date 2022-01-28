//
//  BluetoothManager.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 25/01/22.
//

import Foundation
import CoreBluetooth

class BluetoothManager : CBCentralManager {
    
    static let shared = BluetoothManager()
    
    
    
    
    func isAllowed(completion: @escaping ((Bool) -> Void)) {
    
        
        if self.state == .poweredOff {
            print("off bluetooth")
            CommonFunctions.showMessagePermission(message: "Need to use Bluetooth for connection.", cancelTitle: "Cancel", okTitle: "Setting",isOpenBluetooth: true) { isClick in
                 
            }
            return
        }
        
        switch self.state {
            
        case .unauthorized:
            if #available(iOS 13.0, *) {
                switch CBManager.authorization {
                    
                case .allowedAlways:
                   completion(true)
                    break
                case .denied:
                    print("denied")
                    CommonFunctions.showMessagePermission(message: "Need Bluetooth permission for connect inhaler device", cancelTitle: "Cancel", okTitle: "Setting" , isOpenBluetooth: false) { isClick in
                         
                    }
                    break
                case .restricted:
                    print("restricted")
                    break
                case .notDetermined:
                    _ = CBManager.authorization
                    break
                @unknown default:
                    return
                }
            }
            
            
        case .unknown:
            
            break
        case .unsupported:
            
            break
        case .poweredOn:
            completion(true)
           // self.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
            break
            
        case .resetting:
            
            break
        
        case .poweredOff:
            break
        @unknown default:
            break
        }
        
        
    }
    
 
    
}

