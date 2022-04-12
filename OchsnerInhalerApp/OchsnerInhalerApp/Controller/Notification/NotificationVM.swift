//
//  NotificationVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 08/04/22.
//

import Foundation
import CoreData

class NotificationModel: NSObject {
    var historyDate: String = ""
    var history: [History] = [History]()
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
            
            if obj.acuation.count == 0 {
                for dose in obj.dose {
                    dose.status = "N"
                }
            } else {
                for (index, dose) in obj.dose.enumerated() {
                    let timeInterVal = TimeInterval((30*60)) // #30 miniutes
                    var acuation = [AcuationLog]()
                    if index == 0 {//For firat index
                        let maxDate = (historyDate + dose.time).getDate(format: DateFormate.notificationDate).addingTimeInterval(timeInterVal)
                         acuation = obj.acuation.filter({($0.usedatelocal?.getDate(format: DateFormate.notificationDate))! <= maxDate})
                    } else if index == (obj.dose.count - 1) { // For Last index
                        let minDate = (historyDate + obj.dose[index - 1].time).getDate(format: DateFormate.notificationDate).addingTimeInterval(timeInterVal)
                         acuation = obj.acuation.filter({($0.usedatelocal?.getDate(format: DateFormate.notificationDate))! >= minDate})
                    } else { // For middle index
                        let maxDate = (historyDate + dose.time).getDate(format: DateFormate.notificationDate).addingTimeInterval(timeInterVal)
                        let minDate = (historyDate + obj.dose[index - 1].time).getDate(format: DateFormate.notificationDate).addingTimeInterval(timeInterVal)
                         acuation = obj.acuation.filter({($0.usedatelocal?.getDate(format: DateFormate.notificationDate))! >= minDate || ($0.usedatelocal?.getDate(format: DateFormate.notificationDate))! <= maxDate})
                    }
                    if acuation.count != 0 {
                        dose.status = "Y"
                        dose.takenPuffCount = acuation.count
                    } else {
                        dose.status = "N"
                        dose.takenPuffCount = acuation.count
                    }
                }
            }
            
        }
    }
}

class History: NSObject {
    var puff = 0
    var medName = ""
    var dose: [DoseStatus] = [DoseStatus]()
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
    func getHistory() {
        arrNotification = [NotificationModel]()
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        date = cal.date(byAdding: .day, value: -1, to: date)!
        var days = [String]()
        for _ in 0 ... 6 {
            let noti = NotificationModel()
            days.append(date.getString(format: "yyyy-MM-dd"))
            noti.historyDate = date.getString(format: "dd-MM-yyyy")
            noti.history = DatabaseManager.share.getMentainanceDeviceList(date: date.getString(format: "yyyy-MM-dd"))
            noti.updateStatus()
            arrNotification.append(noti)
            date = cal.date(byAdding: .day, value: -1, to: date)!
        }
        print(days)
    }
}
