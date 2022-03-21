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
    @NSManaged public var devicesyncdateutc: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var uselength: Double
    @NSManaged public var batterylevel: Double
    @NSManaged public var deviceidmac: String?
    @NSManaged public var deviceuuid: String?
    @NSManaged public var issync: Bool
    @NSManaged public var isbadlog: Bool
    
    func APILog() -> [String: Any] {       
        let dicLog = ["UseDateLocal": usedatelocal!,
                      "DeviceSyncDateUTC": devicesyncdateutc! as Any,
                      "Latitude": Double(latitude!)! as Any,
                      "Longitude": Double(longitude!)! as Any,
                      "UseLength": uselength,
                      "BatteryLevel": Double(BLEHelper.shared.bettery)! as Any]
        return dicLog
    }
    
    
    func DBDictionary() -> [String: Any] {
        let dicLog = ["UseDateLocal": usedatelocal!,
                      "DeviceSyncDateUTC": devicesyncdateutc! as Any,
                      "Latitude": Double(latitude!)! as Any,
                      "Longitude": Double(longitude!)! as Any,
                      "UseLength": uselength,
                      "BatteryLevel": Double(BLEHelper.shared.bettery)! as Any,
                      "MacAddress": deviceidmac as Any,
                      "UUID": deviceuuid as Any,
                      "isSync": issync as Any,
                      "isbadLog": isbadlog as Any]
        return dicLog
    }
}
