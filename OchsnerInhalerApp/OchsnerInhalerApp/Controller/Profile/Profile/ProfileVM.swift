//
//  ProfileVM.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 28/02/22.
//

import Foundation

class ProfileVM {
    var userData = ProfileModel()
    func doGetProfile(completionHandler: @escaping ((APIResult) -> Void)) {
        APIManager.shared.performRequest(route: APIRouter.user.path, parameters: [String: Any](), method: .get, isAuth: true, showLoader: false) { error, response in
            if response == nil {
                completionHandler(.failure(error!.message))
            } else {
                if let res = response as? [String: Any] {
                    self.userData = ProfileModel(jSon: res)
                    completionHandler(.success(true))
                } else {
                    completionHandler(.failure(ValidationMsg.CommonError))
                }
            }
        }
    }
}
