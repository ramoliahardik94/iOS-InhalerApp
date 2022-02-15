//
//  ManageDeviceVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 15/02/22.
//

import Foundation

class ManageDeviceVM {
    var arrDevice = [DeviceModel]()
    
    func apicallForGetDeviceList(completionHandler: @escaping ((APIResult) -> Void))  {
        APIManager.shared.performRequest(route: APIRouter.device.path, parameters: [String: Any](), method: .get, isAuth: true) {[weak self] error, response in
            guard let `self` = self else { return }
            if response == nil {
                completionHandler(.failure(error!.message))
            } else {
                if let res = response as? [[String: Any]] {
                    self.arrDevice.removeAll()
                    for obj in res {
                        self.arrDevice.append(DeviceModel(jSon: obj))
                    }
                    completionHandler(.success(true))
                } else {
                    completionHandler(.failure(ValidationMsg.CommonError))
                }
            }
        }
    }
}
