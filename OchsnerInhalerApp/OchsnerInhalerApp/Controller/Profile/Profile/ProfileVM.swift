//
//  ProfileVM.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 28/02/22.
//

import Foundation
import UIKit
import EventKit
class ProfileVM {
    var userData = ProfileModel()
    var store = EKEventStore()
    
    func apiGetProfile(completionHandler: @escaping ((APIResult) -> Void)) {
        APIManager.shared.performRequest(route: APIRouter.user.path, parameters: [String: Any](), method: .get, isAuth: true, showLoader: false) { error, response in
            if response == nil {
                completionHandler(.failure(error!.message))
            } else {
                if let res = response as? [String: Any] {
                    self.userData = ProfileModel(jSon: res)
                    UserDefaultManager.username = self.userData.user?.firstName ?? ""
                    completionHandler(.success(true))
                } else {
                    completionHandler(.failure(ValidationMsg.CommonError))
                }
            }
        }
    }
    
    func getAllCalenderEvent() {
        let calendars = store.calendars(for: .event)
            
        for calendar in calendars {
            let predicate =  store.predicateForEvents(withStart: Date(), end: Date().addingTimeInterval(525600), calendars: [calendar])
            let events = store.events(matching: predicate)
            print("events  = \(events)")
            
        }
    }

    func removeProvider(url: String, completionHandler: @escaping ((APIResult) -> Void)) {
        APIManager.shared.performRequest(route: url, parameters: [:], method: .delete, isAuth: true) { error, response in
          
            if response == nil {
                completionHandler(.failure(error!.message))
            } else {
                // if let res =  response as? [String: Any] {
                completionHandler(.success(true))
                // }
            }
        }
    }
}
