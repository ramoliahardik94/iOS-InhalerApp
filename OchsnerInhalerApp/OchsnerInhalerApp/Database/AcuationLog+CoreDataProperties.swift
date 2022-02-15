//
//  AcuationLog+CoreDataProperties.swift
//  
//
//  Created by Nikita Bhatt on 10/02/22.
//
//

import Foundation
import CoreData


extension AcuationLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AcuationLog> {
        return NSFetchRequest<AcuationLog>(entityName: "AcuationLog")
    }

    @NSManaged public var usedatelocal: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var uselength: Double
    @NSManaged public var deviceidmac: String?
    @NSManaged public var deviceuuid: String?
    @NSManaged public var issync: Bool
    @NSManaged public var batterylevel: Double
    
    func APILog() -> [String: Any] {
        let strDate = Date().getString(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", isUTC: true)
        let dicLog = ["UseDateLocal": usedatelocal!,
                      "DeviceSyncDateUTC": strDate,
                      "Latitude": Double(latitude!)! as Any,
                      "Longitude": Double(longitude!)! as Any,
                      "UseLength": uselength]
        return dicLog
    }
}
