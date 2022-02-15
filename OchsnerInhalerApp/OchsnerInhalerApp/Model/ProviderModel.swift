//
//  ProviderModel.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/02/22.
//

import Foundation

class ProviderModel: NSObject {
    var entryId : Int?//": 1,
    var entryName : String?//": "Ochsner Health",
    var OAuthUrl : String?//": "irect_uri=https%3a%2f%2flocalhost%3a44340%2foauth%2fcallback",
    var fhirUrl : String?//": null,
    var iconFilename : String?//": "Ochsner.png",
    var rescueFlo : Int?//": 0,
    var maintenanceFlo : Int?//": 0,
    var adherenceFlo : String?//": null,
    var state : String?//": "Louisiana",
    var clientSecret : String?//": null,
           // "User": []
 
    
    init(jSon: [String: Any]) {
        if let value = jSon["EntryId"] as? Int {
            self.entryId = value
        }
        
        if let value = jSon["EntryName"] as? String {
            self.entryName = value
        }
        if let value = jSon["OAuthUrl"] as? String {
            self.OAuthUrl = value
        }
        if let value = jSon["FhirUrl"] as? String {
            self.fhirUrl = value
        }
        if let value = jSon["IconFilename"] as? String {
            self.iconFilename = value
        }
        if let value = jSon["RescueFlo"] as? Int {
            self.rescueFlo = value
        }
        if let value = jSon["MaintenanceFlo"] as? Int {
            self.maintenanceFlo = value
        }
        if let value = jSon["AdherenceFlo"] as? String {
            self.adherenceFlo = value
        }
        if let value = jSon["State"] as? String {
            self.state = value
        }
    }
    
}
