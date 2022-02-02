//
//  MedicationModel.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 31/01/22.
//

import Foundation
import UIKit

// MARK: - MedicationModelElement
class MedicationModelElement: NSObject {
    var medID: Int?
    var medName : String?
    var ndc: String?
    
    override init () {
        
        self.medID = 0
        self.medName = ""
        self.ndc = ""
    }
    
    init(Json:[String:Any]) {
        if let value = Json["MedId"] as? Int {
            self.medID = value
        }
        if let value = Json["MedName"] as? String {
            self.medName = value
        }
        if let value = Json["NDC"] as? String {
            self.ndc = value
        }
    }
    
    
    func toDic() -> [String : Any] {
        var dic = [String : Any]()
        dic["MedId"] = self.medID
        dic["MedName"] = self.medName
        dic["NDC"] = self.ndc
        return dic
    }
}
