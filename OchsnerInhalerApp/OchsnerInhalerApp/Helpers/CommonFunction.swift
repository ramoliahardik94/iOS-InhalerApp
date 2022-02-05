//
//  File.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 25/01/22.
//

import UIKit
import Photos
import MBProgressHUD


open class CommonFunctions {
    
    // MARK: -  Alert
    
    public class func showMessage(message: String, _ completion: @escaping ((Bool?) -> Void ) = {_ in }) {
        let alert = UIAlertController(title: (""), message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {_ in
            completion(true)
        }))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }

    // MARK: - Alert
    public class func showMessageYesNo(message: String, cancelTitle: String = "Cancel", okTitle: String = "Ok", _ completion: @escaping ((Bool?) -> Void ) = { _ in  }) {
        let alert = UIAlertController(title: (message), message: "", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: {_ in
            completion(false)
        }))
        
        alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: {_ in
            completion(true)
        }))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Alert Permission
    
    public class func showMessagePermission(message: String, cancelTitle: String = "Cancel", okTitle: String = "Ok", isOpenBluetooth: Bool, _ completion: @escaping ((Bool?) -> Void ) = { _ in }) {
        let alert = UIAlertController(title: (message), message: "", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: {_ in
            completion(false)
        }))
        
        alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: {_ in
            completion(true)
            if isOpenBluetooth {
                let url = URL(string: "App-Prefs:root=General")
                UIApplication.shared.open(url!)
            } else {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            
        }))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Show Progress HUD
    
    class func showGlobalProgressHUD(_ viewcontroller: UIViewController) {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: viewcontroller.view, animated: true)
        }
    }
    class func hideGlobalProgressHUD(_ viewcontroller: UIViewController) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: viewcontroller.view, animated: true)
        }
    }

    class func openBluetooth() {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            let app = UIApplication.shared
            app.open(url)
        }
}

extension TimeZone {

    func offsetFromUTC() -> Int {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.timeZone = self
        localTimeZoneFormatter.dateFormat = "Z"
        return Int(localTimeZoneFormatter.string(from: Date())) ?? 0
    }
}
