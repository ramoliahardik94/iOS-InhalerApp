//
//  UserDefaultManager.swift
//

import UIKit

enum UserDefaultKey: String {
    case loginUserModel
    case deviceToken
    case biometry
    case appPin
    case needToRemember
    case isFirstTimeLoginSet
    case isBurgularyAlarmOn
    case isNotificationOn
    case latitude
    case longitude
    case language
    case temperature
}

class UserDefaultManager {
    
    // MARK: - Bool
    static var biometry: Bool {
        get {
            return self.get(forKey: .biometry) as? Bool ?? false
        }
        set(newValue) {
            self.set(NSNumber(value: newValue), forKey: .biometry)
        }
    }
    
    static var needToRemember: Bool {
        get {
            return self.get(forKey: .needToRemember) as? Bool ?? false
        }
        set(newValue) {
            self.set(NSNumber(value: newValue), forKey: .needToRemember)
        }
    }
    
    static var isFirstTimeLoginSet: Bool {
        get {
            return self.get(forKey: .isFirstTimeLoginSet) as? Bool ?? false
        }
        set(newValue) {
            self.set(NSNumber(value: newValue), forKey: .isFirstTimeLoginSet)
        }
    }
    
    static var isBurgularyAlarmOn: Bool {
        get {
            return self.get(forKey: .isBurgularyAlarmOn) as? Bool ?? false
        }
        set(newValue) {
            self.set(NSNumber(value: newValue), forKey: .isBurgularyAlarmOn)
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
    
    // MARK: - String
    static var deviceToken: String {
        get {
            return self.get(forKey: .deviceToken) as? String ?? ""
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .deviceToken)
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
    
    static var appPin: String? {
        get {
            return self.get(forKey: .appPin) as? String
        }
        set(newValue) {
            self.set(newValue as AnyObject?, forKey: .appPin)
        }
    }
    

   
    
    // MARK: - Model
    
//    static var loggedInUserModel: UserModel? {
//        get {
//            if let modelObj = self.get(forKey: .loginUserModel) {
//                let jsonString =  modelObj as! String
//                let jsonData = jsonString.data(using: .utf8)
//                do {
//                    if let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves) {
//                        let shareobj = Mapper<UserModel>().map(JSON: dictionary as! [String: Any])
//                        return shareobj
//                    }
//                }
//            }
//            return nil
//        }
//        set(newValue) {
//            if let modelObj = newValue {
//                let JSONString = modelObj.toJSONString(prettyPrint: true)
//                self.set(JSONString as AnyObject?, forKey: .loginUserModel)
//            } else {
//                self.remove(forKey: .loginUserModel)
//            }
//        }
//    }
    
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
}
