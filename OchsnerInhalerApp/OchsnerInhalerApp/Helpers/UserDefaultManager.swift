//
//  UserDefaultManager.swift
//

import UIKit
import CoreBluetooth

enum UserDefaultKey: String {
    
    case latitude
    case longitude
    case language
    case temperature
    case grantBLEPermission
    case grantLocationPermission
    case grantNotificationPermission
    case token
    case isLogin
    case isNotificationOn
    case deviceToken
    // case addDevice
    case selectedMedi
    case email
    case providerName
    case userEmailAddress
    case isLocationOn
    case isAddReminder
    case isFirstLaunch
    case username
    case dateLogin
    case bodyMass
    case fatPercent
    case leanBodyMass
    case height
    case waistCircumference
    case bodyMassIndex
    case heartRate
    case bodyTemperature
    case basalBodyTemperature
    case bloodPressureSystolic
    case bloodPressureDiastolic
    case respiratoryRate
    case stepCount
    case distanceWalkingRunning
    case dateRangeForHealthKit
}

class UserDefaultManager {
    
    static var bodyMass: String {
        get {
            return self.get(forKey: .bodyMass ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .bodyMass)
        }
    }
    static var fatPercent: String {
        get {
            return self.get(forKey: .fatPercent ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .fatPercent)
        }
    }
    static var leanBodyMass: String {
        get {
            return self.get(forKey: .leanBodyMass ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .leanBodyMass)
        }
    }
    static var height: String {
        get {
            return self.get(forKey: .height ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .height)
        }
    }
    static var waistCircumference: String {
        get {
            return self.get(forKey: .waistCircumference ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .waistCircumference)
        }
    }
    static var bodyMassIndex: String {
        get {
            return self.get(forKey: .bodyMassIndex ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .bodyMassIndex)
        }
    }
    static var heartRate: String {
        get {
            return self.get(forKey: .heartRate ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .heartRate)
        }
    }
    static var bodyTemperature: String {
        get {
            return self.get(forKey: .bodyTemperature ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .bodyTemperature)
        }
    }
    static var basalBodyTemperature: String {
        get {
            return self.get(forKey: .basalBodyTemperature ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .basalBodyTemperature)
        }
    }
    static var bloodPressureSystolic: String {
        get {
            return self.get(forKey: .bloodPressureSystolic ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .bloodPressureSystolic)
        }
    }
    static var bloodPressureDiastolic: String {
        get {
            return self.get(forKey: .bloodPressureDiastolic ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .bloodPressureDiastolic)
        }
    }
    static var respiratoryRate: String {
        get {
            return self.get(forKey: .respiratoryRate ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .respiratoryRate)
        }
    }
    static var stepCount: String {
        get {
            return self.get(forKey: .stepCount ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .stepCount)
        }
    }
    static var distanceWalkingRunning: String {
        get {
            return self.get(forKey: .distanceWalkingRunning ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .distanceWalkingRunning)
        }
    }
    static var dateRangeForHealthKit: String {
        get {
            return self.get(forKey: .dateRangeForHealthKit ) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .dateRangeForHealthKit)
        }
    }
    
    // MARK: - Bool
    static var isLogin: Bool {
        get {
            return self.get(forKey: .isLogin) as? Bool ?? false
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .isLogin)
        }
    }
    
    // MARK: - Date
    static var dateLogin: Date {
        get {
            return self.get(forKey: .dateLogin) as? Date ?? Date()
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .dateLogin)
        }
    }
    
    // MARK: - Bool
    static var isFirstLaunch: Bool {
        get {
            return self.get(forKey: .isFirstLaunch) as? Bool ?? false
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .isFirstLaunch)
        }
    }
    
    static var email: String {
        get {
            return self.get(forKey: .email) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .email)
        }
    }
    static var username: String {
        get {
            return self.get(forKey: .username) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .username)
        }
    }
    
    static var token: String {
        get {
            return self.get(forKey: .token) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .token)
        }
    }
    
    static var latitude: String {
        get {
            return self.get(forKey: .latitude) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .latitude)
        }
    }
    
    static var longitude: String {
        get {
            return self.get(forKey: .longitude) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .longitude)
        }
    }
    static var selectedMedi: [String: Any] {
        get {
            return self.get(forKey: .selectedMedi ) as? [String: Any] ?? [String: Any]()
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .selectedMedi)
        }
    }
    
    // MARK: - Save/Retrive/Remove Data
    
    static private func set(_ object: AnyObject?, forKey key: UserDefaultKey) {
        UserDefaults.standard.set(object, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    static private func get(forKey key: UserDefaultKey) -> AnyObject? {
        return UserDefaults.standard.object(forKey: key.rawValue) as AnyObject?
    }
    
    static func remove(forKey key: UserDefaultKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: For Permissions
    
    static var isGrantBLE: Bool {
        get {
            return self.get(forKey: .grantBLEPermission) as? Bool ?? false
        }
        set(newValue) {
            self.set(NSNumber(value: newValue), forKey: .grantBLEPermission)
        }
    }
    
    static var isGrantLaocation: Bool {
        get {
            return self.get(forKey: .grantLocationPermission) as? Bool ?? false
        }
        set(newValue) {
            self.set(NSNumber(value: newValue), forKey: .grantLocationPermission)
        }
    }
    
    static var isGrantNotification: Bool {
        get {
            return self.get(forKey: .grantNotificationPermission) as? Bool ?? false
        }
        set(newValue) {
            self.set(NSNumber(value: newValue), forKey: .grantNotificationPermission)
        }
    }
    
    static var isNotificationOn: Bool {
        get {
            return self.get(forKey: .isNotificationOn) as? Bool ?? false
        }
        set(newValue) {
            self.set(NSNumber(value: newValue), forKey: .isNotificationOn)
        }
    }
    
    static var deviceToken: String {
        get {
            return self.get(forKey: .deviceToken) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .deviceToken)
        }
    }
    
    
    static var providerName: String {
        get {
            return self.get(forKey: .providerName) as? String ?? "Ochsner Health"
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .providerName)
        }
    }
    static var userEmailAddress: String {
        get {
            return self.get(forKey: .userEmailAddress) as? String ?? "Ochsner Health"
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .userEmailAddress)
        }
    }
    
    static var isLocationOn: Bool {
        get {
            return self.get(forKey: .isLocationOn) as? Bool ?? false
        }
        set(newValue) {
            self.set(NSNumber(value: newValue), forKey: .isLocationOn)
        }
    }
    
    static var isAddReminder: Bool {
        get {
            return self.get(forKey: .isAddReminder) as? Bool ?? true
        }
        set(newValue) {
            self.set(NSNumber(value: newValue), forKey: .isAddReminder)
        }
    }
    
    
}
