//
//  HomeVM.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 21/02/22.
//

import Foundation

class HomeVM {
    var dashboardData =  [MaintenanceModel]()
     
    func apiDashboardData(completionHandler: @escaping ((APIResult) -> Void)) {
        
        APIManager.shared.performRequest(route: APIRouter.dashboard.path, parameters: [String: Any](), method: .get, isAuth: true, showLoader: false, isCommonMsg: true) { [weak self] error, response in
            guard let `self` = self else { return }
            if response == nil {
                completionHandler(.failure(error!.message))
            } else {
                self.dashboardData = [MaintenanceModel]()
                if let res = response as? [String: Any] {
                    let mainData = DashboardModel(jSon: res)
                    if mainData.rescueData.count != 0 {
                        self.dashboardData.append(contentsOf: mainData.rescueData)
                    }
                    if  mainData.maintenanceData.count != 0 {
                        self.dashboardData.append(contentsOf: mainData.maintenanceData)
                    }
                    completionHandler(.success(true))
                } else {
                    completionHandler(.failure(ValidationMsg.CommonError))
                }
            }
        }
    }
    
}
