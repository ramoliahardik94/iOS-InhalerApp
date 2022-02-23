//
//   BLEHelper.swift
//   BLE_Demo_Final
//
//   Created by Nikita Bhatt on 13/01/22.
//

import Foundation
import CoreBluetooth

class BLEHelper: NSObject {
    
    // MARK: Variable declaration
    static let shared = BLEHelper()
    var isConnected = false 
    var centralManager: CBCentralManager = CBCentralManager()
    var discoveredPeripheral: CBPeripheral?
    var charectristicWrite: CBCharacteristic?
    var charectristicRead: CBCharacteristic?
    var macCharecteristic: CBCharacteristic?
    var addressMAC: String = "70:05:00:00:00:3e"
    var bettery: String = "100"
    var completionHandler: (Bool) -> Void = {_ in }
    var isAllow = false
    var timer: Timer!
    var timerAccuation: Timer!
    
    func setDelegate() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        NotificationCenter.default.addObserver(self, selector: #selector(self.accuationLog(notification:)), name: .BLEAcuationLog, object: nil)
    }
    
    
    // MARK: Function declarations
    // / This function is used for starScan of peripheral base on service(CBUUID) UUID
    // /
    
    func isAllowed(completion: @escaping ((Bool) -> Void)) {
        completion(isAllow)
    }
    func setRTCTime() {
        let year =  Date().getString( format: "yyyy").decimalToHax(byte: 2)
        let day =  Date().getString(format: "dd").decimalToHax()
        let month =  Date().getString(format: "MM").decimalToHax()
        let hour =  Date().getString(format: "HH").decimalToHax()
        let min =  Date().getString(format: "mm").decimalToHax()
        let sec =  Date().getString(format: "s").decimalToHax()
        let haxRTC = TransferService.addRTSStartByte + year+day+month+hour+min+sec
        if discoveredPeripheral != nil && charectristicWrite != nil {
            discoveredPeripheral!.writeValue(haxRTC.hexadecimal!, for: charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    func getBetteryLevel() {
        if discoveredPeripheral != nil && charectristicWrite != nil {
            print(TransferService.requestGetBettery.hexadecimal!)
            discoveredPeripheral?.writeValue(TransferService.requestGetBettery.hexadecimal!, for: charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func getAccuationNumber() {
        if discoveredPeripheral != nil && charectristicWrite != nil {
            discoveredPeripheral?.writeValue(TransferService.requestGetNoAccuation.hexadecimal!, for: charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    @objc func getAccuationLog() {
        if discoveredPeripheral != nil && charectristicWrite != nil && discoveredPeripheral?.state == .connected {
            discoveredPeripheral?.writeValue(TransferService.requestGetAcuationLog.hexadecimal!, for: charectristicWrite!, type: CBCharacteristicWriteType.withResponse)
        } else if self.discoveredPeripheral?.state == .disconnected {
            NotificationCenter.default.post(name: .BLEDisconnect, object: nil)
        }
    }
    func getmacAddress() {
        if discoveredPeripheral != nil && macCharecteristic != nil {
            discoveredPeripheral?.readValue(for: macCharecteristic!)
        }
    }
    
    @objc func accuationLog(notification: Notification) {
        //  DatabaseManager.share.deleteAllAccuationLog()
        print(notification.userInfo!)
        LocationManager.shared.checkLocationPermissionAndFetchLocation(completion: { coordination in
            if notification.userInfo!["uselength"]! as? Decimal != 0 {
                let isoDate = notification.userInfo?["date"] as? String
                let length = notification.userInfo!["uselength"]!
                let mac = notification.userInfo?["mac"] as? String
                let udid = notification.userInfo?["udid"] as? String
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/dd/MM HH:mm:ss"
                if  let date = dateFormatter.date(from: isoDate!) {
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let finalDate = dateFormatter.string(from: date)
                    let dic: [String: Any] = ["date": finalDate,
                                              "useLength": length,
                                              "lat": "\(coordination.latitude)",
                                              "long": "\(coordination.longitude)",
                                              "isSync": false, "mac": mac! as Any,
                                              "udid": udid as Any,
                                              "batterylevel": BLEHelper.shared.bettery]
                    DatabaseManager.share.saveAccuation(object: dic)
                    self.apiCallForAccuationlog()
                }
            }
        })
    }
    
    func apiCallForAccuationlog() {
        if APIManager.isConnectedToNetwork {
            DispatchQueue.global(qos: .background).sync {
                self.apiCallDeviceUsage()
            }
        }
    }
    
    func prepareAcuationLogParam() -> [[String: Any]] {
        var parameter = [[String: Any]]()
        var param = [String: Any]()
        let device = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        for obj in device {
            let usage = DatabaseManager.share.getAccuationLogList(mac: obj.mac!)
            if usage.count != 0 {
                param["DeviceId"] = obj.mac!
                param["Usage"] = usage
                parameter.append(param)
            }
        }
        print(parameter)
        return parameter
    }
    
    func apiCallDeviceUsage() {
        let param = prepareAcuationLogParam()
        if param.count != 0 {
            APIManager.shared.performRequest(route: APIRouter.deviceuse.path, parameters: param, method: .post, isAuth: true, showLoader: true) { error, response in
                if response == nil {
                    print(error!.message)
                } else {
                    if (response as? [String: Any]) != nil {
                        DatabaseManager.share.updateAccuationLog(param)
                        NotificationCenter.default.post(name: .SYNCSUCCESSACUATION, object: nil)
                        print("Success")
                    } else {
                        print(ValidationMsg.CommonError)
                    }
                }
            }
        }
    }
}


extension String {
    
    func getNumberofAccuationLog( ) -> Decimal {
        let arrResponce = self.split(separator: ":")
        _ =  UInt8(arrResponce[3], radix: 16) // payloadLenth
        let strCount = "\(arrResponce[4])\(arrResponce[5])"
        let logCount =  UInt16(strCount, radix: 16)!
        return Decimal(logCount.bigEndian)
    }
    
    func getBeteryLevel() -> Decimal {
        let arrResponce = self.split(separator: ":")
        _ =  UInt8(arrResponce[3], radix: 16) // payloadLenth
        let betteryLevel =  UInt8(arrResponce[4], radix: 16)!
        return Decimal(betteryLevel)
    }
    
    func getAcuationLog() ->  (id: Decimal, date: String, uselength: Decimal) {
        
        let arrResponce = self.split(separator: ":")
        let payloadLenth =  UInt8(arrResponce[3], radix: 16)! // payloadLenth
        if payloadLenth != 0 {
            let idStr = "\(arrResponce[4])\(arrResponce[5])"
            let logCount =  UInt16(idStr, radix: 16)!.bigEndian
            let yearStr = "\(arrResponce[6])\(arrResponce[7])"
            let year =  UInt16(yearStr, radix: 16)!.bigEndian
            let month = UInt8(arrResponce[8], radix: 16)!
            let day = UInt8(arrResponce[9], radix: 16)!
            let hour = UInt8(arrResponce[10], radix: 16)!
            let min = UInt8(arrResponce[11], radix: 16)!
            let sec = UInt8(arrResponce[12], radix: 16)!
            let duration = "\(arrResponce[13])\(arrResponce[14])"
            let durationTime =  UInt16(duration, radix: 16)!
            let date = String(format: "%04d/%02d/%02d %02d:%02d:%02d", year, month, day, hour, min, sec)
            return (Decimal(logCount), date, Decimal(durationTime.bigEndian))
        } else {
            return (Decimal(0), Date().getString(format: "yyyy/MM/dd HH:mm:ss", isUTC: false), Decimal(0))
        }
    }
    
    func decimalToHax(byte: Int = 1) -> String {
        var haxStr = ""
        switch byte {
        case 1:
            if let val = UInt8(self) {
                let data = val.bigEndian
                haxStr = String(format: "%02X", data)
            }
        case 2:
            if  let val = UInt16(self) {
                let data = val.bigEndian
                haxStr = String(format: "%04X", data)
            }
        default:
            if let val = UInt32(self) {
                let data = val.bigEndian
                haxStr = String(format: "%08X", data)
            }
        }
        return haxStr
    }
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        do {
            let regex = try NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
            regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
                let byteString = (self as NSString).substring(with: match!.range)
                let num = UInt8(byteString, radix: 16)!
                data.append(num)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
}
