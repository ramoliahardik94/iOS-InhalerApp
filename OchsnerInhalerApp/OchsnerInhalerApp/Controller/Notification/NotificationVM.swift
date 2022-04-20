//
//  NotificationVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 08/04/22.
//

import Foundation
import CoreData
import UserNotifications

class MsgModel: NSObject {
    var msg: String = ""
    var time: String = ""
}

class NotificationModel: NSObject {
    var historyDate: String = ""
    var history: [History] = [History]()
    var historyOfMiss: [History] = [History]()
    override init() {
        historyDate = ""
    }
    
    init(jSon: [String: Any]) {
        if let value = jSon["historyDate"] as? String {
            historyDate = value
        }
        if let value = jSon["history"] as? [[String: Any]] {
            for obj in value {
                history.append(History(jSon: obj))
            }
        }
    }
   
    func updateStatus() {
        for obj in history {
            debugPrint("Loop For \(obj.mac) \(obj.medName)")
            if obj.acuation.count == 0 {
                for dose in obj.dose {
                    dose.status = "N"
                }
            } else {
                for (index, dose) in obj.dose.enumerated() {
                    Logger.logInfo("time \(dose.time)")
                    let timeInterVal = TimeInterval((30*60)) // #30 miniutes
                    var acuation = [AcuationLog]()
                    let dateHistory =  historyDate.getDate(format: DateFormate.notificationFormate).getString(format: DateFormate.useDateLocalyyyyMMddDash)
                    let timeZone = Date().getString(format: "Z", isUTC: false)
                    if index == 0 {// For firat index
                        let time = dose.time.getDate(format: DateFormate.doseTime).getString(format: "HH:mm:ss")
                        let maxDate = (dateHistory + "T" + time + timeZone).getDate(format: DateFormate.useDateLocalAPI).addingTimeInterval(timeInterVal).getString(format: DateFormate.useDateLocalAPI)
                        Logger.logInfo("minDate: nil")
                        Logger.logInfo("maxDate: \(maxDate)")
                         acuation = obj.acuation.filter({($0.usedatelocal! <= maxDate) })
                        if obj.dose.count == 1 { // For firat index and last index
                            acuation = obj.acuation
                        }
                    } else if index == (obj.dose.count - 1) { // For Last index
                        let time = obj.dose[index - 1].time.getDate(format: DateFormate.doseTime).getString(format: "HH:mm:ss")
                        
                        let minDate = (dateHistory + "T" + time + timeZone).getDate(format: DateFormate.useDateLocalAPI).addingTimeInterval(timeInterVal).getString(format: DateFormate.useDateLocalAPI)
                        Logger.logInfo("minDate: \(minDate)")
                        Logger.logInfo("maxDate: nil")
                         acuation = obj.acuation.filter({($0.usedatelocal! >= minDate)})
                    } else { // For middle index
                        let time1 = dose.time.getDate(format: DateFormate.doseTime).getString(format: "HH:mm:ss")
                        let time2 = obj.dose[index - 1].time.getDate(format: DateFormate.doseTime).getString(format: "HH:mm:ss")
                        let maxDate = (dateHistory + "T" + time1 + timeZone).getDate(format: DateFormate.useDateLocalAPI).addingTimeInterval(timeInterVal).getString(format: DateFormate.useDateLocalAPI)
                        let minDate = (dateHistory + "T" + time2 + timeZone).getDate(format: DateFormate.useDateLocalAPI).addingTimeInterval(timeInterVal).getString(format: DateFormate.useDateLocalAPI)
                        Logger.logInfo("minDate: \(minDate)")
                        Logger.logInfo("maxDate: \(maxDate)")
                         acuation = obj.acuation.filter({($0.usedatelocal! >= minDate) && ($0.usedatelocal! <= maxDate)})
                    }
                    
                    Logger.logInfo("Acuation : \(acuation)")
                          
                    if acuation.count != 0 {
                        dose.status = "Y"
                        dose.takenPuffCount = acuation.count
                    } else {
                        dose.status = "N"
                        dose.takenPuffCount = acuation.count
                    }
                }
            }
            obj.missDose = obj.dose.filter({$0.status == "N"})
        }
    }
}

class History: NSObject {
    var puff = 0
    var medName = ""
    var dose: [DoseStatus] = [DoseStatus]()
    var missDose: [DoseStatus] = [DoseStatus]()
    var mac: String = ""
    var acuation: [AcuationLog] = [AcuationLog]()
    
    override init() {
        puff = 0
        medName = ""
    }
    
    init(jSon: [String: Any]) {
        
        if let value = jSon["puff"] as? Int {
            self.puff = value
        }
        if let value = jSon["medName"] as? String {
            self.medName = value
        }
        if let value = jSon["mac"] as? String {
            self.mac = value
        }
        if let value = jSon["dose"] as? String {
           let arrDose = value.split(separator: ",")
                dose = [DoseStatus]()
                for obj in arrDose {
                    let dic = ["time": String(obj) as Any, "status": "N" as Any]
                    dose.append(DoseStatus(jSon: dic))
                }
            
        }
    }
}

class DoseStatus: NSObject {
    var time = ""
    var status = ""
    var takenPuffCount = 0
    init(jSon: [String: Any]) {
        if let value = jSon["time"] as? String {
            self.time = value
        }
        if let value = jSon["status"] as? String {
            self.status = value
        }
    }
}


class NotificationVM {
    var arrNotification = [NotificationModel]()
    var arrMissNotification = [NotificationModel]()
    var arrNotificationMsg = [MsgModel]()
    func getHistory() {
        arrNotification = [NotificationModel]()
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        date = cal.date(byAdding: .day, value: -1, to: date)!
        let noOfDayToLogin = Date().interval(ofComponent: .day, fromDate: UserDefaultManager.dateLogin)
        let historyOfDays =  noOfDayToLogin >= 7 ? 7 : noOfDayToLogin
        print(noOfDayToLogin)
        print(historyOfDays)
        var days = [String]()
        if historyOfDays >= 1 {
            for _ in 1 ... noOfDayToLogin {
                let noti = NotificationModel()
                days.append(date.getString(format: "yyyy-MM-dd"))
                noti.historyDate = date.getString(format: "MMM dd,yyyy")
                noti.history = DatabaseManager.share.getMentainanceDeviceList(date: date.getString(format: "yyyy-MM-dd"))
                debugPrint("historyDate\(noti.historyDate)")
                noti.updateStatus()
                noti.historyOfMiss = noti.history.filter({$0.missDose.count != 0})
                arrNotification.append(noti)
                date = cal.date(byAdding: .day, value: -1, to: date)!
            }
            arrMissNotification = arrNotification.filter({$0.historyOfMiss.count != 0})
            print(days)
            setArrMsg()
        }
    }
    
    func setArrMsg() {
        arrNotificationMsg = [MsgModel]()
        for date in arrMissNotification {
            for device in date.history {
                for dose in device.missDose {                    
                    let msgModel = MsgModel()
                    msgModel.msg = "\(StringLocalNotifiaction.notificationMsg) (\(device.medName))"
                    msgModel.time = "\(date.historyDate) \(dose.time)"
                    arrNotificationMsg.append(msgModel)
                }
            }
        }
    }
    
    func getStatusOfTodayDose() {
        let cal = Calendar.current
        let date = cal.startOfDay(for: Date())
        let noti = NotificationModel()
        noti.historyDate = date.getString(format: "MMM dd,yyyy")
        noti.history = DatabaseManager.share.getMentainanceDeviceList(date: date.getString(format: "yyyy-MM-dd"))
        debugPrint("historyDate\(noti.historyDate)")
        noti.updateStatus()
        for device in noti.history {
            for dose in device.dose where dose.status != "N" {
                removeNotificationFor(medName: device.medName, mac: device.mac, dose: dose.time)
            }
        }
    }
    func removeNotificationFor(medName: String, mac: String, dose: String) {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { arrNotificationPending in
            print("Pending noti:Count \(arrNotificationPending.count)")
            
            for obj in arrNotificationPending {
                print("Pending noti: \(obj.identifier)")
                print("Pending noti: Contains \(mac).\(dose)")
                if obj.identifier.contains("\(mac).\(dose)") {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [obj.identifier])
                    var graterDate =  dose.getDate(format: DateFormate.doseTime)
                    let strgraterDate = graterDate.getString(format: DateFormate.doseTime12Hr)
                    graterDate =  strgraterDate.getDate(format: DateFormate.doseTime12Hr)
                    //  let showDoesTime  = self.medicationVM.arrTime.last ?? ""
                    var calendar = Calendar(identifier: .gregorian)
                    calendar.timeZone = .current
                    let datesub = calendar.date(byAdding: .minute, value: 30, to: graterDate)
                    let title = String(format: StringLocalNotifiaction.reminderBody, UserDefaultManager.username.trimmingCharacters(in: .whitespacesAndNewlines), medName, dose )
                    
                    NotificationManager.shared.setNotification(date: datesub ?? Date().addingTimeInterval(1800), titile: title, calendar: calendar, macAddress: mac, isFromTomorrow: true, dose: dose)
                }
            }
        })
    }
}
