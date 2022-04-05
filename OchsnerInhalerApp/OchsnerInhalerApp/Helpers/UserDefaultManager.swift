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
}

class UserDefaultManager {
    
    // MARK: - Bool
    static var isLogin: Bool {
        get {
            return self.get(forKey: .isLogin) as? Bool ?? false
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .isLogin)
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
    
//    static var addDevice: [String] {
//        get {
//            return self.get(forKey: .addDevice) as? [String] ?? [String]()
//        }
//        set(newValue) {
//            self.set(newValue as AnyObject?, forKey: .addDevice)
//        }
//    }
//
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
