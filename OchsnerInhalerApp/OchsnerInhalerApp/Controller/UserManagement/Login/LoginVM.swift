//
//  LoginVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 25/01/22.
//

import Foundation

class LoginVM {
    
    var loginModel = UserModel()
    
    func apiLogin(completionHandler: @escaping ((APIResult) -> Void)) {
        
        if checkValidation() {
            
            APIManager.shared.performRequest(route: APIRouter.login.path, parameters: loginModel.toDicForLogin(), method: .get, isBasicAuth: true) { [weak self] error, response in
                guard let `self` = self else { return }
                if response == nil {
                    completionHandler(.failure(error!.message))
                } else {
                    if let res =  response as? [String: Any] {
                        self.loginModel.token = res["Token"] as? String
                        UserDefaultManager.token = self.loginModel.token ?? ""
                        UserDefaultManager.email = self.loginModel.email!
                        UserDefaultManager.isLogin = true
                        completionHandler(.success(true))
                    }
                }
                
            }
        }
    }
    
    func getDeviceList(completionHandler: @escaping ((APIResult) -> Void)) {
        APIManager.shared.performRequest(route: APIRouter.device.path, parameters: [String: Any](), method: .get, isAuth: true, showLoader: false) { error, response in          
            if response == nil {
                completionHandler(.failure(error!.message))
            } else {
                if let res = response as? [[String: Any]] {
                    for obj in res {
                        DatabaseManager.share.saveDevice(object: DeviceModel(jSon: obj))
                    }
                    completionHandler(.success(true))
                } else {
                    completionHandler(.failure(ValidationMsg.CommonError))
                }
            }
        }
        
    }
    
    func checkValidation() -> Bool {
        var isValid = true
        
        if !(loginModel.email?.lowercased() ?? "").isValidEmail {
            CommonFunctions.showMessage(message: ValidationMsg.email)
            isValid = false
        } else if loginModel.password == "" {
            CommonFunctions.showMessage(message: ValidationMsg.password)
            isValid = false
        }
        return isValid
    }
    
    func apiForgotPassword(completionHandler: @escaping ((APIResult) -> Void)) {
        let url = "\(APIRouter.forgote.path)?emailAddress=\(loginModel.email?.lowercased() ?? "")"
        APIManager.shared.performRequest(route: url, parameters: [String: Any](), method: .post, isBasicAuth: true) { [weak self] error, response in
            guard self != nil else { return }
            if response == nil {
                completionHandler(.failure(error!.message))
       
            } else {
                completionHandler(.success(true))
            }
        }
    }
}
