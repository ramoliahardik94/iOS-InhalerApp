//
//  BLECommunication.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 01/02/22.
//

import Foundation

import CoreBluetooth

extension BLEHelper {
    
    func scanPeripheral() {
        _ = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.didFinishScan), userInfo: nil, repeats: false)
        // TODO:  Replace hear Service array make a param if needed then
        centralManager.scanForPeripherals(withServices: [TransferService.otaServiceUUID, TransferService.inhealerUTCservice], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    func connectPeriPheral() {
        if discoveredPeripheral != nil {
            if discoveredPeripheral!.state == .disconnected {
                // MARK: Step:6 Connect to peripheral
                centralManager.connect(discoveredPeripheral!, options: nil)
            }
        }
    }
    
    @objc func didFinishScan() {
        NotificationCenter.default.post(name: .BLENotFound, object: nil)
      self.stopScanPeriphral()
    }
    
    func stopScanPeriphral() {
        centralManager.stopScan()
    }
    
    // This function is use for cleanup BLE Task
    func cleanup() {
        // Don't do anything if we're not connected
        guard let discoveredPeripheral = discoveredPeripheral,
            case .connected = discoveredPeripheral.state else { return }
        
        for service in (discoveredPeripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.uuid == TransferService.characteristicNotifyUUID && characteristic.isNotifying {
                    // It is notifying, so unsubscribe
                    self.discoveredPeripheral?.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        // If we've gotten this far, we're connected, but we're not subscribed, so we just disconnect
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
    }
}
