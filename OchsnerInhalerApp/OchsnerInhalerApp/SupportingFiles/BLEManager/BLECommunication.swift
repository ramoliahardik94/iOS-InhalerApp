//
//  BLECommunication.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 01/02/22.
//

import Foundation

import CoreBluetooth

extension BLEHelper {
    
    
    /// For scan peripheral
    /// if "isTimer" is true it set Timer of 15 sec after tat it notify .BLENotFound
    /// isTimer default value is false
    func scanPeripheral(isTimer: Bool = false) {
        stopScanPeriphral()
        stopTimer()
        
        if isTimer {
            Logger.logInfo("Scaning start with 15 sec timer")
            timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.didFinishScan), userInfo: nil, repeats: false)
        } else {
        // TODO:  Replace hear Service array make a param if needed then
            Logger.logInfo("Scaning start with 30 sec timer")
            timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.didFinishScan), userInfo: nil, repeats: false)
        }
        DispatchQueue.global(qos: .background).sync {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func stopTimer() {
      if timer != nil {
        timer!.invalidate()
        timer = nil
      }
    }
    
    /// It use to connect discoveredPeripheral if discoveredPeripheral is null nothing happend
    func connectPeriPheral() {
        if discoveredPeripheral != nil {
            centralManager.connect(discoveredPeripheral!, options: nil)
        }
    }
    
    func bleConnect() {
        let devicelist = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        if UserDefaultManager.isLogin  && UserDefaultManager.isGrantBLE && UserDefaultManager.isGrantLaocation && UserDefaultManager.isGrantNotification && devicelist.count > 0 {
            if isAllow {
                BLEHelper.shared.scanPeripheral()
            } else {
                BLEHelper.shared.setDelegate()
            }
         }
    }
    
    @objc func didFinishScan() {
        isAddAnother ? Logger.logInfo("Scaning stop with 15 sec timer") : Logger.logInfo("Scaning stop with 30 sec timer")
        if isAddAnother {
            NotificationCenter.default.post(name: .BLENotFound, object: nil)
        }
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
