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
}
