//
//  UserDefaultManager.swift
//

import UIKit

enum UserDefaultKey: String {

    case latitude
    case longitude
    case token
    case isLogin
   
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
