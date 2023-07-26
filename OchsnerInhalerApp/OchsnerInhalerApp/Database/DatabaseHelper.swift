//
//  DatabaseHelper.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 10/02/22.
//

import Foundation
import CoreData
import UIKit
import KeychainSwift

struct EntityName {
    static let acuationLog = "AcuationLog"
    static let device = "Device"
}

class DatabaseManager {
    static var share = DatabaseManager()
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func saveActuation(object: [String: Any]) {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.acuationLog)
        let predicate1 =  NSPredicate(format: "usedatelocal == %@", ("\(object["date"]!)"))
        let predicate2 =  NSPredicate(format: "deviceidmac == %@", ("\(object["mac"]!)"))
        //        let predicate2 =  NSPredicate(format: "issync == %d", false)
        let predicate =  NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
        fetchRequest.predicate = predicate
        do {
            var actuationLog: AcuationLog!
            let arrActuationLog = try context?.fetch(fetchRequest) as! [AcuationLog]
            if arrActuationLog.count != 0 {
                actuationLog = arrActuationLog[0]
                actuationLog.issync = actuationLog.issync
            } else {
                actuationLog = (NSEntityDescription.insertNewObject(forEntityName: EntityName.acuationLog, into: context!) as! AcuationLog)
                actuationLog.issync = (object["isSync"] as! Bool)
            }
            actuationLog.uselength = Double("\(object["useLength"]!)") ?? 0.0
            
            if let date = object["date"] as? String {
                let maxDate = Date().getString(format: DateFormate.useDateLocalAPI, isUTC: false)
                let minDate = getMinDate()
                // TODO: - Remove max date condition to fix the issue if the device is unused for 30+ days
                actuationLog.isbadlog = (date > maxDate || date < minDate)
                actuationLog.usedatelocal = date
            }
            
            actuationLog.longitude = (object["long"] as! String)
            actuationLog.latitude = (object["lat"] as! String)
            let macId = (object["mac"] as! String).trimmingCharacters(in: .whitespacesAndNewlines) == "" ? self.getMac(UDID: (object["udid"] as! String)) : (object["mac"] as! String)
            actuationLog.deviceidmac = macId
            actuationLog.deviceuuid = (object["udid"] as! String)
            actuationLog.batterylevel = Double(object["batterylevel"] as! String)! == 0 ? 10.0 : Double(object["batterylevel"] as! String)!
            actuationLog.uselength = Double("\(object["useLength"]!)")!
            actuationLog.devicesyncdateutc = Date().getString(format: DateFormate.deviceSyncDateUTCAPI, isUTC: true)
            try context?.save()
            Logger.logInfo("Log Save \(actuationLog.DBDictionary())")
        } catch {
            debugPrint("Can not get Data")
        }
    }
    
    func isMantenanceAllow(medName: String) -> Bool {
        var arrDevice = [Device]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.device)
        let predicate =  NSPredicate(format: "medtypeid == 2")
        fetchRequest.predicate = predicate
        do {
            arrDevice = try context?.fetch(fetchRequest) as! [Device]
        } catch {
            debugPrint("can not get data")
        }
        
        arrDevice = arrDevice.filter({$0.medname?.lowercased() == medName.lowercased()})
        if arrDevice.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    func isReminder() -> Bool {
        var arrDevice = [Device]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.device)
        let predicate =  NSPredicate(format: "medtypeid == 2")
        fetchRequest.predicate = predicate
        do {
            arrDevice = try context?.fetch(fetchRequest) as! [Device]
        } catch {
            debugPrint("can not get data")
        }
        if arrDevice.count == 0 {
            return false
        } else {
            return arrDevice[0].reminder
        }
    }
    
    func updateFWVersion(_ version: String, _ udid: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.device)
        let predicate =  NSPredicate(format: "udid == %@", udid)
        fetchRequest.predicate = predicate
        do {
            let arrDevice = try context?.fetch(fetchRequest) as! [Device]
            if arrDevice.count > 0 {
                for obj in arrDevice {
                    obj.version = version
                }
            }
            try context?.save()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .BLEChange, object: nil)
            }
        } catch {
            debugPrint("can not get device")
        }
    }
    
    func saveDevice(object: DeviceModel, isFromDirection: Bool = false) {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.device)
        
        if object.udid != "" {
            setupUDID(mac: object.internalID, udid: object.udid)
        } else {
            object.udid = getUDID(mac: object.internalID)
        }
        
        let predicate1 =  NSPredicate(format: "mac == %@", object.internalID)
        let predicate2 =  NSPredicate(format: "email == %@", UserDefaultManager.email)
        let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
        fetchRequest.predicate = predicate
        do {
            var device: Device!
            if object.internalID != "" {
                let arrDevice = try context?.fetch(fetchRequest) as! [Device]
                if arrDevice.count != 0 {
                    device = arrDevice[0]
                    if device.udid == "" && object.udid != "" {
                        device.udid = object.udid
                    }
                } else {
                    device = (NSEntityDescription.insertNewObject(forEntityName: EntityName.device, into: context!) as! Device)
                    device.udid = object.udid
                }
                device.email = UserDefaultManager.email
                device.mac = object.internalID
                device.reminder =  object.isReminder
                device.scheduledoses = object.arrTime.joined(separator: ",")
                device.puff = Int16(object.puffs)
                device.medname =  object.medication.medName
                device.medtypeid = Int16(object.medTypeID)
                device.version = object.version != "" ? object.version : device.version
                try context?.save()
                Logger.logInfo("Device \(arrDevice.count == 0 ? "Save" : "Update") : \(device.mac ?? "") with udid:\(device.udid ?? "")")
            }
        } catch {
            
        }
    }
    
    func getActuationLogList(mac: String) -> [[String: Any]] {
        var actuationLog = [AcuationLog]()
        var usage = [[String: Any]]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.acuationLog)
        let predicate1 =  NSPredicate(format: "deviceidmac == %@", mac)
        let predicate2 =  NSPredicate(format: "issync == %d", false)
        let predicate3 =  NSPredicate(format: "isbadlog == %d", false)
        let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2, predicate3])
        
        fetchRequest.predicate = predicate
        do {
            try context?.save()
            actuationLog = try context?.fetch(fetchRequest) as! [AcuationLog]
            for obj in actuationLog {
                let log = obj
                let maxDate = Date().getString(format: DateFormate.useDateLocalAPI, isUTC: false)
                let minDate = getMinDate()
                if log.usedatelocal! > minDate && log.usedatelocal! < maxDate {
                    usage.append(log.APILog())
                } else {
                    log.isbadlog = true
                }
                try context?.save()
            }
        } catch {
            debugPrint("Can not get Data")
        }
        
        return usage
    }
    
    func getActuationLogListUnSync() -> [[String: Any]] {
        var actuationLog = [AcuationLog]()
        var usage = [[String: Any]]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.acuationLog)
        let predicate2 =  NSPredicate(format: "issync == %d", false)
        let predicate3 =  NSPredicate(format: "isbadlog == %d", false)
        let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate2, predicate3])
        fetchRequest.predicate = predicate
        do {
            try context?.save()
            actuationLog = try context?.fetch(fetchRequest) as! [AcuationLog]
            for obj in actuationLog {
                let maxDate = Date().getString(format: DateFormate.useDateLocalAPI, isUTC: false)
                let minDate = getMinDate()
                if obj.usedatelocal! > minDate && obj.usedatelocal! < maxDate {
                    usage.append(["Param": obj.APIForSingle()])
                } else {
                    obj.isbadlog = true
                }
                try context?.save()
            }
        } catch {
            debugPrint("Can not get Data")
        }
        return usage
    }
    
    func setRTCFor(udid: String, value: Bool) {
        var device = [Device]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.device)
        let predicate = NSPredicate(format: "udid == %@", udid)
        fetchRequest.predicate = predicate
        do {
            device = try context?.fetch(fetchRequest) as! [Device]
            if device.count > 0 {
                device = device.map({ obj in
                    obj.setrtc = value
                    return obj
                })
            }
            try context?.save()
        } catch {
            debugPrint("Can not get Data")
        }
    }
    
    func getIsSetRTC(udid: String) -> Bool {
        var device = [Device]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.device)
        let predicate = NSPredicate(format: "udid == %@", udid)
        fetchRequest.predicate = predicate
        do {
            device = try context?.fetch(fetchRequest) as! [Device]
        } catch {
            debugPrint("Can not get Data")
        }
        if device.count > 0 { return device[0].setrtc } else { return false }
    }
    
    func deleteAllActuationLog() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.acuationLog)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try context?.execute(request)
            try context?.save()
        } catch {
            debugPrint("There was an error")
        }
    }
    
    func deleteMacAddress(macAddress: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.device)
        let predicate = NSPredicate(format: "mac == %@", macAddress)
        fetchRequest.predicate = predicate
        do {
            if let  arrDevice = try context?.fetch(fetchRequest) {
                for obj in arrDevice {
                    context?.delete(obj)
                }
                try context?.save()
            }
            setupUDID(mac: macAddress, udid: "", isDelete: true)
        } catch {
            debugPrint("There was an error")
        }
    }
    
    
    func deleteAllDevice() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.device)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try context?.execute(request)
            try context?.save()
        } catch {
            debugPrint("There was an error")
        }
    }
    
    func getAddedDeviceList(email: String) -> [Device] {
        var device = [Device]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.device)
        let predicate = NSPredicate(format: "email == %@", email)
        fetchRequest.predicate = predicate
        do {
            device = try context?.fetch(fetchRequest) as! [Device]
        } catch {
            debugPrint("Can not get Data")
        }
        return device
    }
}
extension DatabaseManager {
    
    func updateDeviceVersion(macAddress: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.device)
    }
    
    func updateActuationLog(_ updateObj: [[String: Any]]) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.acuationLog)
        for obj in updateObj {
            let mac = obj["DeviceId"] as! String
            if let usage = obj["Usage"] as? [[String: Any]] {
                
                for data in usage {
                    let date = data["UseDateLocal"] as! String
                    let predicate1 =  NSPredicate(format: "deviceidmac == %@", mac)
                    let predicate2 =  NSPredicate(format: "usedatelocal == %@", date)
                    let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
                    
                    fetchRequest.predicate = predicate
                    guard let `context` = context else { return }
                    do {
                        if let logs = try context.fetch(fetchRequest) as? [AcuationLog] {
                            for log in logs {
                                log.issync = true
                                try context.save()
                            }
                        }
                    } catch {
                        debugPrint("cant update :\(error.localizedDescription)")
                    }
                }
            }
            
        }
    }
    
    
    func updateActuationLogwithTimeAdd(_ updateObj: [[String: Any]], sec: Int = 2) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.acuationLog)
        for obj in updateObj {
            let mac = obj["DeviceId"] as! String
            if let usage = obj["Usage"] as? [[String: Any]] {
                
                for data in usage {
                    let date = data["UseDateLocal"] as! String
                    let predicate1 =  NSPredicate(format: "deviceidmac == %@", mac)
                    let predicate2 =  NSPredicate(format: "usedatelocal == %@", date)
                    let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
                    
                    fetchRequest.predicate = predicate
                    do {
                        let logs = try context?.fetch(fetchRequest) as! [AcuationLog]
                        for log in logs {
                            var date = log.usedatelocal!.getDate(format: DateFormate.useDateLocalAPI)
                            date.addTimeInterval(TimeInterval(sec))
                            if date > Date() {
                                log.isbadlog = true
                            }
                            let useDatePlus5sec = date.getString(format: DateFormate.useDateLocalAPI)
                            log.usedatelocal = useDatePlus5sec
                            try context?.save()
                        }
                    } catch {
                        debugPrint("cant update :\(error.localizedDescription)")
                    }
                }
            }
            
        }
    }
    
    
    func setupUDID(mac: String, udid: String, isDelete: Bool = false ) {
        
        let keychain = KeychainSwift()
        
        if isDelete {
            keychain.delete(mac)
        } else {
            keychain.set(udid, forKey: mac)
            print("setUUID\(udid) for mac \(mac)")
        }
    }
    
    func getUDID(mac: String) -> String {
        let keychain = KeychainSwift()
        guard let oldUDID = keychain.get(mac) else {
            // udid not found in keychain
            return ""
        }
        return oldUDID
        
    }
    
    func getMac(UDID: String) -> String {
        var device = [Device]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.device)
        let predicate = NSPredicate(format: "udid == %@", UDID)
        fetchRequest.predicate = predicate
        do {
            device = try context?.fetch(fetchRequest) as! [Device]
        } catch {
            debugPrint("Can not get Data")
        }
        if device.count > 0 {
            return device[0].mac!
        } else {
            return ""
        }
    }
    
    func isContinuasBadReading(uuid: String) -> Bool {
        var actuationLog = [AcuationLog]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.acuationLog)
        let predicate1 =  NSPredicate(format: "deviceuuid == %@", uuid)
        let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1])
        
        let sortDescriptor = [NSSortDescriptor.init(key: "usedatelocal", ascending: false)]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor
        fetchRequest.fetchLimit = 5
        
        do {
            actuationLog = try context?.fetch(fetchRequest) as! [AcuationLog]
            let arrBad = actuationLog.filter({$0.isbadlog == true})
            return arrBad.count == 5
        } catch {
            debugPrint("Can not get Data")
            return false
        }
    }
    func getMentainanceDeviceList(date: String) -> [History] {
        var device = [Device]()
        var history = [History]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.device)
        let predicate1 = NSPredicate(format: "email == %@", UserDefaultManager.email)
        let predicate2 =  NSPredicate(format: "medtypeid == %d", 2)
        let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
        
        fetchRequest.predicate = predicate
        do {
            device = try context?.fetch(fetchRequest) as! [Device]
        } catch {
            debugPrint("Can not get Data")
        }
        for obj in device {
            let his = obj.deviceForMantainance()
            his.acuation = getActuationogForHistory(mac: obj.mac!, date: date)
            history.append(his)
            
        }
        return history
    }
    
    func removeMentainanceDeviceList() {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.device)

        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context?.execute(batchDeleteRequest)

        } catch {
            // Error Handling
        }
    }
    
    func getActuationogForHistory(mac: String, date: String) -> [AcuationLog] {
        var actuationLog = [AcuationLog]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.acuationLog)
        let predicate1 =  NSPredicate(format: "deviceidmac == %@", mac)
        let predicate3 =  NSPredicate(format: "isbadlog == %d", false)
        let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate3])
        
        fetchRequest.predicate = predicate
        do {
            actuationLog = try context?.fetch(fetchRequest) as! [AcuationLog]
        } catch {
            debugPrint("Can not get Data")
        }
        let filter = actuationLog.filter({($0.usedatelocal ?? "").contains(date)})
        return filter
        
    }
    func getMinDate() -> String {
        var dateComponents = DateComponents()
        dateComponents.year = 2021
        dateComponents.month = 12
        dateComponents.day = 31
        dateComponents.timeZone = .current
        dateComponents.hour = 0
        dateComponents.minute = 0
        let someDateTime = Calendar.current.date(from: dateComponents)
        return someDateTime!.getString(format: DateFormate.useDateLocalAPI, isUTC: false)
    }
}
