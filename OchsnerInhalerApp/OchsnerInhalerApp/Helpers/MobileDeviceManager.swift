//
//  MobileDeviceManager.swift

import Foundation
import KeychainSwift
import UIKit


class MobileDeviceManager: NSObject {
    static let shared = MobileDeviceManager()
    var udid: String = ""
    var name: String = UIDevice.modelName

    func setupUDID() {
        
        let keychain = KeychainSwift()
        
        guard let oldUDID = keychain.get("udid") else {
            //udid not found in keychain so save this udid in keychain
            let udid = UIDevice.current.identifierForVendor!.uuidString
            keychain.set(udid, forKey: "udid")
            self.udid = udid
            return
        }
        self.udid = oldUDID
    }
    
}
