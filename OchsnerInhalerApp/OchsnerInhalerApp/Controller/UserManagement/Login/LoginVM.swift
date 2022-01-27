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
                    self?.loginModel.Token = response!["Token"] as? String
                    UserDefaultManager.token = self?.loginModel.Token ?? ""
                    UserDefaultManager.isLogin = true
                    completionHandler(.success(true))
                }
               
            }
        }
    }
    
    
    func checkValidation()->Bool {
        var isValid = true
        
         if !(loginModel.email ?? "").isValidEmail {
            CommonFunctions.showMessage(message: StringUserManagement.emailPlaceHolder)
            isValid = false
        }
        else if loginModel.password == "" {
            CommonFunctions.showMessage(message:  StringUserManagement.confirmPasswordPlaceHolder)
            isValid = false
        }
        
        return isValid
    }
    
    
}
