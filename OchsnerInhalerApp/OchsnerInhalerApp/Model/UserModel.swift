//
//  UserModel.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 11/01/22.
//

import UIKit

class UserModel: NSObject {
        var firstName : String?
        var lastName : String?
        var email : String?
        var password : String?
        var confirmPassword : String?
        var Token : String?
    
    override init (){
        self.firstName = ""
        self.lastName = ""
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
        self.Token = ""
    }
    
    init(Json: [String:Any]) {
        
        if let value = Json["FirstName"] as? String {
            self.firstName = value
        }
        if let value = Json["LastName"] as? String {
            self.lastName = value
        }
        if let value = Json["Email"] as? String {
            self.email = value
        }
        if let value = Json["Password"] as? String {
            self.password = value
        }
        if let value = Json["Token"] as? String {
            self.Token = value
        }
    }
    
    func toDic() -> [String : Any] {
        var dic = [String : Any]()
        dic["FirstName"] = self.firstName
        dic["LastName"] = self.lastName
        dic["Email"] = self.email
        dic["Password"] = self.password
        return dic
    }
    
    func toDicForLogin()->[String:Any] {
        var dic = [String : Any]()
        dic["Email"] = self.email
        dic["Password"] = self.password
        return dic
    }
}
