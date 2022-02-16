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
    func save(object: [String: Any]) {
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
}
