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
    var charectristicWrite : CBCharacteristic?
    var charectristicRead : CBCharacteristic?
    var addressMAC : String = ""
    var completionHandler: (Bool)->Void = {_ in }
   // var a = 1
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
    func setRTCTime()->String{
        
        
        let year = DecimalToHax(value: Date().getString( format: "yyyy",isUTC: true),byte: 2)
        let day = DecimalToHax(value: Date().getString(format: "dd", isUTC: true))
        let month = DecimalToHax(value: Date().getString(format: "MM", isUTC: true))
        let hour = DecimalToHax(value: Date().getString(format: "HH", isUTC: true))
        let min = DecimalToHax(value: Date().getString(format: "mm", isUTC: true))
        let sec = DecimalToHax(value: Date().getString(format: "s", isUTC: true))
       
        let haxRTC = "AA015507" + year+day+month+hour+min+sec
        if discoveredPeripheral != nil && charectristicWrite != nil {
        discoveredPeripheral!.writeValue(haxRTC.hexadecimal!, for: charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        }
        print(haxRTC)
        return haxRTC
        
        // Discover the characteristic we want...
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
             // MARK: Step:8 Search only for Characteristics that match our UUID
            peripheral.discoverCharacteristics([TransferService.characteristicNotifyUUID,TransferService.characteristicWriteUUID], for: service)
        }
    }
   
    
    func DecimalToHax(value:String,byte:Int = 1)->String{
        var haxStr = ""
        switch byte{
        case 1:
            if let val = UInt8(value) {
                let data = val.bigEndian
                haxStr = String(format:"%02X", data)
            }
        case 2:
            if  let val = UInt16(value) {
                let data = val.bigEndian
                haxStr = String(format:"%04X", data)
            }
        default :
            if let val = UInt8(value) {
                let data = val.bigEndian
                haxStr = String(format:"%02X", data)
            }
        }
        return haxStr
    }
    
    func HexToDecimal(value:String,byte:Int = 1 )-> Decimal {
        var decimalValue = Decimal()
        switch byte{
        case 1:
            if let val = UInt8(value, radix: 16) {
                decimalValue = Decimal(val.bigEndian)
            }
        case 2:
            if let val = UInt16(value, radix: 16) {
                decimalValue = Decimal(val.bigEndian)
            }
        default :
            if let val = UInt8(value, radix: 16) {
                decimalValue = Decimal(val.bigEndian)
            }
        }
        print(decimalValue)
        return decimalValue
    }
}


extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}
