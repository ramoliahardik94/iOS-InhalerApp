//
//  BLEOTAUpgradeVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 06/06/22.
//

import Foundation
class BLEOTAUpgradeVM {

    func apiForErrorLog(param: [String: Any], completionHandler: @escaping ((APIResult) -> Void)) {
        background {
            APIManager.shared.performRequest(route: APIRouter.upgradeerror.path, parameters: param, method: .post, isAuth: true, showLoader: false) { _, response in
                if response == nil {
                    completionHandler(.failure(ValidationMsg.CommonError))
                } else {
                    if (response as? [[String: Any]]) != nil {
                        completionHandler(.success(true))
                    } else {
                        completionHandler(.failure(ValidationMsg.CommonError))
                    }
                }
            }
        }
    }
}
