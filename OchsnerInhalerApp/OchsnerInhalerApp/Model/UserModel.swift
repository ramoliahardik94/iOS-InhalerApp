//
//  UserModel.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 11/01/22.
//

import UIKit

class UserModel: NSObject {
        var firstName: String?
        var lastName: String?
        var email: String?
        var password: String?
        var confirmPassword: String?
        var token: String?
    
    override init () {
        self.firstName = ""
        self.lastName = ""
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
        self.token = ""
    }
    
    init(jSon: [String: Any]) {
        
        if let value = jSon["FirstName"] as? String {
            self.firstName = value
        }
        if let value = jSon["LastName"] as? String {
            self.lastName = value
        }
        if let value = jSon["Email"] as? String {
            self.email = value
        }
        if let value = jSon["Password"] as? String {
            self.password = value
        }
        if let value = jSon["Token"] as? String {
            self.token = value
        }
    }
    
    func toDic() -> [String: Any] {
        var dic = [String: Any]()
        dic["FirstName"] = self.firstName
        dic["LastName"] = self.lastName
        dic["EmailAddress"] = self.email
        dic["Password"] = self.password
        return dic
    }
    
    func toDicForLogin() -> [String: Any] {
        var dic = [String: Any]()
        dic["Email"] = self.email
        dic["Password"] = self.password
        return dic
    }
}
