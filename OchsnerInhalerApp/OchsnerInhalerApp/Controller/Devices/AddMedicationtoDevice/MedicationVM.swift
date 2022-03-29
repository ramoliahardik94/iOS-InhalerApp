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
    var medTypeId = 1
    var puff = 1
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
    
    func apiAddDevice(isreminder: Bool, completionHandler: @escaping ((APIResult) -> Void)) {
        totalDose = arrTime.count
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
            APIManager.shared.performRequest(route: APIRouter.device.path, parameters: dic, method: .post, isAuth: true) { [weak self] error, response in
                guard let `self` = self else { return }
                if response == nil {
                    completionHandler(.failure(error!.message))
                } else {
                    if (response as? [String: Any]) != nil {
                        let device = DeviceModel()
                        device.internalID = BLEHelper.shared.addressMAC
                        device.udid = BLEHelper.shared.discoveredPeripheral?.identifier.uuidString ?? ""
                        device.isReminder = isreminder
                        device.medTypeID = self.medTypeId
                        DatabaseManager.share.saveDevice(object: device,isFromDirection: true)
                        NotificationCenter.default.post(name: .medUpdate, object: nil)
                        BLEHelper.shared.isAddAnother = false
                        completionHandler(.success(true))
                        
                    } else {
                        completionHandler(.failure(ValidationMsg.CommonError))
                    }
                }
            }
        }
        
    }
}
