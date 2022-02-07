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
    var medName: String?
    var ndc: String?
    var isSelected: Bool = false
    override init () {
        
        self.medID = 0
        self.medName = ""
        self.ndc = ""
    }
    
    init(jSon: [String: Any]) {
        if let value = jSon["MedId"] as? Int {
            self.medID = value
        }
        if let value = jSon["MedName"] as? String {
            self.medName = value
        }
        if let value = jSon["NDC"] as? String {
            self.ndc = value
        }
    }
    
    
    func toDic() -> [String: Any] {
        var dic = [String: Any]()
        dic["MedId"] = self.medID
        dic["MedName"] = self.medName
        dic["NDC"] = self.ndc
        return dic
    }
}
