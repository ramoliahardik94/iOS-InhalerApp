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
    @NSManaged public var setrtc: Bool
    @NSManaged public var scheduledoses: String?
    @NSManaged public var medname: String?
    @NSManaged public var puff: Int16
    @NSManaged public var version: String?
    @NSManaged public var date: Date?
    
    
    func deviceForMantainance() -> History {
        var dic = [String: Any]()
        dic["puff"] = self.puff
        dic["medName"] = self.medname
        dic["mac"] = self.mac
        dic["dose"] = self.scheduledoses
        let history = History(jSon: dic)
        return history
    }
}
