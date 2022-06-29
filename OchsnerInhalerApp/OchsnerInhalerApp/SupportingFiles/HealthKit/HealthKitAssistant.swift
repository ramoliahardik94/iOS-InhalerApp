//
//  HealthKitAssistant.swift
//  HealthApp
//
//  Created by Nikita Bhatt on 13/06/22.
//

import Foundation
import HealthKit
import UIKit


class HealthKitAssistant {
    // Shared Variable
    static let shared = HealthKitAssistant()
    // BMI
    let bodyMass = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
    let fatPercent   = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!
    let leanBodyMass = HKQuantityType.quantityType(forIdentifier: .leanBodyMass)!
    let height   = HKQuantityType.quantityType(forIdentifier: .height)!
    let waistCircumference = HKQuantityType.quantityType(forIdentifier: .waistCircumference)!
    let bodyMassIndex = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)!
    
    // Vitals
    let heartRate = HKQuantityType.quantityType(forIdentifier: .heartRate)! // Scalar(Count)/Time,          Discrete
    let bodyTemperature = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!// Temperature,                 Discrete
    let basalBodyTemperature  = HKQuantityType.quantityType(forIdentifier: .basalBodyTemperature)!// Basal Body Temperature,      Discrete
    let bloodPressureSystolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)! // Pressure,                    Discrete
     // Pressure,                    Discrete
    let bloodPressureDiastolic = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)! // Pressure,                    Discrete
    let respiratoryRate = HKQuantityType.quantityType(forIdentifier: .respiratoryRate)! // Scalar(Count)/Time,          Discrete
    
    // Fitness
    let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    let distanceWalkingRunning = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    
    // Healthkit store object
    let healthKitStore = HKHealthStore()
    
    // MARK: Permission block
    func getHealthKitPermission(completion: @escaping (Bool) -> Void) {
        
        // Check HealthKit Available
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        var permitionArray: Set<HKQuantityType> {
            return Set([bodyMass,
                        fatPercent,
                        leanBodyMass,
                        height,
                        waistCircumference,
                        bodyMassIndex,
                        heartRate,
                        bodyTemperature,
                        basalBodyTemperature,
                        bloodPressureSystolic,
                        bloodPressureDiastolic,
                        respiratoryRate,
                        stepCount,
                        distanceWalkingRunning])
        }
        
        self.healthKitStore.requestAuthorization(toShare: nil, read: permitionArray) { (success, error) in
            if success {
                completion(true)
            } else {
                if error != nil {
                    print(error ?? "")
                }
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    // MARK: - HealthKit Query
    func getMostRecentDetail(for sampleType: HKQuantityType, completion: @escaping (_ results: [HKSample]?) -> Void) {
        let lastday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        // Use HKQuery to load the most recent samples.
        
        
        var interval = DateComponents()
        interval.day = 1
        let predicate = HKQuery.predicateForSamples(withStart: lastday, end: Date(), options: [])
        
        let str = "\(String(describing: lastday!.getString(format: "ddMMMyyyy"))) - \(Date().getString(format: "ddMMMyyyy"))"
        print(str)
        UserDefaultManager.dateRangeForHealthKit = str
        // Get the recent data first
        let sortDescriptors = [
            NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        ]
        let heartRateQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: sortDescriptors, resultsHandler: { (_, results, error) in
            guard error == nil else { print("error"); return }
            print(results as Any)
            completion(results)
        })
        
        HKHealthStore().execute(heartRateQuery)
    }
    // MARK: - Get Vital Details:
    func getVitalData() {
        getMostRecentDetail(for: heartRate) { [self] result in // weight
            print(result as Any)
            Logger.logInfo("Vital: heartRate " + sampleInfo(results: result))
            UserDefaultManager.heartRate = sampleInfo(results: result)
        }
        getMostRecentDetail(for: bodyTemperature) { [self] result in
            print(result as Any)
            Logger.logInfo("Vital: bodyTemperature " + sampleInfo(results: result, unit: "degC"))
            UserDefaultManager.bodyTemperature = sampleInfo(results: result, unit: "degC")
        }
        getMostRecentDetail(for: basalBodyTemperature) { [self] result in
            print(result as Any)
            Logger.logInfo("Vital: basalBodyTemperature " + sampleInfo(results: result, unit: "degC"))
            UserDefaultManager.basalBodyTemperature = sampleInfo(results: result, unit: "degC")
        }
        getMostRecentDetail(for: bloodPressureSystolic) { [self] result in
            print(result as Any)
            Logger.logInfo("Vital: bloodPressureSystolic " + sampleInfo(results: result, unit: "mmHg"))
            UserDefaultManager.bloodPressureSystolic = sampleInfo(results: result, unit: "mmHg")
        }
        getMostRecentDetail(for: bloodPressureDiastolic) { [self] result in
            print(result as Any)
            Logger.logInfo("Vital: bloodPressureDiastolic " + sampleInfo(results: result, unit: "mmHg"))
            UserDefaultManager.bloodPressureDiastolic = sampleInfo(results: result, unit: "mmHg")
        }
        getMostRecentDetail(for: respiratoryRate) { [self] result in
            print(result as Any)
            Logger.logInfo("Vital: respiratoryRate " + sampleInfo(results: result))
            UserDefaultManager.respiratoryRate = sampleInfo(results: result)
        }
    }
    
    // MARK: - Get BMI Details:
    func getBMIReport() {
        getMostRecentDetail(for: bodyMass) { [self] result in // weight
            UserDefaultManager.bodyMass = sampleInfo(results: result, unit: "kg")
            print(result as Any)
            Logger.logInfo("BMI: bodyMass " + sampleInfo(results: result, unit: "kg"))
        }
        getMostRecentDetail(for: height) { [self] result in
            UserDefaultManager.height = sampleInfo(results: result, unit: "cm")
            print(result as Any)
            Logger.logInfo("BMI: height " + sampleInfo(results: result, unit: "cm"))
        }
        getMostRecentDetail(for: leanBodyMass) { [self] result in
            UserDefaultManager.leanBodyMass = sampleInfo(results: result, unit: "kg")
            print(result as Any)
            Logger.logInfo("BMI: leanBodyMass " + sampleInfo(results: result, unit: "kg"))
        }
        getMostRecentDetail(for: fatPercent) { [self] result in
            UserDefaultManager.fatPercent = sampleInfo(results: result, unit: "%")
            print(result as Any)
            Logger.logInfo("BMI: fatPercent " + sampleInfo(results: result, unit: "%"))
        }
        getMostRecentDetail(for: bodyMassIndex) { [self] result in
            UserDefaultManager.bodyMassIndex = sampleInfo(results: result, unit: "count")
            print(result as Any)
            Logger.logInfo("BMI: bodyMassIndex " + sampleInfo(results: result, unit: "count"))
        }
        getMostRecentDetail(for: waistCircumference) { [self] result in
            UserDefaultManager.waistCircumference = sampleInfo(results: result, unit: "cm")
            print(result as Any)
            Logger.logInfo("BMI: waistCircumference " + sampleInfo(results: result, unit: "cm"))
        }
    }
    
    // MARK: - Get Fitness Details:
    func getFitnessReport() {
        getMostRecentDetail(for: stepCount) { [self] result in
            print(result as Any)
            UserDefaultManager.stepCount = sampleInfo(results: result, unit: "count")
            Logger.logInfo("Fitness: stepCount " + sampleInfo(results: result, unit: "count"))
        }
        getMostRecentDetail(for: distanceWalkingRunning) { [self] result in
            print(result as Any)
            UserDefaultManager.distanceWalkingRunning = sampleInfo(results: result, unit: "km")
            Logger.logInfo("Fitness: distanceWalkingRunning " + sampleInfo(results: result, unit: "km"))
        }
    }
    
    // MARK: - Function for creating String.
    /*used only for testing, prints heart rate info */
    private func sampleInfo(results: [HKSample]?, unit: String = "count/min") -> String {
        let heartRateUnit: HKUnit = HKUnit(from: unit)
        var value = ""
        for sample in results! {
            guard let currData: HKQuantitySample = sample as? HKQuantitySample else { return "" }
            Logger.logInfo("[\(sample)]")
            value += "\(currData.quantity.doubleValue(for: heartRateUnit)) " + unit
//            Logger.logInfo("value: \(currData.quantity.doubleValue(for: heartRateUnit))")
//            Logger.logInfo("unit: \(currData.quantityType)")
//            Logger.logInfo("quantityType: \(currData.quantityType)")
//            Logger.logInfo("Start Date: \(currData.startDate)")
//            Logger.logInfo("End Date: \(currData.endDate)")
//            Logger.logInfo("Metadata: \(String(describing: currData.metadata))")
//            Logger.logInfo("UUID: \(currData.uuid)")
//            Logger.logInfo("Source: \(currData.sourceRevision)")
//            Logger.logInfo("Device: \(String(describing: currData.device))")
//            Logger.logInfo("---------------------------------\n")
        }// eofl
      
        return value
    }// eom
    
    // MARK: - ToSave details
    func saveHeartRate(bpm: Double) {
        let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
        let quantity = HKQuantity(unit: unit, doubleValue: bpm)
        let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let heartRateSample = HKQuantitySample(type: type, quantity: quantity, start: Date(), end: Date())
        
        self.healthKitStore.save(heartRateSample) { (success, error) -> Void in
            if !success {
                print("An error occured saving the HR sample \(heartRateSample). In your app, try to handle this gracefully. The error was: \(String(describing: error!)).")
            } else {
                print("Save Heart Rate Successfuly")
            }
        }
    }
    
    func saveStep(noStep: Double) {
        let unit = HKUnit.count().unitDivided(by: HKUnit.count())
        let quantity = HKQuantity(unit: unit, doubleValue: noStep)
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let heartRateSample = HKQuantitySample(type: type, quantity: quantity, start: Date(), end: Date())
        
        self.healthKitStore.save(heartRateSample) { (success, error) -> Void in
            if !success {
                print("An error occured saving the Step sample \(heartRateSample). In your app, try to handle this gracefully. The error was: \(String(describing: error!)).")
            } else {
                print("Save Steps Successfuly")
            }
        }
    }
    
    func saveOxygenSaturation(level: Double) {
        let unit = HKUnit.count().unitDivided(by: HKUnit.percent())
        let quantity = HKQuantity(unit: unit, doubleValue: level/100)
        let type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        
        let heartRateSample = HKQuantitySample(type: type, quantity: quantity, start: Date(), end: Date())
        
        self.healthKitStore.save(heartRateSample) { (success, error) -> Void in
            if !success {
                print("An error occured saving the OxygenSaturation sample \(heartRateSample). In your app, try to handle this gracefully. The error was: \(String(describing: error!)).")
            } else {
                print("Save OxygenSaturation Successfuly")
            }
        }
    }
    
    func saveSleepAnalysis() {
        // alarmTime and endTime are NSDate objects
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            let dateStart = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            let dateEnd = Date()
            // we create our new object we want to push in Health app
            let object = HKCategorySample(type: sleepType, value: HKCategoryValueSleepAnalysis.inBed.rawValue, start: dateStart, end: dateEnd)
            // at the end, we save it
            self.healthKitStore.save(object, withCompletion: { (success, error) -> Void in
                if error != nil {
                    // something happened
                    return
                }
                if success {
                    print("My new data was saved in HealthKit")
                    
                } else {
                    // something happened again
                }
            })
            let object2 = HKCategorySample(type: sleepType, value: HKCategoryValueSleepAnalysis.asleep.rawValue, start: dateStart, end: dateEnd)
            self.healthKitStore.save(object2, withCompletion: { (success, error) -> Void in
                if error != nil {
                    // something happened
                    return
                }
                if success {
                    print("My new data asleep was saved in HealthKit")
                } else {
                    // something happened again
                }
                
            })
        }
    }
    
    func getSleepTime() {
        // startDate and endDate are NSDate objects
        // first, we define the object type we want
        
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // You may want to use a predicate to filter the data... startDate and endDate are NSDate objects corresponding to the time range that you want to retrieve
            
            let dateStart = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
            let dateEnd = Date()
            let predicate = HKQuery.predicateForSamples(withStart: dateStart, end: dateEnd, options: [])
            
            // Get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            // the block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) { (_, tmpResult, _) -> Void in
                    if let result = tmpResult {
                        for item in result {
                            if let sample = item as? HKCategorySample {
                                let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                                print("sleep: \(sample.startDate) \(sample.endDate) - source: \(sample.source.name) - value: \(value)")
                                let seconds = sample.endDate.timeIntervalSince(sample.startDate)
                                let minutes = seconds/60
                                let hours = minutes/60
                                print("\(hours):\(minutes):\(seconds)")
                            }
                        }
                    }
                }
            self.healthKitStore.execute(query)
        }
    }
    
    public func getOxygenLevel(completion: @escaping (Double?, Error?) -> Void) {
        
        guard let oxygenQuantityType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else {
            fatalError("*** Unable to get oxygen saturation on this device ***")
        }
        
        HKHealthStore().requestAuthorization(toShare: nil, read: [oxygenQuantityType]) { (success, error) in
            
            guard error == nil, success == true else {
                completion(nil, error)
                return
            }
            
            let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
            let query = HKStatisticsQuery(quantityType: oxygenQuantityType,
                                          quantitySamplePredicate: predicate,
                                          options: .mostRecent) { _, result, error in
                DispatchQueue.main.async {
                    if let err = error {
                        completion(nil, err)
                    } else {
                        guard let level = result, let sum = level.mostRecentQuantity() else {
                            completion(nil, error)
                            return
                        }
                        print("Quantity : ", sum)
                        let measureUnit2 = HKUnit.percent()
                        let count2 = sum.doubleValue(for: measureUnit2)
                        print("Count 2 : ", count2)
                        completion(count2 * 100.0, nil)
                    }
                }
            }
            HKHealthStore().execute(query)
        }
    }
}
