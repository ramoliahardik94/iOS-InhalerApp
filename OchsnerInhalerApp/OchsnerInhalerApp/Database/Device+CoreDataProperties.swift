//
//  Device+CoreDataProperties.swift
//  
//
//  Created by Nikita Bhatt on 18/02/22.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var mac: String?
    @NSManaged public var udid: String?
    @NSManaged public var email: String?
}
