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
        let accuationLog = NSEntityDescription.insertNewObject(forEntityName: "AcuationLog", into: context!) as! AcuationLog
        accuationLog.uselength = Double("\(object["useLength"]!)") ?? 0.0
        print(accuationLog.uselength)
        accuationLog.usedatelocal = (object["date"] as! String)
        accuationLog.longitude = (object["long"] as! String)
        accuationLog.latitude = (object["lat"] as! String)
        accuationLog.issync = (object["isSync"] as! Bool)
        accuationLog.deviceidmac = ( object["mac"] as! String)
        accuationLog.deviceuuid = (object["udid"] as! String)
        accuationLog.batterylevel = Double(object["batterylevel"] as! String)!
        accuationLog.uselength = Double("\(object["useLength"]!)")!
        do {
            try context?.save()
        } catch {
            print("data is not save")
        }
    }
    
    func saveDevice(object: [String: Any]) {
        let accuationLog = NSEntityDescription.insertNewObject(forEntityName: "Device", into: context!) as! Device
        accuationLog.mac = (object["mac"]! as! String)
        accuationLog.udid = (object["udid"]! as! String)
        accuationLog.email = (object["email"]! as! String)
        do {
            try context?.save()
        } catch {
            print("data is not save")
        }
    }
    
    func getAccuationLogList() {
        var accuationLog = [AcuationLog]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AcuationLog")
//        fetchRequest.predicate = NSPredicate(
//            format: "issync LIKE %@", "false"
//        )
        do {
            accuationLog = try context?.fetch(fetchRequest) as! [AcuationLog]
        } catch {
            print("Can not get Data")
        }
        for obj in accuationLog {
            let log = obj
            print(log.APILog())
        }
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
        for obj in device {
            let log = obj
            device.append(log)
        }
        return device
    }
}
