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
        if centralManager.state == .poweredOn {
            if UserDefaultManager.isLogin && ((!isTimer )  || isAddAnother) {
                if timer == nil || !timer.isValid {
                    let time = isTimer ? Constants.TimerScanAddtime : Constants.TimerScanAutoConnect
                    if !isTimer {
                        showDashboardStatus(msg: BLEStatusMsg.scanConnectBLE)
                    }
                    Logger.logInfo("Scaning start with \(time) sec timer")
                    timer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.didFinishScan), userInfo: nil, repeats: false)
                    self.centralManager.scanForPeripherals(withServices: TransferService.serviceArray, options: nil)
                }
                
                isScanning = true
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .BLEChange, object: nil)
                }
            }
        } else {
            isScanning = false
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .BLEChange, object: nil)
            }
            DispatchQueue.main.async {
                if let topVC =  UIApplication.topViewController() {
                    topVC.view.makeToast(ValidationMsg.bluetoothOn)
                }
            }
        }
    }
    
    /// use to stop timer from any weare in BLEHelperr
    func stopTimer() {
        print("timerStop")
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        isScanning = false
    }
    
    /// It use to connect discoveredPeripheral if discoveredPeripheral is null nothing happend
    func connectPeriPheral(peripheral: CBPeripheral) {
        peripheral.delegate = self
        if isAllow {
            if peripheral.state != .connected || peripheral.state != .connecting {
                centralManager.connect(peripheral, options: nil)
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .BLEChange, object: nil)
            }
        } else {
            DispatchQueue.main.async {
                if let topVC =  UIApplication.topViewController() {
                    topVC.view.makeToast(ValidationMsg.bluetoothOn)
                    
                }
            }
        }
    }
    
    /// While Bluettooth status change that time common task are perform heat with *bleConnect* function
    func bleConnect() {
        let devicelist = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        if UserDefaultManager.isLogin  && UserDefaultManager.isGrantBLE && UserDefaultManager.isGrantLaocation && UserDefaultManager.isGrantNotification && devicelist.count > 0 {
            if isAllow {
                if connectedPeripheral.count != 0 {
                    for peripheral in connectedPeripheral {
                        if let discoveredPeripheral = peripheral.discoveredPeripheral {
                            switch discoveredPeripheral.state {
                            case .connected:
                                print(centralManager.state)
                                discoveredPeripheral.discoverServices(nil)
                            case .disconnected:
                                self.connectPeriPheral(peripheral: discoveredPeripheral)
                            default:
                                break
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    if let topVC =  UIApplication.topViewController() {
                        topVC.view.makeToast(ValidationMsg.bluetoothOn)
                    }
                }
            }
        }
    }
    
    /// once timer of sanning is finished this functio is called
    @objc func didFinishScan() {
        isAddAnother ? Logger.logInfo("Scaning stop with \(Constants.TimerScanAddtime) sec timer") : Logger.logInfo("Scaning stop with \(Constants.TimerScanAutoConnect) sec timer")
        if isAddAnother {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .BLENotFound, object: nil)
            }
        }
        if !isAddAnother && countOfScanDevice == 0 {
            hideDashboardStatus(msg: BLEStatusMsg.noDeviceFound)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .DataSyncDone, object: nil)
            }
        }
        isScanning = false
        self.stopTimer()
        self.stopScanPeriphral()
    }
    
    /// using this function user can stop scanning the periipheral
    func stopScanPeriphral() {
        if timer != nil {
            Logger.logInfo("Scaning stop with device number of device \(connectedPeripheral.count)")
        }
        centralManager.stopScan()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .BLEChange, object: nil)
        }
        
    }
    
    /// This function is use for cleanup BLE Task
    func cleanup(peripheral: CBPeripheral) {
        // Don't do anything if we're not connected
        for service in (peripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.uuid == TransferService.characteristicNotifyUUID && characteristic.isNotifying {
                    // It is notifying, so unsubscribe
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
        // If we've gotten this far, we're connected, but we're not subscribed, so we just disconnect
        centralManager.cancelPeripheralConnection(peripheral)
    }
}
