//
//  ProviderListVM.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/02/22.
//

import Foundation

class ProviderListVM {
    var providerList = [ProviderModel]()
    
    func doGetProviderList(completionHandler: @escaping ((APIResult) -> Void)) {
        
        APIManager.shared.performRequest(route: APIRouter.providerList.path, parameters: [String: Any](), method: .get) { error, response in
            if response == nil {
                
                completionHandler(.failure(error!.message))
            } else {
                if let res = response as? [[String: Any]] {
                    self.providerList.removeAll()
                    for obj in res {
                        self.providerList.append(ProviderModel(jSon: obj))
                    }
                    completionHandler(.success(true))
                } else {
                    completionHandler(.failure(ValidationMsg.CommonError))
                }
            }
        }
    }
}
