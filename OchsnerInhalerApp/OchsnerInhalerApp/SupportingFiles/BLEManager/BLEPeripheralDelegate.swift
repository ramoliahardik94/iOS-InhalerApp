//
//  BLEPeripheralDelegate.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 02/02/22.
//

import Foundation
import CoreBluetooth
import UIKit
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
            discoverPeripheral.isFromNotification = true
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
                DispatchQueue.main.async {
                    if (UIApplication.topViewController() as? HomeVC) != nil {
                        NotificationCenter.default.post(name: .DataSyncDone, object: nil)
                        self.hideDashboardStatus(msg: BLEStatusMsg.syncFailApi, colorBG: .ColorHomeIconRed)
                    }
                }
                Logger.logInfo("RTC Log Hax: \(stringFromData) of mac: \(discoverPeripheral.addressMAC)")
                if stringFromData == TransferService.responseSuccessRTC {
                    DatabaseManager.share.setRTCFor(udid: peripheral.identifier.uuidString, value: true)
                } else if stringFromData == TransferService.responseFailRTC {
                    Logger.logInfo("For RTC Fail")
                    setRTCTime(uuid: peripheral.identifier.uuidString)
                }
                
            } else if str == StringCharacteristics.getType(.beteryLevel)() {
                if let index = connectedPeripheral.firstIndex(where: {$0.discoveredPeripheral?.identifier.uuidString == peripheral.identifier.uuidString}) {
                    connectedPeripheral[index].bettery = "\(stringFromData.getBeteryLevel())"
                }
                Logger.logInfo("Battery Hax: \(String(describing: stringFromData)) Decimal: \(stringFromData.getBeteryLevel()) mac: \(discoverPeripheral.addressMAC)")
                DispatchQueue.main.async { 
                    NotificationCenter.default.post(name: .BLEBatteryLevel, object: nil, userInfo: ["batteryLevel": "\(stringFromData.getBeteryLevel())"])
                }
                
            } else if str == StringCharacteristics.getType(.actuationLogNumber)() {
                
                discoverPeripheral.noOfLog = stringFromData.getNumberofActuationLog()
                Logger.logInfo("Number Of Acuation log Hax: \(String(describing: stringFromData)) Decimal: \(discoverPeripheral.noOfLog) mac: \(discoverPeripheral.addressMAC)")
                if discoverPeripheral.noOfLog > 0 {
                    showDashboardStatus(msg: BLEStatusMsg.featchDataFromDevice)
                    getActuationLog()
                } else {
                    Logger.logInfo("\(discoverPeripheral.addressMAC) : logCounter >= noOfLog : \(Decimal(discoverPeripheral.logCounter)) >= \(discoverPeripheral.noOfLog)")
                    logCounter += 1
                    actuationAPI_LastActuation()
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
        guard characteristic.uuid == TransferService.characteristicNotifyUUID || characteristic.uuid == TransferService.characteristicAutoNotify else { return }
        let mac = connectedPeripheral.first(where: {$0.discoveredPeripheral?.identifier.uuidString == peripheral.identifier.uuidString})?.addressMAC ?? ""
        if characteristic.isNotifying {
            // Notification has started
           
            Logger.logInfo("Notification began on \(characteristic) For \(mac)")
        } else {
            // Notification has stopped, so disconnect from the peripheral
            Logger.logInfo("Notification stopped on \(characteristic) For \(mac). Disconnecting")
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
            peripheral.discoverCharacteristics(nil, for: service)
        }
        for service in peripheralServices where service.uuid == TransferService.inhealerUTCservice {
            peripheral.discoverCharacteristics([TransferService.characteristicWriteUUID, TransferService.characteristicNotifyUUID, TransferService.characteristicAutoNotify], for: service)
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
        print(serviceCharacteristics)
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.macCharecteristic {
            discoverPeripheral.macCharecteristic = characteristic
        }
        // TODO: - Uncomment for BG AutoNotify
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicAutoNotify {
            peripheral.setNotifyValue(false, for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
            discoverPeripheral.charectristicNotify = characteristic
        }
        
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicWriteUUID {
          
            discoverPeripheral.charectristicWrite = characteristic
        }
        
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicNotifyUUID {
            peripheral.setNotifyValue(false, for: characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
            discoverPeripheral.charectristicRead = characteristic
        }
        
        if discoverPeripheral.charectristicRead != nil && discoverPeripheral.charectristicWrite != nil &&  discoverPeripheral.macCharecteristic != nil && discoverPeripheral.charectristicNotify != nil {
            delay(isAddAnother ? Constants.PairDialogDelay : 0) {
                [weak self] in
                guard let `self` = self else { return }
                
                switch peripheral.state {
                case .connected :
                    self.getmacAddress(peripheral: discoverPeripheral)
                    self.getBatteryLevel(peripheral: discoverPeripheral)
                    if !self.isAddAnother {
                        self.setRTCTime(uuid: discoverPeripheral.discoveredPeripheral!.identifier.uuidString)
                        self.countOfConnectedDevice += 1
                        if self.countOfScanDevice == self.countOfConnectedDevice {
                            self.countOfConnectedDevice = 0
                            self.countOfScanDevice = 0
                            let bleDevice = BLEHelper.shared.connectedPeripheral.filter({$0.discoveredPeripheral?.state == .connected})
                            if bleDevice.count > 0 {
                                Logger.logInfo("Log get After Connect All device")
                                CommonFunctions.getLogFromDeviceAndSync()
                            } else {
                                self.hideDashboardStatus(msg: BLEStatusMsg.noDeviceFound)
                            }
                        }
                    }
                    Logger.logInfo("BLEConnect with identifier \(peripheral.identifier.uuidString )")
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
    case RTCTime, beteryLevel, actuationLogNumber, acuationLog
    func getType() -> String {
        switch self {
        case .RTCTime :
            return  "0155"
        case .beteryLevel:
            return "0255"
        case .actuationLogNumber :
            return  "0355"
        case .acuationLog :
            return  "0455"
        }
    }
    
}
