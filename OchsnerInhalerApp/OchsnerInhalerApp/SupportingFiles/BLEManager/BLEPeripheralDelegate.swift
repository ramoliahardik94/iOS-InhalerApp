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
           print("Error discovering characteristics: %s", error.localizedDescription)
            return
        }
        
        guard
            let stringFromData = characteristic.value?.hexEncodedString() else { return }
        print(stringFromData)
        if characteristic.uuid == TransferService.macCharecteristic {
            addressMAC = stringFromData
            NotificationCenter.default.post(name: .BLEGetMac, object: ["MacAdd": stringFromData])
        } else {
            var arrResponce = stringFromData.split(separator: ":")
            arrResponce.remove(at: 0)// StartByte
            let str = "\(arrResponce[0])\(arrResponce[1])"
            if str == StringCharacteristics.getType(.RTCTime)() {
                setRTCTime()
            } else if str == StringCharacteristics.getType(.beteryLevel)() {
                let bettery = stringFromData.getBeteryLevel()
               // print("Bettery : \(bettery)")
                NotificationCenter.default.post(name: .BLEBatteryLevel, object: nil, userInfo: ["batteryLevel": "\(bettery)"])
            } else if str == StringCharacteristics.getType(.accuationLog)() {
                let numberofLog = stringFromData.getNumberofAccuationLog()
              //  print("Number Of Acuation log : \(numberofLog)")
                NotificationCenter.default.post(name: .BLEAcuationCount, object: nil, userInfo: ["acuationCount": "\(numberofLog)"])
            } else if str == StringCharacteristics.getType(.acuationLog)() {
                let log = stringFromData.getAcuationLog()
                NotificationCenter.default.post(name: .BLEAcuationLog, object: nil, userInfo: ["Id": "\(log.id)", "date": "\(log.date)", "uselength": "\(log.uselength)"])
              //  print("Id : \(log.id) \n Date: \(log.date) \n usageLength : \(log.uselength)")
            }
        }
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
        }
        
    }
    
    /*
     *  This is called when peripheral is ready to accept more data when using write without response
     */
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        print("Peripheral is ready, send data")
        
    }
}

// MARK: - BLE Service and Characteristics
extension BLEHelper {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: %s", error.localizedDescription)
     
            return
        }
        
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
            print("Error discovering characteristics: %s", error.localizedDescription)

            return
        }
       
        // Again, we loop through the array, just in case and check if it's the right one
        guard let serviceCharacteristics = service.characteristics else {
            print("service error \(service)")
            return }
        
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.macCharecteristic {
           macCharecteristic = characteristic
        }
        
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicWriteUUID {
          
            charectristicWrite = characteristic
        }
        
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicNotifyUUID {
            discoveredPeripheral!.setNotifyValue(true, for: characteristic)
            charectristicRead = characteristic
        }
        
        stopTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: {
            if self.discoveredPeripheral!.state == .connected  && !self.isConnected {
                self.stopTimer()
                self.isConnected = true
                print(".BLEConnect")
                NotificationCenter.default.post(name: .BLEConnect, object: nil)
            }
        })
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
        return self.map { String(format: format, $0) }.joined()
    }
}


enum StringCharacteristics: String {
    case RTCTime, beteryLevel, accuationLog, acuationLog
    func getType() -> String {
        switch self {
        case .RTCTime :
            return  "0155"
        case .beteryLevel:
            return "0255"
        case .accuationLog :
            return  "0355"
        case .acuationLog :
            return  "0455"
        }
    }
    
}
