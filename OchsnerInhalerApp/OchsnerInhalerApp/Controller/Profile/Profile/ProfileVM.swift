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
    
    func getAllCalenderEvent() {
        let calendars = store.calendars(for: .event)
            
        for calendar in calendars {
            let predicate =  store.predicateForEvents(withStart: Date(), end: Date().addingTimeInterval(525600), calendars: [calendar])
            let events = store.events(matching: predicate)
            print("events  = \(events)")
            
        }
        
    }
     func setAlarm(isOn: Bool = false) {
        let appDelegate = UIApplication.shared.delegate
        as! AppDelegate
        if let appleEventStore = appDelegate.eventStore {
            let cal = appleEventStore.calendars(for: .event)
            for calendar in cal {
                let predicate =  appleEventStore.predicateForEvents(withStart: Date(), end: Date().addingTimeInterval(315360000), calendars: [calendar])
                let events = appleEventStore.events(matching: predicate)
                
                for event in events {
                    if event.title.contains("Your Next Dose is on"){
                        if !isOn {
                            event.alarms = []
                        } else {
                            let subString = event.title.replacingOccurrences(of: "Your Next Dose is on", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                            
                        
                            
                            print("titile \(event.title)")
                            print("subString \(subString)")
                            if event.alarms?.count == 0 {
                                print("event date \( event.startDate)")
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "hh:mm a"
                                let today = event.startDate
                                dateFormatter.dateFormat = "dd/MM/yyyy"
                                let strDate = "\(dateFormatter.string(from: today ?? Date()))"
                                
                                print("strDate \(strDate)")
//                                dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
//                                if let date = dateFormatter.date(from: strDate) {
//                                    print("formted date \(date)")
//                                }
                                
                            }
                        }
                        //  try   appleEventStore.remove(event., span: .thisEvent)
                        
                    }
                    
                }
            }
        }
    }
}
