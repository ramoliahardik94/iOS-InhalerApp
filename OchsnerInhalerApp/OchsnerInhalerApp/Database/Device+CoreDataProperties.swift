//
//  Device+CoreDataProperties.swift
//  
//
//  Created by Nikita Bhatt on 03/03/22.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var email: String?
    @NSManaged public var mac: String?
    @NSManaged public var udid: String?
    @NSManaged public var medtypeid: Int16
    @NSManaged public var reminder: Bool

}
