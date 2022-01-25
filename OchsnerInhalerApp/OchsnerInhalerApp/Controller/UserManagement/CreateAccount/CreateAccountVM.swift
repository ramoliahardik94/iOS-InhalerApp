//
//  CreateAccountVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 25/01/22.
//

import Foundation

class CreateAccountVM {
    
    var userData = UserModel()
    
    func apiCreateAccount(completionHandler: @escaping ((APIResult) -> Void)){
    
        if checkValidation() {
            
            APIManager.shared.performRequest(route: APIRouter.createAccount.path, parameters: userData.toDic(), method: .post) { error, response in
                print(response)
                completionHandler(.success(true))
            }
        }
    }
    
    
    func checkValidation()->Bool {
        var isValid = true
        
        if userData.firstName == "" {
            CommonFunctions.showMessage(message:  StringUserManagement.placeHolderFirstName)
            isValid = false
        }
        
        else if userData.lastName == "" {
            CommonFunctions.showMessage(message: StringUserManagement.placeHolderLastName)
            isValid = false
        }
        
        else if !(userData.email ?? "").isValidEmail {
            CommonFunctions.showMessage(message: StringUserManagement.emailPlaceHolder)
            isValid = false
        }
        else if userData.confirmPassword == "" {
            CommonFunctions.showMessage(message:  StringUserManagement.confirmPasswordPlaceHolder)
            isValid = false
        }
        
        else if  userData.confirmPassword != userData.password  {
            CommonFunctions.showMessage(message:  "Confirm password doesn't match")
            isValid = false
        }
        return isValid
    }
    
    
}
