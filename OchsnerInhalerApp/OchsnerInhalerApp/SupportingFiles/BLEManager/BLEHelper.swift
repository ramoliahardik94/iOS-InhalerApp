//
//  BLEHelper.swift
//  BLE_Demo_Final
//
//  Created by Nikita Bhatt on 13/01/22.
//

import Foundation
// MARK: Step:1 import CoreBluetooth Library
// MARK: Step:2 add NSBluetoothAlwaysUsageDescription for Bluetooth permition
import CoreBluetooth

class BLEHelper: NSObject {
    
    // MARK: Variable declaration
    static let shared = BLEHelper()
    var centralManager: CBCentralManager = CBCentralManager()
    var discoveredPeripheral: CBPeripheral?
    var charectristicWrite: CBCharacteristic?
    var charectristicRead: CBCharacteristic?
    var addressMAC: String = ""
    var completionHandler: (Bool) -> Void = {_ in }
   // var a = 1
    var isAllow = false
    
    func setDelegate() {
        // MARK: Step:3 Create object of CBCentralManager
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    
    // MARK: Function declarations
    /// This function is used for starScan of peripheral base on service(CBUUID) UUID
    ///
    // MARK: Step 5 : Scan near by peripherals
    
    func isAllowed(completion: @escaping ((Bool) -> Void)) {
        completion(isAllow)
    }
    func setRTCTime() -> String {
        let year = decimalToHax(value: Date().getString( format: "yyyy", isUTC: true), byte: 2)
        let day = decimalToHax(value: Date().getString(format: "dd", isUTC: true))
        let month = decimalToHax(value: Date().getString(format: "MM", isUTC: true))
        let hour = decimalToHax(value: Date().getString(format: "HH", isUTC: true))
        let min = decimalToHax(value: Date().getString(format: "mm", isUTC: true))
        let sec = decimalToHax(value: Date().getString(format: "s", isUTC: true))
       
        let haxRTC = "AA015507" + year+day+month+hour+min+sec
        if discoveredPeripheral != nil && charectristicWrite != nil {
        discoveredPeripheral!.writeValue(haxRTC.hexadecimal!, for: charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        }
        print(haxRTC)
        return haxRTC
        
    }
   
    
    func decimalToHax(value: String, byte: Int = 1) -> String {
        var haxStr = ""
        switch byte {
        case 1:
            if let val = UInt8(value) {
                let data = val.bigEndian
                haxStr = String(format: "%02X", data)
            }
        case 2:
            if  let val = UInt16(value) {
                let data = val.bigEndian
                haxStr = String(format: "%04X", data)
            }
        default :
            if let val = UInt8(value) {
                let data = val.bigEndian
                haxStr = String(format: "%02X", data)
            }
        }
        return haxStr
    }
    
    func hexToDecimal(value: String, byte: Int = 1 ) -> Decimal {
        var decimalValue = Decimal()
        switch byte {
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
        
        let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex?.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}
