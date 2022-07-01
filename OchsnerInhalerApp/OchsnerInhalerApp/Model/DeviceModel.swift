//
//  DeviceModel.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 15/02/22.
//

import Foundation

class DeviceModel: NSObject {
    var deviceID: Int = 0
    var internalID: String = ""
    var userID: Int = 0
    var medTypeID: Int = 0
    var dailyUsage: Int = 0
    var puffs: Int = 1
    var activeFL: Bool = false
    var medID: Int = 0
    var batteryLevel: String = "Not Set"
    var batteryLevelDate: String = ""
    var medType: MedType = MedType()
    var medication: MedicationModelElement = MedicationModelElement()
    var useTimes: [String] = [String]()
    var arrTime: [String] = [String]()
    var isReminder = true
    var udid = ""
    var version: String = ""
    var discription: String = ""
    override init () {        
    }
    init(jSon: [String: Any]) {
        
        if let value = jSon["DeviceId"] as? Int {
            self.deviceID = value
        }
        if let value = jSon["Description"] as? String {
            self.discription = value
        }
        if let value = jSon["InternalId"] as? String {
            self.internalID = value
        }
        if let value = jSon["UserId"] as? Int {
            self.userID = value
        }
        if let value = jSon["MedTypeId"] as? Int {
            self.medTypeID = value
        }
        if let value = jSon["DailyUsage"] as? Int {
            self.dailyUsage = value
        }
        if let value = jSon["Puffs"] as? Int {
            self.puffs = value
        }
        if let value = jSon["ActiveFl"] as? Bool {
            self.activeFL = value
        }
        if let value = jSon["MedId"] as? Int {
            self.medID = value
        }
        if let value = jSon["BatteryLevel"] as? String {
            self.batteryLevel = "\(value)%"
        }
        if let value = jSon["BatteryLevel"] as? Int {
            self.batteryLevel = "\(value)%"
        }
        if let value = jSon["BatteryLevelDate"] as? String {
            self.batteryLevelDate = value
        }
        if let value = jSon["MedType"] as? [String: Any] {
            self.medType = MedType(jSon: value)
        }
        if let value = jSon["Medication"] as? [String: Any] {
            self.medication = MedicationModelElement(jSon: value)
        }
        
        if let value = jSon["UseTimes"] as? String {
            useTimes.removeAll()
            arrTime.removeAll()
            if value.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                let time = value.split(separator: ",")
              
                for (index, element) in time.enumerated() {
                    let str = "\((index + 1).ordinal) Dose at \(element)"
                    arrTime.append("\(element)")
                    useTimes.append(str)
                    print("DeviceModel STORE UseTimes == \(arrTime.description)")
                }
            }
        }
             
    }
    
}
// MARK: - MedType
class MedType: NSObject {
    var typeID: Int = 0
    var typeName: String = ""
    
    override init () {
        typeID = 0
        typeName = ""
    }
    init(jSon: [String: Any]) {
        if let value = jSon["TypeId"] as? Int {
            self.typeID = value
        }
        if let value = jSon["TypeName"] as? String {
            self.typeName = value
        }
        
    }
}
