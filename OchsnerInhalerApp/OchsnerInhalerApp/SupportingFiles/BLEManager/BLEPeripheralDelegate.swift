//
//  BLEPeripheralDelegate.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 02/02/22.
//

import Foundation
import CoreBluetooth

// MARK: - CBPeripheral Delegate
extension BLEHelper: CBPeripheralDelegate {
    /*
     *   This callback lets us know more data has arrived via notification on the characteristic
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            Logger.logError("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
       
        guard
            let stringFromData = characteristic.value?.hexEncodedString() else { return }
        
        guard let discoverPeripheral = connectedPeripheral.first(where: {peripheral.identifier.uuidString == $0.discoveredPeripheral?.identifier.uuidString}) else { return }
        
        
        if characteristic.uuid == TransferService.characteristicAutoNotify {
            Logger.logInfo("Auto notify Comes: \(String(describing: stringFromData))")
        }
       
        if characteristic.uuid == TransferService.macCharecteristic {
            if let index = connectedPeripheral.firstIndex(where: {$0.discoveredPeripheral?.identifier.uuidString == peripheral.identifier.uuidString}) {
                connectedPeripheral[index].addressMAC = stringFromData
            }
            Logger.logInfo("Mac Address: \(String(describing: stringFromData))")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .BLEGetMac, object: nil, userInfo: ["MacAdd": stringFromData])
            }
            
        } else {
            var arrResponce = stringFromData.split(separator: ":")
            arrResponce.remove(at: 0)// StartByte
            let str = "\(arrResponce[0])\(arrResponce[1])"
            if str == StringCharacteristics.getType(.RTCTime)() {
                Logger.logInfo("RTC Log Hax: \(stringFromData) of mac: \(discoverPeripheral.addressMAC)")
                if stringFromData == TransferService.responseSuccessRTC {
                    DatabaseManager.share.setRTCFor(udid: peripheral.identifier.uuidString, value: true)
                } else if stringFromData == TransferService.responseFailRTC {
                    setRTCTime(uuid: peripheral.identifier.uuidString)
                }
                
            } else if str == StringCharacteristics.getType(.beteryLevel)() {
                if let index = connectedPeripheral.firstIndex(where: {$0.discoveredPeripheral?.identifier.uuidString == peripheral.identifier.uuidString}) {
                    connectedPeripheral[index].bettery = "\(stringFromData.getBeteryLevel())"
                }
                Logger.logInfo("Bettery Hax: \(String(describing: stringFromData)) Decimal: \(stringFromData.getBeteryLevel()) mac: \(discoverPeripheral.addressMAC)")
                DispatchQueue.main.async { 
                    NotificationCenter.default.post(name: .BLEBatteryLevel, object: nil, userInfo: ["batteryLevel": "\(stringFromData.getBeteryLevel())"])
                }
                
            } else if str == StringCharacteristics.getType(.accuationLogNumber)() {
                
                discoverPeripheral.noOfLog = stringFromData.getNumberofAccuationLog()
                Logger.logInfo("Number Of Acuation log Hax: \(String(describing: stringFromData)) Decimal: \(discoverPeripheral.noOfLog) mac: \(discoverPeripheral.addressMAC)")
                if discoverPeripheral.noOfLog > 0 {
                    getAccuationLog()
                } else {
                    logCounter += 1
                    accuationAPI_LastAccuation()
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .BLEAcuationCount, object: nil, userInfo: ["acuationCount": "\(discoverPeripheral.noOfLog)"])
                }
                
            } else if str == StringCharacteristics.getType(.acuationLog)() {
                discoverPeripheral.logCounter += 1
                let log = stringFromData.getAcuationLog(counter: discoverPeripheral.logCounter, uuid: peripheral.identifier.uuidString)
                Logger.logInfo("Acuation log Hax: \(String(describing: stringFromData)) Decimal: \(log) mac: \(discoverPeripheral.addressMAC)")
                let mac = DatabaseManager.share.getMac(UDID: peripheral.identifier.uuidString)
                guard let bettery = connectedPeripheral.first(where: {$0.discoveredPeripheral!.identifier.uuidString == peripheral.identifier.uuidString}) else { return }
                NotificationCenter.default.post(name: .BLEAcuationLog, object: nil, userInfo:
                                                    ["Id": (log.id),
                                                     "date": "\(log.date)",
                                                     "uselength": log.uselength,
                                                     "mac": mac,
                                                     "udid": peripheral.identifier.uuidString,
                                                     "bettery": bettery.bettery])
                
                
            }
        }
    }
    
    /*
     *  The peripheral letting us know whether our subscribe/unsubscribe happened or not
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            Logger.logError("Error changing notification state: \(error.localizedDescription)")
            return
        }
        
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid == TransferService.characteristicNotifyUUID else { return }
        
        if characteristic.isNotifying {
            // Notification has started
            Logger.logInfo("Notification began on \(characteristic)")
        } else {
            // Notification has stopped, so disconnect from the peripheral
            Logger.logInfo("Notification stopped on \(characteristic). Disconnecting")
        }
        
    }
  
}

// MARK: - BLE Service and Characteristics
extension BLEHelper {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            Logger.logError("Error discovering services: \(error.localizedDescription)")
     
            return
        }
        print("Discover Servivce: \(String(describing: peripheral.services))")
        guard let peripheralServices = peripheral.services else { return }
        
        for service in peripheralServices where service.uuid == TransferService.otaServiceUUID {
            peripheral.discoverCharacteristics([TransferService.macCharecteristic], for: service)
        }
        for service in peripheralServices where service.uuid == TransferService.inhealerUTCservice {
            peripheral.discoverCharacteristics([TransferService.characteristicWriteUUID, TransferService.characteristicNotifyUUID], for: service)
        }

    }    
    /*
     *  The Transfer characteristic was discovered.
     *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Deal with errors (if any).
        if let error = error {
            Logger.logError("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        guard let discoverPeripheral = connectedPeripheral.first(where: {peripheral.identifier.uuidString == $0.discoveredPeripheral?.identifier.uuidString}) else { return }
        // Again, we loop through the array, just in case and check if it's the right one
        guard let serviceCharacteristics = service.characteristics else {
            Logger.logError("service error \(service)")
            return }
        
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.macCharecteristic {
            discoverPeripheral.macCharecteristic = characteristic
        }
        
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicAutoNotify {
            peripheral.setNotifyValue(true, for: characteristic)
        }
        
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicWriteUUID {
          
            discoverPeripheral.charectristicWrite = characteristic
        }
        
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicNotifyUUID {
            peripheral.setNotifyValue(true, for: characteristic)
            discoverPeripheral.charectristicRead = characteristic
        }
        
//        stopTimer()
        if discoverPeripheral.macCharecteristic != nil && discoverPeripheral.charectristicWrite != nil {
            delay(isAddAnother ? 15 : 0) {
                [weak self] in
                guard let `self` = self else { return }
                
                switch peripheral.state {
                case .connected :
//                    if !DatabaseManager.share.getIsSetRTC(udid: peripheral.identifier.uuidString) {
//                        self.setRTCTime(uuid: peripheral.identifier.uuidString)
//                    }
                    self.getmacAddress(peripheral: discoverPeripheral)
                    self.getBetteryLevel(peripheral: discoverPeripheral)
                    if !self.isAddAnother {
                        self.getAccuationNumber(peripheral: discoverPeripheral)
                    }
                    Logger.logInfo("BLEConnect with identifier \(peripheral.identifier.uuidString )")
                    //self.isScanning = false
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .BLEConnect, object: nil)

                    }
                default:
                    break
                }
            }
        }
        // Once this is complete, we just need to wait for the data to come in.
    }
    
}
extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX:" : "%02hhx:"
        let string = self.map { String(format: format, $0) }.joined()
        return String(string.dropLast())     
    }
}


enum StringCharacteristics: String {
    case RTCTime, beteryLevel, accuationLogNumber, acuationLog
    func getType() -> String {
        switch self {
        case .RTCTime :
            return  "0155"
        case .beteryLevel:
            return "0255"
        case .accuationLogNumber :
            return  "0355"
        case .acuationLog :
            return  "0455"
        }
    }
    
}
