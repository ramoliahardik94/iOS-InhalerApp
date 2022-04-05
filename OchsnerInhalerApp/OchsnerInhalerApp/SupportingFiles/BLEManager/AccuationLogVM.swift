//
//  AccuationLogVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 15/03/22.
//

import Foundation
import UIKit

extension BLEHelper {
    
    
    func accuationAPI_LastAccuation() {
        let connectedDevice = connectedPeripheral.filter({$0.discoveredPeripheral!.state == .connected})
        if logCounter == connectedDevice.count {
            logCounter = 0
            apiCallForAccuationlog()
        }
    }
    ///Whenever BLE Device/Peripheral send Accuation log BLEHelper notify hear with thair log details in *notification* object
    @objc func accuationLog(notification: Notification) {
      
        if let object = notification.userInfo as? [String: Any] {
                if object["uselength"]! as? Decimal != 0 {
                    let isoDate = object["date"] as? String
                    let length = object["uselength"]!
                    let mac = object["mac"] as? String
                    let logPeripheralUUID = object["udid"] as? String
                    _ = object["Id"] as? Decimal
                    let bettery = object["bettery"] as? String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = DateFormate.dateFromLog
                    guard let discoverPeripheral = BLEHelper.shared.connectedPeripheral.first(where: { logPeripheralUUID == $0.discoveredPeripheral!.identifier.uuidString}) else {
                        return
                    }
                    Logger.logInfo("Notification for AccuationLog")
                    if  let date = dateFormatter.date(from: isoDate!) {
                        dateFormatter.dateFormat = DateFormate.useDateLocalAPI
                        let finalDate = dateFormatter.string(from: date)
                        let dic: [String: Any] = ["date": finalDate,
                                                  "useLength": length,
                                                  "lat": "\(LocationManager.shared.cordinate.latitude)",
                                                  "long": "\(LocationManager.shared.cordinate.longitude)",
                                                  "isSync": false,
                                                  "mac": mac! as Any,
                                                  "udid": logPeripheralUUID as Any,
                                                  "batterylevel": bettery as Any]
                        if mac != nil {
                            DatabaseManager.share.saveAccuation(object: dic)
                        }
                        if Decimal(discoverPeripheral.logCounter) == discoverPeripheral.noOfLog {
                            discoverPeripheral.noOfLog = 0
                            discoverPeripheral.logCounter = 0
                            logCounter += 1
                            accuationAPI_LastAccuation()

                        }

                    } else {
                        Logger.logError("Invalid Date \(isoDate ?? "date") with Formate \(DateFormate.dateFromLog)")
                    }
                }
        }
    }

    func apiCallForAccuationlog(mac: String = "", isForSingle: Bool = false) {
        if APIManager.isConnectedToNetwork {
            DispatchQueue.global(qos: .background).sync {
                if isForSingle {
                    let unSyncData = DatabaseManager.share.getAccuationLogListUnSync()
                    if unSyncData.count > 0 {
                        let obj = unSyncData[0]
                        guard let param = obj["Param"] as? [[String: Any]] else { return }
                        self.apiCallDeviceUsage(param: param)
                    }
                    
                } else {
                    self.apiCallDeviceUsage(param: prepareAcuationLogParam(mac: mac))
                }
            }
        }
    }
    /// use for get parameter from databse for sync data to *deviceuse* API
    func prepareAcuationLogParam(mac: String) -> [[String: Any]] {
        var parameter = [[String: Any]]()
        var param = [String: Any]()
        let device = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        for obj in device {
            if obj.mac == "" {
                obj.mac = DatabaseManager.share.getMac(UDID: obj.udid!)
            }
            let usage = DatabaseManager.share.getAccuationLogList(mac: obj.mac!)
            if usage.count != 0 {
                param["DeviceId"] = obj.mac!
                param["Usage"] = usage
                parameter.append(param)
            }
        }
        if mac != "" {
            parameter = parameter.filter({ ($0["DeviceId"] as! String) == mac })
        }
        return parameter
    }

    /// Cloud API call of *deviceuse*

    
    func apiCallDeviceUsage(param: [[String: Any]]) {
        print(param)
        let param = param
        if param.count != 0 {
            APIManager.shared.performRequest(route: APIRouter.deviceuse.path, parameters: param, method: .post, isAuth: true, showLoader: false) { [self] _, response in
                if response != nil {
                    if (response as? [String: Any]) != nil {
                        if self.isPullToRefresh {
                            if let topVC =  UIApplication.topViewController() {
                                topVC.view.makeToast( ValidationMsg.successAcuation)
                            }
                            self.isPullToRefresh = false
                        }
                        DatabaseManager.share.updateAccuationLog(param)
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .SYNCSUCCESSACUATION, object: nil)
                        }
                        let unSyncData = DatabaseManager.share.getAccuationLogListUnSync()
                        if unSyncData.count > 0 {
                            apiCallForAccuationlog()
                        }
                    }
                    
                } else {
                    if self.isPullToRefresh {
                        if let topVC =  UIApplication.topViewController() {
                            topVC.view.makeToast( ValidationMsg.failAcuation)
                        }
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .SYNCSUCCESSACUATION, object: nil)
                        }
                        if param.count == 1 {
                            if let arrUsage = param[0]["Usage"] as? [[String: Any]] {
                                if arrUsage.count == 1 {
                                    DatabaseManager.share.updateAccuationLogwithTimeAdd(param)
                                }
                            }
                        }
                        apiCallForAccuationlog(isForSingle: true)
                        self.isPullToRefresh = false
                    }
                }
                
            }
        }
    }
}
