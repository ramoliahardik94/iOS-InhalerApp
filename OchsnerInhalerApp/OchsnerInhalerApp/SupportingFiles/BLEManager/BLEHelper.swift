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
    
    var charectristicWrite: CBCharacteristic?
    var charectristicRead: CBCharacteristic?
    var macCharecteristic: CBCharacteristic?
    var noOfLog: Decimal = 0
    var logCounter = 0
    
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
    var uuid: String = ""
    var completionHandler: (Bool) -> Void = {_ in }
    var isAllow = false
    var timer: Timer!
    var isAddAnother = false
    var logCounter = 0
    var isPullToRefresh = false
    
    
    /// set notification observer for  *.BLEAcuationLog*  when ever Accuation log came from BLE Device/Peripheral this helps to notify in function *accuationLog(notification...*
    func addLogObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.accuationLog(notification:)), name: .BLEAcuationLog, object: nil)
        isSet = true
    }
    
    func setDelegate() {
        if !isSet {
            addLogObserver()
        }
//        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true, CBCentralManagerOptionRestoreIdentifierKey: "BLEcenteralManager", CBCentralManagerRestoredStatePeripheralsKey: "BLEdevice"])
    }
    
    func isAllowed(completion: @escaping ((Bool) -> Void)) {
        completion(isAllow)
    }
    
    /// This function is use for set RTC Time to the BLE Device/Peripheral whichi is stored in *connectedPeripheral* and user should pass the UUID in parameter *uuid* for identify
    func setRTCTime(uuid: String) {
        let year =  Date().getString( format: "yyyy").decimalToHax(byte: 2)
        
        let day =  Date().getString(format: "dd").decimalToHax()
        let month =  Date().getString(format: "MM").decimalToHax()
        let hour =  Date().getString(format: "HH").decimalToHax()
        let min =  Date().getString(format: "mm").decimalToHax()
        let sec =  Date().getString(format: "s").decimalToHax()
        let haxRTC = TransferService.addRTSStartByte + year+month+day+hour+min+sec
        let decimal = "\(Date().getString( format: "yyyy")): \(Date().getString(format: "MM")): \( Date().getString(format: "dd")): \(Date().getString(format: "HH")): \(Date().getString(format: "mm")): \( Date().getString(format: "s"))"
        Logger.logInfo("RTC set on Date \(decimal) \n RTC Time Set From Device \(haxRTC)")
        if !connectedPeripheral.isEmpty {
            if let peripheral = connectedPeripheral.first(where: {$0.discoveredPeripheral?.identifier.uuidString == uuid}) {
                if peripheral.charectristicWrite != nil {
                    peripheral.discoveredPeripheral!.writeValue(haxRTC.hexadecimal!, for: peripheral.charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
                }
            }
        }
    }
    /// This function is use to get Bettery of given * PeriPhalType* Data type which contains CBPeripheral and it's discover charecteristics and other details
    func getBetteryLevel(peripheral: PeriperalType) {
        if peripheral.discoveredPeripheral != nil && peripheral.charectristicWrite != nil && peripheral.discoveredPeripheral?.state == .connected {
            peripheral.discoveredPeripheral?.writeValue(TransferService.requestGetBettery.hexadecimal!, for: peripheral.charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    /// This function is use for get Accuation numbers fom BLE Device/Peripheral
    @objc func getAccuationNumber(_ isPulltoRefresh: Bool = false, peripheral: PeriperalType) {       
        Logger.logInfo(ValidationMsg.startSync)
        self.isPullToRefresh = isPulltoRefresh
        print(connectedPeripheral.count)
        if peripheral.discoveredPeripheral != nil && peripheral.charectristicWrite != nil && peripheral.discoveredPeripheral?.state == .connected {
            Logger.logInfo("Get Accuation number for \(peripheral.addressMAC)")
            peripheral.discoveredPeripheral?.writeValue(TransferService.requestGetNoAccuation.hexadecimal!, for: peripheral.charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
            
        }
    }
    /// This function is use for get Accuation Logs from BLE Device
    @objc func getAccuationLog() {
        let connectedDevice = connectedPeripheral.filter({$0.discoveredPeripheral!.state == .connected})
        for obj in connectedDevice {
            if obj.discoveredPeripheral != nil && obj.charectristicWrite != nil && obj.discoveredPeripheral?.state == .connected {
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
    
}
