//
//  BLECommunication.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 01/02/22.
//

import Foundation

import CoreBluetooth
import UIKit

extension BLEHelper {
    
    
    /// For scan peripheral
    /// if "isTimer" is true it set Timer of 15 sec after tat it notify .BLENotFound
    /// isTimer default value is false is set Timer of 30 second not notify
    func scanPeripheral(isTimer: Bool = false) {
        if UserDefaultManager.isLogin {
            if isTimer {
                if timer == nil || !timer.isValid {
                    Logger.logInfo("Scaning start with 15 sec timer")
                    timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.didFinishScan), userInfo: nil, repeats: false)
                    DispatchQueue.global(qos: .utility).async { [weak self] in
                        guard let `self` = self else { return }
                        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
                    }
                }
            } else {
                if timer == nil || !timer.isValid {
                    Logger.logInfo("Scaning start with 30 sec timer")
                    timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.didFinishScan), userInfo: nil, repeats: false)
                    DispatchQueue.global(qos: .utility).async { [weak self] in
                        guard let `self` = self else { return }
                        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
                    }
                    
                }
            }
            DispatchQueue.global(qos: .background).sync {
                
                isScanning = true
                NotificationCenter.default.post(name: .BLEChange, object: nil)
            }
        }
    }
    
    func stopTimer() {
        print("timerStop")
      if timer != nil {
        timer!.invalidate()
        timer = nil
      }
    }
    
    /// It use to connect discoveredPeripheral if discoveredPeripheral is null nothing happend
    func connectPeriPheral() {
        if discoveredPeripheral != nil {                    
            centralManager.connect(discoveredPeripheral!, options: nil)
            delay(2) {
                NotificationCenter.default.post(name: .BLEChange, object: nil)
            }
        }
    }
    
    func bleConnect() {
        let devicelist = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        if UserDefaultManager.isLogin  && UserDefaultManager.isGrantBLE && UserDefaultManager.isGrantLaocation && UserDefaultManager.isGrantNotification && devicelist.count > 0 {
            if isAllow {
                BLEHelper.shared.scanPeripheral()
            } else {
              //  BLEHelper.shared.setDelegate()
                if let topVC =  UIApplication.topViewController() {
                    topVC.view.showToast(toastMessage: "Please Turn on Bluetooth", duration: 10)
                }
               
            }
         }
    }
    
    @objc func didFinishScan() {
        isAddAnother ? Logger.logInfo("Scaning stop with 15 sec timer") : Logger.logInfo("Scaning stop with 30 sec timer")
        if isAddAnother {
            NotificationCenter.default.post(name: .BLENotFound, object: nil)
        }
        isScanning = false
        self.stopTimer()
        self.stopScanPeriphral()
    }
    
    func stopScanPeriphral() {
        if timer != nil {
             Logger.logInfo("Scaning stop")
        }
        centralManager.stopScan()
       
        NotificationCenter.default.post(name: .BLEChange, object: nil)
    

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
