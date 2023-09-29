//
//   BLEHelper.swift
//   BLE_Demo_Final
//
//   Created by Nikita Bhatt on 13/01/22.
//

import Foundation
import CoreBluetooth
import UIKit

class PeriperalType: NSObject {
    var discoveredPeripheral: CBPeripheral?
    var bettery: String = "0"
    var addressMAC: String = ""
    var version = String()
    var charectristicWrite: CBCharacteristic?
    var charectristicVersion: CBCharacteristic?
    var charectristicNotify: CBCharacteristic?
    var charectristicRead: CBCharacteristic?
    var macCharecteristic: CBCharacteristic?
    var noOfLog: Decimal = 0
    var logCounter = 0
    var isFromNotification = false
    var isOTAUpgrade = false
    
    override init() {
        super.init()
        bettery = "0"
        addressMAC = ""
    }
    
    init(peripheral: CBPeripheral, mac: String = "", bettery: String = "0") {
        self.discoveredPeripheral = peripheral
        self.addressMAC = mac
        self.bettery = bettery
    }
}

class BLEHelper: NSObject {
    
    // MARK: Variable declaration
    static let shared = BLEHelper()
    var isSet = false
    var centralManager: CBCentralManager = CBCentralManager()
    var connectedPeripheral: [PeriperalType] = [PeriperalType]()
    var isScanning = false
    var newDeviceId: String = ""
    var completionHandler: (Bool) -> Void = {_ in }
    var isAllow = false
    var timer: Timer!
    var isAddAnother = false
    var logCounter = 0
    var isPullToRefresh = false
    var countOfScanDevice = 0
    var countOfConnectedDevice = 0
    
    /// set notification observer for  *.BLEAcuationLog*  when ever Actuation log came from BLE Device/Peripheral this helps to notify in function *actuationLog(notification...*
    func addLogObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.actuationLog(notification:)), name: .BLEAcuationLog, object: nil)
        isSet = true
    }
    
    // TODO: Bug - 5
    func setDelegate() {
        if !isSet {
            addLogObserver()
        }
        Logger.logInfo("isAllow: \(isAllow) State: \(centralManager.state)")
        if centralManager.state == .poweredOn {
            print("Connected.")
            // TODO: Bug-1 Bluetooth permission crash
            centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .utility), options: [CBCentralManagerOptionShowPowerAlertKey: true, CBCentralManagerOptionRestoreIdentifierKey: "BLEcenteralManager", CBCentralManagerRestoredStatePeripheralsKey: "BLEdevice"])
        } else if centralManager.state == .unauthorized {
            if let topVC =  UIApplication.topViewController() {
                topVC.view.makeToast(ValidationMsg.bluetoothOn)
            }
        } else if centralManager.state == .poweredOff {
            if let topVC =  UIApplication.topViewController() {
                topVC.view.makeToast(ValidationMsg.bluetoothOn)
            }
            
        } else if centralManager.state == .unsupported {
            if let topVC =  UIApplication.topViewController() {
                topVC.view.makeToast("unsupported")
            }
            
        } else if centralManager.state == .resetting {
            if let topVC =  UIApplication.topViewController() {
                topVC.view.makeToast("resetting")
            }
        } else if centralManager.state == .unknown {
            print("Unknown")
         } else {
            if let topVC =  UIApplication.topViewController() {
                topVC.view.makeToast("resetting")
            }
        }
    }
    
    func isAllowed(completion: @escaping ((Bool) -> Void)) {
        completion(isAllow)
    }
    
    /// This function is use for set RTC Time to the BLE Device/Peripheral whichi is stored in *connectedPeripheral* and user should pass the UUID in parameter *uuid* for identify
    func setRTCTime(uuid: String) {
//        let year = Calendar.current.component(.year, from: Date()).description
//        let day = Calendar.current.component(.day, from: Date()).description
//        let month = Calendar.current.component(.month, from: Date()).description
//        let hour = Calendar.current.component(.hour, from: Date()).description
//        let min = Calendar.current.component(.minute, from: Date()).description
//        let sec = Calendar.current.component(.second, from: Date()).description
//        let hexRTC = TransferService.addRTSStartByte + year.decimalToHax(byte: 2) + month.decimalToHax() + day.decimalToHax() + hour.decimalToHax() + min.decimalToHax() + sec.decimalToHax()
//        Logger.logInfo("RTC set on Date \(year) : \(month) : \(day) : \(hour) : \(min) : \(sec) RTC Time Set From Device \(hexRTC)")
        
        debugPrint("Main Function RTC")
        let year =  Date().getString( format: "yyyy").decimalToHax(byte: 2)
        let day =  Date().getString(format: "dd").decimalToHax()
        let month =  Date().getString(format: "MM").decimalToHax()
        let hour =  Date().getString(format: "HH").decimalToHax()
        let min =  Date().getString(format: "mm").decimalToHax()
        let sec =  Date().getString(format: "s").decimalToHax()
        let hexRTC = TransferService.addRTSStartByte + year + month + day + hour + min + sec
        let decimal = "\(Date().getString( format: "yyyy")): \(Date().getString(format: "MM")): \( Date().getString(format: "dd")): \(Date().getString(format: "HH")): \(Date().getString(format: "mm")): \( Date().getString(format: "s"))"
        Logger.logInfo("RTC set on Date \(decimal) \n RTC Time Set From Device \(hexRTC)")
        if !connectedPeripheral.isEmpty {
            if let peripheral = connectedPeripheral.first(where: {$0.discoveredPeripheral?.identifier.uuidString == uuid}) {
                if peripheral.charectristicWrite != nil {
                    peripheral.discoveredPeripheral!.writeValue(hexRTC.hexadecimal!, for: peripheral.charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
                }
            }
        }
    }
    /// This function is use to get Battery of given * PeriPhalType* Data type which contains CBPeripheral and it's discover charecteristics and other details
    func getBatteryLevel(peripheral: PeriperalType) {
        if peripheral.discoveredPeripheral != nil && peripheral.charectristicWrite != nil && peripheral.discoveredPeripheral?.state == .connected {
            peripheral.discoveredPeripheral?.writeValue(TransferService.requestGetBattery.hexadecimal!, for: peripheral.charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    /// This function is use for get Actuation numbers fom BLE Device/Peripheral
    @objc func getActuationNumber(_ isPulltoRefresh: Bool = false, peripheral: PeriperalType) {       
        Logger.logInfo(ValidationMsg.startSync)
        self.isPullToRefresh = isPulltoRefresh
        print(connectedPeripheral.count)
        if peripheral.discoveredPeripheral != nil && peripheral.charectristicWrite != nil && peripheral.discoveredPeripheral?.state == .connected {
            Logger.logInfo("Get Actuation number for \(peripheral.addressMAC)")
            peripheral.discoveredPeripheral?.writeValue(TransferService.requestGetNoActuation.hexadecimal!, for: peripheral.charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    /// This function is use for get Actuation Logs from BLE Device
    @objc func getActuationLog() {
        let connectedDevice = connectedPeripheral.filter({$0.discoveredPeripheral!.state == .connected})
        for obj in connectedDevice {
            if obj.discoveredPeripheral != nil && obj.charectristicWrite != nil && obj.discoveredPeripheral?.state == .connected && (obj.noOfLog > 0) {
                obj.discoveredPeripheral?.writeValue(TransferService.requestGetAcuationLog.hexadecimal!, for: obj.charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    /// use this function to get mac Address of BLE Device/Peripheral
    func getmacAddress(peripheral: PeriperalType) {
        if peripheral.discoveredPeripheral != nil && peripheral.macCharecteristic != nil && peripheral.discoveredPeripheral!.state == .connected {
            peripheral.discoveredPeripheral!.readValue(for: peripheral.macCharecteristic!)
        }
    }
    
    func getVersion(peripheral: PeriperalType) {
        if peripheral.discoveredPeripheral != nil && peripheral.charectristicVersion != nil && peripheral.discoveredPeripheral!.state == .connected {
            peripheral.discoveredPeripheral!.readValue(for: peripheral.charectristicVersion!)
        }
    }
    
    func getVersionInString(haxStr: String) -> String {
        let hexArray = haxStr.split(separator: ":")
        var arrVersion = [String]()
        for validHexString in hexArray {
            let validUnicodeScalarValue = Int(validHexString, radix: 16)!
            let validUnicodeScalar = Unicode.Scalar(validUnicodeScalarValue)!
            let character = Character(validUnicodeScalar)
            arrVersion.append(String(character))
        }
        return arrVersion.joined(separator: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
