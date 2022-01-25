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
            
            return
        }
        
        switch self.state {
            
        case .poweredOff:
            
            print("on bluetooth")
            
            break
            
            
        case .unauthorized:
            if #available(iOS 13.0, *) {
                switch CBManager.authorization {
                    
                case .allowedAlways:
                   completion(true)
                    break
                case .denied:
                    print("denied")
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
        @unknown default:
            break
        }
        
        
    }
    
 
    
}

