//
//  DashboardModel.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 21/02/22.
//

import Foundation

class DashboardModel: NSObject {
    var rescueData =  [MaintenanceModel]()
    var maintenanceData = [MaintenanceModel]()
    override init () {
    }
    
    init(jSon: [String: Any]) {
        if let value = jSon["RescueData"] as? [[String: Any]] {
            for item in value {
                rescueData.append(MaintenanceModel(jSon: item, type: "1"))
            }
          //self.rescueData = value
        }
    
        if let value = jSon["MaintenanceData"] as? [[String: Any]] {
            for item in value {
                let obj = MaintenanceModel(jSon: item, type: "2")
                maintenanceData.append(obj)
            }
        }
    }
}

class RescueModel: NSObject {
    var medName: String? // ": "ProAir",
    var today: UsageModel?
    var thisWeek: UsageModel?
    var thisMonth: UsageModel?
    
    init(jSon: [String: Any]) {
        if let value = jSon["MedName"] as? String {
            self.medName = value
        }
        if let value = jSon["Today"] as? [String: Any] {
            self.today = UsageModel(jSon: value)
        }
        if let value = jSon["ThisWeek"] as? [String: Any] {
            self.thisWeek = UsageModel(jSon: value)
        }
        if let value = jSon["ThisMonth"] as? [String: Any] {
            self.thisMonth = UsageModel(jSon: value)
        }
    }
}

class MaintenanceModel: NSObject {
    var medName: String? // ": "ProAir",
    var nextScheduledDose: String? // ": "ProAir",
    var thisWeek: UsageModel?
    var thisMonth: UsageModel?
    var dailyAdherence =  [DailyAdherenceModel]()
    var today: UsageModel?
    var type: String? // for Rescue=1 Mantainance=2
    override init () {
    }
    init(jSon: [String: Any], type: String) {
        if let value = jSon["MedName"] as? String {
            self.medName = value
        }
        if let value = jSon["NextScheduledDose"] as? String {
            self.nextScheduledDose = value
        }
        if let value = jSon["DailyAdherence"] as? [[String: Any]] {
            for item in value {
                self.dailyAdherence.append(DailyAdherenceModel(jSon: item))
            }
        }
        if let value = jSon["ThisWeek"] as? [String: Any] {
            self.thisWeek = UsageModel(jSon: value)
        }
        if let value = jSon["ThisMonth"] as? [String: Any] {
            self.thisMonth = UsageModel(jSon: value)
        }
        if let value = jSon["Today"] as? [String: Any] {
            self.today = UsageModel(jSon: value)
        }
        self.type = type
    }
}
class UsageModel: NSObject {
    var count: Int? // ": null,
    var doseDetail = [DoseDetails]()
    var adherence: Int? // ": 0,
    var status: Int? // ": 3,
    var change: String? // ": "Up"
    
    init(jSon: [String: Any]) {
        if let value = jSon["Count"] as? Int {
            self.count = value
        }
        if let value = jSon["Adherence"] as? Int {
            self.adherence = value
        }
        if let value = jSon["Status"] as? Int {
            self.status = value
        }
        if let value = jSon["Change"] as? String {
            self.change = value
        }
        if let value = jSon["DoseDetail"] as? [[String: Any]] {
            for item in value {
                self.doseDetail.append(DoseDetails(jSon: item))
            }
        }
    }
}

class DoseDetails: NSObject {
    var datetime: String? // ": null,
    
    init(jSon: [String: Any]) {
        if let value = jSon["DateTime"] as? String {
            self.datetime = value
        }
    }
}
class DailyAdherenceModel: NSObject {
    var day: String? // ": "Sa",
    var denominator: Int? // ": 2,
    var numerator: Int? // ": 1
    init(jSon: [String: Any]) {
        if let value = jSon["Day"] as? String {
            self.day = value
        }
        if let value = jSon["Denominator"] as? Int {
            self.denominator = value
        }
        if let value = jSon["Numerator"] as? Int {
            self.numerator = value
        }
    }
}
