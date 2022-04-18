//
//  ActuationLogVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 15/03/22.
//

import Foundation
import UIKit

extension BLEHelper {
    
    
    func actuationAPI_LastActuation() {
        let connectedDevice = connectedPeripheral.filter({$0.discoveredPeripheral!.state == .connected})
        Logger.logInfo("logCounter\(logCounter) >= connectedDevice.count\(connectedDevice.count)")
        if logCounter >= connectedDevice.count {
            logCounter = 0
            Logger.logInfo("Last connected device data store to DB")
            delay(5) {
                Logger.logInfo("deviceuse: actuationAPI_LastActuation ")
                self.apiCallForActuationlog()
            }
        } else {
            Logger.logInfo("not last connected device data store to DB")
        }
    }
    
    /// Whenever BLE Device/Peripheral send Actuation log BLEHelper notify hear with thair log details in *notification* object
    @objc func actuationLog(notification: Notification) {
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
                            DatabaseManager.share.saveActuation(object: dic)
                        }
                        if Decimal(discoverPeripheral.logCounter) >= discoverPeripheral.noOfLog {
                            logCounter += 1
                            Logger.logInfo("\(mac!) : logCounter >= noOfLog : \(Decimal(discoverPeripheral.logCounter)) >= \(discoverPeripheral.noOfLog)")
                            discoverPeripheral.noOfLog = 0
                            discoverPeripheral.logCounter = 0
                            if discoverPeripheral.isFromNotification {
                                Logger.logInfo("isFromNotification: \(discoverPeripheral.isFromNotification)")
                                delay(5) {
                                    self.apiCallForActuationlog(mac: discoverPeripheral.addressMAC)
                                    discoverPeripheral.isFromNotification = false
                                }
                               
                            } else {
                                actuationAPI_LastActuation()
                            }
                        }
                } else {
                    Logger.logError("Invalid Date \(isoDate ?? "date") with Formate \(DateFormate.dateFromLog)")
                }
            }
        }
    }
    
    func apiCallForActuationlog(mac: String = "", isForSingle: Bool = false) {
        if APIManager.isConnectedToNetwork {
            Logger.logInfo("apiCallForActuationlog(isForSingle: \(isForSingle) ,mac: \(mac))")
                if isForSingle {
                    let unSyncData = DatabaseManager.share.getActuationLogListUnSync()
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
    
    /// use for get parameter from databse for sync data to *deviceuse* API
    func prepareAcuationLogParam(mac: String) -> [[String: Any]] {
        var parameter = [[String: Any]]()
        var param = [String: Any]()
        let device = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        for obj in device {
            if obj.mac! == "" {
                obj.mac = DatabaseManager.share.getMac(UDID: obj.udid!)
            }
            let usage = DatabaseManager.share.getActuationLogList(mac: obj.mac!)
            if usage.count != 0 {
                param["DeviceId"] = obj.mac!
                param["Usage"] = usage
                parameter.append(param)
            }
        }
        if mac != "" {
            parameter = parameter.filter({ ($0["DeviceId"] as! String) == mac })
        }
        Logger.logInfo("Param For deviceuse \(parameter)")
        return parameter
    }
    
    /// Cloud API call of *deviceuse*
    func apiCallDeviceUsage(param: [[String: Any]]) {
        print(param)
        let param = param
        if param.count != 0 {
            Logger.logInfo(ValidationMsg.startSync)
            showDashboardStatus(msg: BLEStatusMsg.syncStart)
            APIManager.shared.performRequest(route: APIRouter.deviceuse.path, parameters: param, method: .post, isAuth: true, showLoader: false) { [self] _, response in
                
                if response != nil {
                    if (response as? [String: Any]) != nil {
                        self.isPullToRefresh = false
                        DatabaseManager.share.updateActuationLog(param)
                        DispatchQueue.main.async {                            
                            // TODO: For Notificaion status
                            let notiVM = NotificationVM()
                            notiVM.getStatusOfTodayDose()
                            NotificationCenter.default.post(name: .DataSyncDone, object: nil)
                        }
                        
                        Logger.logInfo(ValidationMsg.successAcuation)
                        let unSyncData = DatabaseManager.share.getActuationLogListUnSync()
                        if unSyncData.count > 0 {
                            Logger.logInfo("deviceuse: apiCallDeviceUsage unSyncData.count > 0 ")
                            apiCallForActuationlog()
                        } else {
                            
                            hideDashboardStatus(msg: BLEStatusMsg.syncSuccess)
                        }
                    }
                } else {
                    Logger.logInfo(ValidationMsg.failAcuation)
                    self.isPullToRefresh = false
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .DataSyncDone, object: nil)
                    }
                    if param.count == 1 {
                        if let arrUsage = param[0]["Usage"] as? [[String: Any]] {
                            if arrUsage.count == 1 {
                                DatabaseManager.share.updateActuationLogwithTimeAdd(param)
                            }
                        }
                    }
                    apiCallForActuationlog(isForSingle: true)
                }
            }
        } else {
            Logger.logInfo(ValidationMsg.startSyncCloudNo)
            hideDashboardStatus(msg: BLEStatusMsg.syncFailNoData)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .DataSyncDone, object: nil)
            }
        }
    }
    
    func showDashboardStatus(msg: String) {
        DispatchQueue.main.async {
            if let dashboard = UIApplication.topViewController() as? HomeVC {
                dashboard.lblSyncTitle.text = msg
                dashboard.syncView.backgroundColor = .ButtonColorBlue
                dashboard.activitySync.startAnimating()
                dashboard.heightSync.constant = 35
                dashboard.syncView.isHidden = false
                dashboard.viewDidLayoutSubviews()
            }
        }
    }
    func hideDashboardStatus(msg: String) {
        DispatchQueue.main.async {
            if let dashboard = UIApplication.topViewController() as? HomeVC {
                // CommonFunctions.showGlobalProgressHUD(UIApplication.topViewController()!, text: ValidationMsg.syncLoader)
                dashboard.lblSyncTitle.text = msg
                dashboard.syncView.backgroundColor = .ButtonColorGreen
                dashboard.activitySync.stopAnimating()
                dashboard.syncView.alpha = 1
                delay(2) {
                    UIView.animate(withDuration: 0.5, animations: {
                        dashboard.syncView.alpha = 0
                    }, completion: { _ in
                        dashboard.heightSync.constant = 0
                        dashboard.syncView.isHidden = true
                        dashboard.viewDidLayoutSubviews()
                        dashboard.syncView.alpha = 1
                    })
                }
            }
        }
    }
}
