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
        
        accuationLog.uselength = 1
        accuationLog.usedatelocal = "12.112.12"
        
        do {
            try context?.save()
        } catch {
            print("data is not save")
        }
    }
//    func getAccuationLogList() {
//        var accuationLog = [AcuationLog]()
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AcuationLog")
//        fetchRequest.predicate = NSPredicate(
//            format: "issync LIKE %@", "false"
//        )
//        do {
//            accuationLog = try context?.fetch(fetchRequest) as! [AcuationLog]
//        } catch {
//            print("Can not get Data")
//        }
//        print(accuationLog)
//    }
}
