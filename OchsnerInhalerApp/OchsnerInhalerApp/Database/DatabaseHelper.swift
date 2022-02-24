//
//  DatabaseHelper.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 10/02/22.
//

import Foundation
import CoreData
import UIKit
class DatabaseManager {
    static var share = DatabaseManager()
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func saveAccuation(object: [String: Any]) {
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AcuationLog")
        let predicate1 =  NSPredicate(format: "usedatelocal == %@", ("\(object["date"]!)"))
        let predicate2 =  NSPredicate(format: "issync == %d", false)
        let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
        fetchRequest.predicate = predicate
        do {
            var accuationLog = NSEntityDescription.insertNewObject(forEntityName: "AcuationLog", into: context!) as! AcuationLog
            let arrAccuationLog = try context?.fetch(fetchRequest) as! [AcuationLog]
            if arrAccuationLog.count != 0 {
                accuationLog = arrAccuationLog[0]
            }
            accuationLog.uselength = Double("\(object["useLength"]!)") ?? 0.0
            print(object)
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
            print("Can not get Data")
        }
        
        
        
        let accuationLog = NSEntityDescription.insertNewObject(forEntityName: "AcuationLog", into: context!) as! AcuationLog
        
        
        accuationLog.uselength = Double("\(object["useLength"]!)") ?? 0.0
        print(object)
        accuationLog.usedatelocal = (object["date"] as! String)
        accuationLog.longitude = (object["long"] as! String)
        accuationLog.latitude = (object["lat"] as! String)
        accuationLog.issync = (object["isSync"] as! Bool)
        accuationLog.deviceidmac = ( object["mac"] as! String)
        accuationLog.deviceuuid = (object["udid"] as! String)
        accuationLog.batterylevel = Double(object["batterylevel"] as! String)!
        accuationLog.uselength = Double("\(object["useLength"]!)")!
        accuationLog.devicesyncdateutc = Date().getString(format: "yyyy-MM-dd'T'HH:mm:ss'Z'", isUTC: true)
        do {
            try context?.save()
        } catch {
            print("data is not save")
        }
    }
    
    func saveDevice(object: [String: Any]) {
        
        deleteMacAddress(macAddress: BLEHelper.shared.addressMAC)
        let accuationLog = NSEntityDescription.insertNewObject(forEntityName: "Device", into: context!) as! Device
        accuationLog.mac = (object["mac"]! as! String)
        accuationLog.udid = (object["udid"]! as! String)
        accuationLog.email = (object["email"]! as! String)
        do {
            try context?.save()
            print("Save Device \(BLEHelper.shared.addressMAC)")
        } catch {
            print("data is not save")
        }
    }
    
    func getAccuationLogList(mac: String) -> [[String: Any]] {
        var accuationLog = [AcuationLog]()
        var usage = [[String: Any]]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AcuationLog")
        let predicate1 =  NSPredicate(format: "deviceidmac == %@", mac)
        let predicate2 =  NSPredicate(format: "issync == %d", false)
        let predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])
        
        fetchRequest.predicate = predicate
        do {
            accuationLog = try context?.fetch(fetchRequest) as! [AcuationLog]
        } catch {
            print("Can not get Data")
        }
        for obj in accuationLog {
            let log = obj
            usage.append(log.APILog())
        }
        return usage
    }
    
    func deleteAllAccuationLog() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "AcuationLog")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try context?.execute(request)
            try context?.save()
        } catch {
            print("There was an error")
        }
    }
    
    func deleteMacAddress(macAddress: String) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        let predicate = NSPredicate(format: "mac == %@", macAddress)
        fetch.predicate = predicate
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try context?.execute(request)
            try context?.save()
        } catch {
            print("There was an error")
        }
    }
    
    func deleteAllDevice() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try context?.execute(request)
            try context?.save()
        } catch {
            print("There was an error")
        }
    }
    
    func getAddedDeviceList(email: String) -> [Device] {
        var device = [Device]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device")
        let predicate = NSPredicate(format: "email == %@", email)
        fetchRequest.predicate = predicate
        do {
            device = try context?.fetch(fetchRequest) as! [Device]
        } catch {
            print("Can not get Data")
        }
        
        return device
    }
    
    func updateAccuationLog(_ updateObj: [[String: Any]]) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AcuationLog")
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
                        print("cant update :\(error.localizedDescription)")
                    }
                }
            }
            
        }
    }
}

