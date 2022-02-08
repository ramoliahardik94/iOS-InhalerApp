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
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected")
        if peripheral.state == .connected {
            print("Scanning stopped")
            stopScanPeriphral()
            peripheral.delegate = self
            peripheral.discoverServices([TransferService.otaServiceUUID, TransferService.inhealerUTCservice])
        }
    }
        
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("DidFail")
        NotificationCenter.default.post(name: .BLENotConnect, object: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("state \(peripheral.state.rawValue)")
        NotificationCenter.default.post(name: .BLEDisconnect, object: nil)
        print("DidDissconnect")
    }
    
    
    /*
     *   This callback lets us know more data has arrived via notification on the characteristic
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error discovering characteristics: %s", error.localizedDescription)
            return
        }
        
        guard let characteristicData = characteristic.value,
              let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
        print(characteristic)
        var arrResponce = stringFromData.split(separator: " ")
        arrResponce.remove(at: 0)// StartByte
        let str = "\(arrResponce[0])\(arrResponce[1])"
        if str == "0155"{
            setRTCTime()
        } else if str == "0255" {
        let bettery = stringFromData.getBeteryLevel()
            print("Bettery : \(bettery)")
        } else if str == "0355" {
            let numberofLog = stringFromData.getNumberofAccuationLog()
            print("Number Of Acuation log : \(numberofLog)")
        } else if str == "0455" {
            let log = stringFromData.getAcuationLog()
            print("Id : \(log.id) \n Date: \(log.date) \n usageLength : \(log.uselength)")
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
        for service in peripheralServices {
            peripheral.discoverCharacteristics([TransferService.macCharecteristic, TransferService.characteristicWriteUUID, TransferService.characteristicNotifyUUID], for: service)
            
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
            // If it is, subscribe to it
            guard let characteristicData = characteristic.value,
                  let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
            print("MAC: \(stringFromData)")
            macCharecteristic = characteristic
            addressMAC = stringFromData
        }
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicWriteUUID {
           
            charectristicWrite = characteristic
        }
        
        for characteristic in serviceCharacteristics where characteristic.uuid == TransferService.characteristicNotifyUUID {
       
            charectristicRead = characteristic
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
            if self.discoveredPeripheral!.state == .connected {
                NotificationCenter.default.post(name: .BLEConnect, object: nil)
            }
        })
        // Once this is complete, we just need to wait for the data to come in.
    }
    
}
