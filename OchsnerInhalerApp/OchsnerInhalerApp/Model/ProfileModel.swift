//
//  ProfileModel.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 28/02/22.
//

import Foundation

class ProfileModel: NSObject {
    var token: String? // ": "Token",
    var user: ProfileUserModel? // ": "Token",
    override init() {
        
    }
    init(jSon: [String: Any]) {
        if let value = jSon["Token"] as? String {
            self.token = value
        }
        if let value = jSon["User"] as? [String: Any] {
            self.user = ProfileUserModel(jSon: value)
        }
    }
}

class ProfileUserModel: NSObject {
    var userId: Int? // ": 2,
    var firstName: String? // ": "Matthew",
    var lastName: String? // ": "Herzog",
    var emailAddress: String? // ": "mherzog@ochsner.org",
    var password: String? // ": null,
    var resetCode: String? // ": null,
    var providerId: Int? // ": null,
    var providerName: String? // ": null
    
    init(jSon: [String: Any]) {
        if let value = jSon["UserId"] as? Int {
            self.userId = value
        }
        
        if let value = jSon["FirstName"] as? String {
            self.firstName = value
        }
        if let value = jSon["LastName"] as? String {
            self.lastName = value
        }
        if let value = jSon["EmailAddress"] as? String {
            self.emailAddress = value
        }
        if let value = jSon["Password"] as? String {
            self.password = value
        }
        if let value = jSon["ResetCode"] as? String {
            self.resetCode = value
        }
        if let value = jSon["ProviderId"] as? Int {
            self.providerId = value
        }
        if let value = jSon["ProviderName"] as? String {
            self.providerName = value
        }
    }
    
}
