//
//  LoginModel.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 25/01/22.
//

import Foundation

class LoginModel: Codable {
        
        var email : String?
        var password : String?
        
    
    func toDic() -> [String : Any] {
        var dic = [String : Any]()
        dic["Email"] = self.email
        dic["Password"] = self.password
        return dic
    }
}
