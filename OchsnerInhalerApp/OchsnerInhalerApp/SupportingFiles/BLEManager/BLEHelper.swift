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
    var noOfLog: Decimal = 0
    var logCounter = 0
    var isPullToRefresh = false
    
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
    func getBetteryLevel(peripheral: PeriperalType) {
            if peripheral.discoveredPeripheral != nil && peripheral.charectristicWrite != nil && peripheral.discoveredPeripheral?.state == .connected {
                peripheral.discoveredPeripheral?.writeValue(TransferService.requestGetBettery.hexadecimal!, for: peripheral.charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
            }
    }
    
    @objc func getAccuationNumber(_ isPulltoRefresh: Bool = false) {
        self.isPullToRefresh = isPulltoRefresh
        
        for obj in connectedPeripheral {
            if obj.discoveredPeripheral != nil && obj.charectristicWrite != nil && obj.discoveredPeripheral?.state == .connected {
                delay(20) {
                    Logger.logInfo("Get Accuation number for \(obj.addressMAC)")
                    obj.discoveredPeripheral?.writeValue(TransferService.requestGetNoAccuation.hexadecimal!, for: obj.charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
                }
            }
               
        }
    }
    
    @objc func getAccuationLog() {
        for obj in connectedPeripheral {
            if obj.discoveredPeripheral != nil && obj.charectristicWrite != nil && obj.discoveredPeripheral?.state == .connected {
                obj.discoveredPeripheral?.writeValue(TransferService.requestGetAcuationLog.hexadecimal!, for: obj.charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func getmacAddress(peripheral: PeriperalType) {
        if peripheral.discoveredPeripheral != nil && peripheral.macCharecteristic != nil && peripheral.discoveredPeripheral!.state == .connected {
            peripheral.discoveredPeripheral!.readValue(for: peripheral.macCharecteristic!)
            }
    }
    
}
