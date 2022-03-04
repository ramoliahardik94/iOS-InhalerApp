//
//  CreateAccountVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 25/01/22.
//

import Foundation

class CreateAccountVM {
    
    var userData = UserModel(jSon: [String: Any]())
    var isPrivacy = false
    func apiCreateAccount(completionHandler: @escaping ((APIResult) -> Void)) {
        UserDefaultManager.remove(forKey: .grantBLEPermission)
        UserDefaultManager.remove(forKey: .grantLocationPermission)
        UserDefaultManager.remove(forKey: .grantNotificationPermission)
        if checkValidation() {
            APIManager.shared.performRequest(route: APIRouter.createAccount.path, parameters: userData.toDic(), method: .post) { [weak self] error, response in
                if response == nil {
                    completionHandler(.failure(error!.message))
                } else {
                    if let res =  response as? [String: Any] {
                        self?.userData.token = res["Token"] as? String
                        UserDefaultManager.token = self?.userData.token ?? ""
                        UserDefaultManager.isLogin = true
                        completionHandler(.success(true))
                    }
                }
            }
        }
    }
    
    
    func checkValidation() -> Bool {
        var isValid = true
        
        if userData.firstName?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            CommonFunctions.showMessage(message: ValidationMsg.fName)
            isValid = false
        } else if userData.lastName?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            CommonFunctions.showMessage(message: ValidationMsg.lName)
            isValid = false
        } else if !(userData.email ?? "").isValidEmail {
            CommonFunctions.showMessage(message: ValidationMsg.email)
            isValid = false
        } else if userData.password?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            CommonFunctions.showMessage(message: ValidationMsg.password)
            isValid = false
        } else if userData.confirmPassword?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            CommonFunctions.showMessage(message: ValidationMsg.confirmPassword)
            isValid = false
        } else if  userData.confirmPassword != userData.password {
            CommonFunctions.showMessage(message: ValidationMsg.matchPass)
            isValid = false
        } else if !isPrivacy {
            CommonFunctions.showMessage(message: ValidationMsg.privacyPolicy)
            isValid = false
        }
        
        return isValid
    }
    
    
}
