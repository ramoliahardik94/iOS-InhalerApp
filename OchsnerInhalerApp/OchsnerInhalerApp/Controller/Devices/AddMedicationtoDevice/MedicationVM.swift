//
//  MedicationVM.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 31/01/22.
//

import Foundation

class MedicationVM {
    var medication = [MedicationModelElement]()
    var selectedMedication: MedicationModelElement!
    var macAddress = "N/A"
    var medTypeId = 2
    var puff = 0
    var totalDose = 0
    var arrTime: [String] = [String]()
    var isEdit = false
    func apiGetMedicationLis(completionHandler: @escaping ((APIResult) -> Void)) {
        
        APIManager.shared.performRequest(route: APIRouter.medication.path, parameters: [String: Any](), method: .get) { error, response in
            if response == nil {
                
                completionHandler(.failure(error!.message))
            } else {
                if let res = response as? [[String: Any]] {
                    self.medication.removeAll()
                    for obj in res {
                        self.medication.append(MedicationModelElement(jSon: obj))
                    }
                    completionHandler(.success(true))
                } else {
                    completionHandler(.failure(ValidationMsg.CommonError))
                }
            }
        }
    }
    
    func apiAddDevice(completionHandler: @escaping ((APIResult) -> Void)) {
        if macAddress != "N/A" {
            var str = ""
            if arrTime.count != 0 {
               str = arrTime.joined(separator: ",")
            }
            let dic: [String: Any] = [
                "InternalId": macAddress,
                "MedId": selectedMedication.medID!,
                "MedTypeId": medTypeId,
                "Puffs": puff,
                "DailyUsage": totalDose, 
                "UseTimes": str
            ]
            APIManager.shared.performRequest(route: APIRouter.device.path, parameters: dic, method: .post, isAuth: true) { error, response in
                if response == nil {
                    completionHandler(.failure(error!.message))
                } else {
                    if (response as? [String: Any]) != nil {
                        completionHandler(.success(true))
                    } else {
                        completionHandler(.failure(ValidationMsg.CommonError))
                    }
                }
            }
        }
        
    }
}
