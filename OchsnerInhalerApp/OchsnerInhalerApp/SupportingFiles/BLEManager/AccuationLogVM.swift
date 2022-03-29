//
//  AccuationLogVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 15/03/22.
//

import Foundation
import UIKit

extension BLEHelper {
    
    @objc func accuationLog(notification: Notification) {
      
        if let object = notification.userInfo as? [String: Any] {
                if object["uselength"]! as? Decimal != 0 {
                    let isoDate = object["date"] as? String
                    let length = object["uselength"]!
                    let mac = object["mac"] as? String
                    let udid = object["udid"] as? String
                    _ = object["Id"] as? Decimal
                    let bettery = object["bettery"] as? String
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = DateFormate.dateFromLog
                    if  let date = dateFormatter.date(from: isoDate!) {
                        dateFormatter.dateFormat = DateFormate.useDateLocalAPI
                        let finalDate = dateFormatter.string(from: date)
                        let dic: [String: Any] = ["date": finalDate,
                                                  "useLength": length,
                                                  "lat": "\(LocationManager.shared.cordinate.latitude)",
                                                  "long": "\(LocationManager.shared.cordinate.longitude)",
                                                  "isSync": false, "mac": mac! as Any,
                                                  "udid": udid as Any,
                                                  "batterylevel": bettery as Any]
                        DatabaseManager.share.saveAccuation(object: dic)
                        if Decimal(logCounter) == self.noOfLog {
                            self.noOfLog = 0
                            self.logCounter = 0
                            self.apiCallForAccuationlog()
                        }
                    } else {
                        Logger.logError("Invalid Date \(isoDate ?? "date") with Formate \(DateFormate.dateFromLog)")
                    }
                }
           // })
            
           
        }
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
        return parameter
    }
    
    func apiCallDeviceUsage() {
        let param = prepareAcuationLogParam()
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
                    }
                    
                } else {
                    if self.isPullToRefresh {
                        if let topVC =  UIApplication.topViewController() {
                            topVC.view.makeToast( ValidationMsg.failAcuation)
                        }
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .SYNCSUCCESSACUATION, object: nil)
                        }
                        self.isPullToRefresh = false
                    }
                }
                
            }
        }
    }
}
