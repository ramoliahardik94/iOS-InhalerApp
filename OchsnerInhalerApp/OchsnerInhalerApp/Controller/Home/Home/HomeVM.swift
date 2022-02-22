//
//  HomeVM.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 21/02/22.
//

import Foundation

class HomeVM {
    var dashboardData =  [MaintenanceModel]()
     
    func doDashboardData(completionHandler: @escaping ((APIResult) -> Void)) {
        
        APIManager.shared.performRequest(route: APIRouter.dashboard.path, parameters: [String: Any](), method: .get, isAuth: true, showLoader: false) { error, response in
            if response == nil {
                
                completionHandler(.failure(error!.message))
            } else {
                if let res = response as? [String: Any] {
                     let mainData = DashboardModel(jSon: res)
                    print(" main data \(mainData.maintenanceData.count)" )
                    if  mainData.maintenanceData.count != 0 {
                        self.dashboardData.append(contentsOf: mainData.maintenanceData)
                    }
                    if mainData.rescueData.count != 0 {
                        self.dashboardData.append(contentsOf: mainData.rescueData)
                    }
                    completionHandler(.success(true))
                } else {
                    completionHandler(.failure(ValidationMsg.CommonError))
                }
            }
        }
    }
    
}
