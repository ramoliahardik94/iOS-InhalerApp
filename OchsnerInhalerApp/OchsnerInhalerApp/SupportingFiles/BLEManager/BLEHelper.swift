//
//   BLEHelper.swift
//   BLE_Demo_Final
//
//   Created by Nikita Bhatt on 13/01/22.
//

import Foundation
import CoreBluetooth

class BLEHelper: NSObject {
    
    // MARK: Variable declaration
    static let shared = BLEHelper()
    
    var centralManager: CBCentralManager = CBCentralManager()
    var discoveredPeripheral: CBPeripheral?
    var charectristicWrite: CBCharacteristic?
    var charectristicRead: CBCharacteristic?
    var macCharecteristic: CBCharacteristic?
    var addressMAC: String = "N/A"
    var completionHandler: (Bool) -> Void = {_ in }
    var isAllow = false
    var timer: Timer!
    
    func setDelegate() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    
    // MARK: Function declarations
    // / This function is used for starScan of peripheral base on service(CBUUID) UUID
    // /
    
    func isAllowed(completion: @escaping ((Bool) -> Void)) {
        completion(isAllow)
    }
    func setRTCTime() {
        let year =  Date().getString( format: "yyyy", isUTC: true).decimalToHax(byte: 2)
        let day =  Date().getString(format: "dd", isUTC: true).decimalToHax()
        let month =  Date().getString(format: "MM", isUTC: true).decimalToHax()
        let hour =  Date().getString(format: "HH", isUTC: true).decimalToHax()
        let min =  Date().getString(format: "mm", isUTC: true).decimalToHax()
        let sec =  Date().getString(format: "s", isUTC: true).decimalToHax()
        let haxRTC = TransferService.addRTSStartByte + year+day+month+hour+min+sec
        if discoveredPeripheral != nil && charectristicWrite != nil {
            discoveredPeripheral!.writeValue(haxRTC.hexadecimal!, for: charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    func getBetteryLevel() {
        if discoveredPeripheral != nil && charectristicWrite != nil {
            discoveredPeripheral?.writeValue(TransferService.requestGetBettery.hexadecimal!, for: charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func getAccuationNumber() {
        if discoveredPeripheral != nil && charectristicWrite != nil {
            discoveredPeripheral?.writeValue(TransferService.requestGetNoAccuation.hexadecimal!, for: charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func getAccuationLog() {
        if discoveredPeripheral != nil && charectristicWrite != nil {
            discoveredPeripheral?.writeValue(TransferService.requestGetAcuationLog.hexadecimal!, for: charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    func getmacAddress() {
        if discoveredPeripheral != nil && macCharecteristic != nil {
            discoveredPeripheral?.readValue(for: macCharecteristic!)
        }
    }
}


extension String {
    
    func getNumberofAccuationLog( ) -> Decimal {
        var arrResponce = self.split(separator: ":")
        arrResponce.remove(at: 0)//  StartByte
        arrResponce.remove(at: 0)// OPCODE
        arrResponce.remove(at: 0)// OPCODE
        _ =  UInt8(arrResponce[0], radix: 16) // payloadLenth
        arrResponce.remove(at: 0)
        let strCount = arrResponce.joined(separator: "")
        let logCount =  UInt16(strCount, radix: 16)!
        return Decimal(logCount)
    }
    
    func getBeteryLevel() -> Decimal {
        var arrResponce = self.split(separator: ":")
        arrResponce.remove(at: 0)//  StartByte
        arrResponce.remove(at: 0)// OPCODE
        arrResponce.remove(at: 0)// OPCODE
        _ =  UInt8(arrResponce[0], radix: 16) // payloadLenth
        arrResponce.remove(at: 0)// PlayLoad Lenth
        let betteryLevel =  UInt8(arrResponce[0], radix: 16)!
        return Decimal(betteryLevel)
    }
    func getAcuationLog() ->  (id: Decimal, date: String, uselength: Decimal) {
        
        var arrResponce = self.split(separator: ":")
        arrResponce.remove(at: 0)//  StartByte
        arrResponce.remove(at: 0)//  OPCODE
        arrResponce.remove(at: 0)//  OPCODE
        let payloadLenth =  UInt8(arrResponce[0], radix: 16)! // payloadLenth
        if payloadLenth != 0 {
            arrResponce.remove(at: 0)//  PlayLoad Lenth
            let idStr = "\(arrResponce[0])\(arrResponce[1])"
            let logCount =  UInt16(idStr, radix: 16)!.bigEndian
            arrResponce.remove(at: 0)//  ID
            arrResponce.remove(at: 0)//  ID
            let yearStr = "\(arrResponce[0])\(arrResponce[1])"
            let year =  UInt16(yearStr, radix: 16)!.bigEndian
            arrResponce.remove(at: 0)// Year
            arrResponce.remove(at: 0)// Year
            let month = UInt8(arrResponce[0], radix: 16)!
            arrResponce.remove(at: 0)// Month
            let day = UInt8(arrResponce[0], radix: 16)!
            arrResponce.remove(at: 0)// day
            let hour = UInt8(arrResponce[0], radix: 16)!
            arrResponce.remove(at: 0)// huor
            let min = UInt8(arrResponce[0], radix: 16)!
            arrResponce.remove(at: 0)// min
            let sec = UInt8(arrResponce[0], radix: 16)!
            arrResponce.remove(at: 0)// min
            let duration = "\(arrResponce[0])\(arrResponce[1])"
            let durationTime =  UInt16(duration, radix: 16)!
            arrResponce.remove(at: 0)// durationTime
            arrResponce.remove(at: 0)// durationTime
            let date = "\(year)/\(month)/\(day) \(hour):\(min):\(sec)"
            return (Decimal(logCount), date, Decimal(durationTime))
        } else {
            return (Decimal(0), Date().getString(format: "yyyy/MM/dd", isUTC: false), Decimal(0))
        }
    }
    func decimalToHax(byte: Int = 1) -> String {
        var haxStr = ""
        switch byte {
        case 1:
            if let val = UInt8(self) {
                let data = val.bigEndian
                haxStr = String(format: "%02X", data)
            }
        case 2:
            if  let val = UInt16(self) {
                let data = val.bigEndian
                haxStr = String(format: "%04X", data)
            }
        default:
            if let val = UInt32(self) {
                let data = val.bigEndian
                haxStr = String(format: "%08X", data)
            }
        }
        return haxStr
    }
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        do {
            let regex = try NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
            regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
                let byteString = (self as NSString).substring(with: match!.range)
                let num = UInt8(byteString, radix: 16)!
                data.append(num)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
}
