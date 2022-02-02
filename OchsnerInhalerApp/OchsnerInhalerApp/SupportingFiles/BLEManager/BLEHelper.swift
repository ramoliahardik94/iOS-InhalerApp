//
//  BLEHelper.swift
//  BLE_Demo_Final
//
//  Created by Nikita Bhatt on 13/01/22.
//

import Foundation
//MARK: - Step:1 import CoreBluetooth Library
//MARK:  Step:2 add NSBluetoothAlwaysUsageDescription for Bluetooth permition
import CoreBluetooth

class BLEHelper : NSObject {
    
    //MARK: Variable declaration
    static let shared = BLEHelper()
    var centralManager : CBCentralManager = CBCentralManager()
    var discoveredPeripheral: CBPeripheral?
    var completionHandler: (Bool)->Void = {_ in }
    var a = 1
    var isAllow = false
    
    func setDelegate(){
        //MARK:  Step:3 Create object of CBCentralManager
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    
    //MARK: Function declarations
    /// This function is used for starScan of peripheral base on service(CBUUID) UUID
    ///
    //MARK: Step 5 : Scan near by peripherals
 
  
    
    
    func isAllowed(completion: @escaping ((Bool) -> Void)) {
        completion(isAllow)
    }
}
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
    //MARK:- CBPeripheral Delegate
extension BLEHelper : CBPeripheralDelegate {
    
    /*
     *  We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected")
        NotificationCenter.default.post(name: .BLEConnect, object: nil)
        // Stop scanning
        centralManager.stopScan()
        print("Scanning stopped")
        
        peripheral.delegate = self
        
        //MARK: Step:7 Search only for services that match our UUID
        peripheral.discoverServices([TransferService.otaServiceUUID,TransferService.inhealerUTCservice])
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NotificationCenter.default.post(name: .BLENotConnect, object: nil)
    }
    
    // implementations of the CBPeripheralDelegate methods

    /*
     *  The peripheral letting us know when services have been invalidated.
     */
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
        for service in invalidatedServices where service.uuid == TransferService.inhealerUTCservice {
            print("Transfer service is invalidated - rediscover services")
            peripheral.discoverServices([TransferService.inhealerUTCservice])
        }
        for service in invalidatedServices where service.uuid == TransferService.otaServiceUUID {
            print("Transfer service is invalidated - rediscover services")
            peripheral.discoverServices([TransferService.otaServiceUUID])
        }
    }

    /*
     *  The Transfer Service was discovered
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        // Discover the characteristic we want...
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            //MARK: Step:8 Search only for Characteristics that match our UUID
            peripheral.discoverCharacteristics([TransferService.characteristicNotifyUUID,TransferService.characteristicWriteUUID], for: service)
        }
    }
    
    /*
     *  The Transfer characteristic was discovered.
     *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Deal with errors (if any).
        if let error = error {
            print("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        // Again, we loop through the array, just in case and check if it's the right one
        guard let serviceCharacteristics = service.characteristics else { return }
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.macCharecteristic {
            // If it is, subscribe to it
            //MARK: Step:9 sets indication for specific characteristic
            peripheral.setNotifyValue(true, for: characteristic)
            let mac = peripheral.value(forKey: "value")
            print(mac!)
        }
        
        // Once this is complete, we just need to wait for the data to come in.
    }
    
    /*
     *   This callback lets us know more data has arrived via notification on the characteristic
     */
    //MARK: Step:10.1 Get value for charecteristic from BLE
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        guard let characteristicData = characteristic.value,
            let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
        
            print("Received %d bytes: %s", characteristicData.count, stringFromData)
        
    //TODO: I'll have to understand this logic base on device get data
//        // Have we received the end-of-message token?
//        if stringFromData == "EOM" {
//            // End-of-message case: show the data.
//            // Dispatch the text view update to the main queue for updating the UI, because
//            // we don't know which thread this method will be called back on.
//            DispatchQueue.main.async() {
//                self.textView.text = String(data: self.data, encoding: .utf8)
//            }
//
//            // Write test data
//            writeData()
//        } else {
//            // Otherwise, just append the data to what we have previously received.
//            data.append(characteristicData)
//        }
    }

    /*
     *  The peripheral letting us know whether our subscribe/unsubscribe happened or not
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error changing notification state: %s", error.localizedDescription)
            return
        }
        
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid == TransferService.characteristicNotifyUUID else { return }
        
        if characteristic.isNotifying {
            // Notification has started
            print("Notification began on %@", characteristic)
        } else {
            // Notification has stopped, so disconnect from the peripheral
            print("Notification stopped on %@. Disconnecting", characteristic)
            cleanup()
        }
        
    }
    
    /*
     *  This is called when peripheral is ready to accept more data when using write without response
     */
    //MARK: Step:10.2 write value to peripheral
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
       print("Peripheral is ready, send data")
    }
}


