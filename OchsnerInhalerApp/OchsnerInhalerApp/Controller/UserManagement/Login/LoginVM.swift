//
//  LoginVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 25/01/22.
//

import Foundation

class LoginVM {
    
    var loginModel = UserModel()
    
    func apiLogin(completionHandler: @escaping ((APIResult) -> Void)){
    
        if checkValidation() {
            
            APIManager.shared.performRequest(route: APIRouter.login.path, parameters: loginModel.toDicForLogin(), method: .get,isBasicAuth: true) { [weak self] error, response in
                if response == nil{
                    completionHandler(.failure(error!.message))
                }
                else {
                    if let res =  response as? [String : Any] {
                    self?.loginModel.Token = res["Token"] as? String
                    UserDefaultManager.token = self?.loginModel.Token ?? ""
                    UserDefaultManager.isLogin = true
                    completionHandler(.success(true))
                    }
                }
               
            }
        }
    }
    
    
    func checkValidation()->Bool {
        var isValid = true
        
         if !(loginModel.email ?? "").isValidEmail {
             CommonFunctions.showMessage(message: ValidationMsg.email)
            isValid = false
        }
        else if loginModel.password == "" {
            CommonFunctions.showMessage(message:  ValidationMsg.password)
            isValid = false
        }
        
        return isValid
    }
    
    
}
