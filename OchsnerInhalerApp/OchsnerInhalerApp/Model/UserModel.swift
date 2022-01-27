//
//  UserModel.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 11/01/22.
//

import UIKit

class UserModel: Codable {
        var firstName : String?
        var lastName : String?
        var email : String?
        var password : String?
        var confirmPassword : String?
    
    func toDic() -> [String : Any] {
        var dic = [String : Any]()
        dic["FirstName"] = self.firstName
        dic["LastName"] = self.lastName
        dic["Email"] = self.email
        dic["Password"] = self.password
        return dic
    }
}
