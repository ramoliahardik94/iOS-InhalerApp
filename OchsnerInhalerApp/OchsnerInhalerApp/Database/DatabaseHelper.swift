//
//  DatabaseHelper.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 10/02/22.
//

import Foundation
import CoreData
import UIKit


struct EntityName {
    static let acuationLog = "AcuationLog"
    static let device = "Device"
}



class DatabaseManager {
    static var share = DatabaseManager()
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func saveAccuation(object: [String: Any]) {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.acuationLog)
        let predicate1 =  NSPredicate(format: "usedatelocal == %@", ("\(object["date"]!)"))
        let predicate2 =  NSPredicate(format: "issync == %d", false)
        let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
        fetchRequest.predicate = predicate
        do {
            var accuationLog: AcuationLog!
            let arrAccuationLog = try context?.fetch(fetchRequest) as! [AcuationLog]
            if arrAccuationLog.count != 0 {
                accuationLog = arrAccuationLog[0]
            } else {
                accuationLog = (NSEntityDescription.insertNewObject(forEntityName: EntityName.acuationLog, into: context!) as! AcuationLog)
            }
            accuationLog.uselength = Double("\(object["useLength"]!)") ?? 0.0
            debugPrint(object)
            accuationLog.usedatelocal = (object["date"] as! String)
            accuationLog.longitude = (object["long"] as! String)
            accuationLog.latitude = (object["lat"] as! String)
            accuationLog.issync = (object["isSync"] as! Bool)
            accuationLog.deviceidmac = ( object["mac"] as! String)
            accuationLog.deviceuuid = (object["udid"] as! String)
            accuationLog.batterylevel = Double(object["batterylevel"] as! String)!
            accuationLog.uselength = Double("\(object["useLength"]!)")!
            accuationLog.devicesyncdateutc = Date().getString(format: "yyyy-MM-dd'T'HH:mm:ss'Z'", isUTC: true)
            try context?.save()
        } catch {
            debugPrint("Can not get Data")
        }
    }
    
    func isMantenanceAllow( mac: String) -> Bool {
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
            return true
        } else {
            return arrDevice[0].mac == mac
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
    
    func saveDevice(object: DeviceModel) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.device)
        
        let predicate1 =  NSPredicate(format: "mac == %@", object.internalID)
        let predicate2 =  NSPredicate(format: "email == %@", UserDefaultManager.email)
        let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
        fetchRequest.predicate = predicate
        do {
            var accuationLog: Device!
            let arrAccuationLog = try context?.fetch(fetchRequest) as! [Device]
            if arrAccuationLog.count != 0 {
                accuationLog = arrAccuationLog[0]
                if accuationLog.udid == "" && object.udid != "" {
                    accuationLog.mac = object.internalID
                    accuationLog.udid = object.udid
                    accuationLog.email = UserDefaultManager.email
                    accuationLog.medtypeid = Int16(object.medTypeID)
                }
                accuationLog.reminder =  object.isReminder
            } else {
                accuationLog = (NSEntityDescription.insertNewObject(forEntityName: EntityName.device, into: context!) as! Device)
                accuationLog.mac = object.internalID
                accuationLog.udid = object.udid
                accuationLog.email = UserDefaultManager.email
                accuationLog.reminder =  object.isReminder
                accuationLog.medtypeid = Int16(object.medTypeID)
            }
            try context?.save()
        } catch {
            
        }
    }
    
    func getAccuationLogList(mac: String) -> [[String: Any]] {
        var accuationLog = [AcuationLog]()
        var usage = [[String: Any]]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName.acuationLog)
        let predicate1 =  NSPredicate(format: "deviceidmac == %@", mac)
        let predicate2 =  NSPredicate(format: "issync == %d", false)
        let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
        
        fetchRequest.predicate = predicate
        do {
            accuationLog = try context?.fetch(fetchRequest) as! [AcuationLog]
        } catch {
            debugPrint("Can not get Data")
        }
        for obj in accuationLog {
            let log = obj
            usage.append(log.APILog())
        }
        return usage
    }
    
    func deleteAllAccuationLog() {
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
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.device)
        let predicate = NSPredicate(format: "mac == %@", macAddress)
        fetch.predicate = predicate
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try context?.execute(request)
            try context?.save()
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
    
    func updateAccuationLog(_ updateObj: [[String: Any]]) {
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
                            log.issync = true
                            try context?.save()
                        }
                    } catch {
                        debugPrint("cant update :\(error.localizedDescription)")
                    }
                }
            }
            
        }
    }
}
