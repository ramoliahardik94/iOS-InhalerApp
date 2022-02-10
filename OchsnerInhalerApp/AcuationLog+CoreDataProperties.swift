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

    @NSManaged public var use_date_local: String?
    @NSManaged public var latitude: String?
    @NSManaged public var longitude: String?
    @NSManaged public var use_length: Double
    @NSManaged public var device_id_mac: String?
    @NSManaged public var device_uuid: String?

}
