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
    
    // MARK: - Alert
    
    public class func showMessage(message: String, titleOk: String = "Ok", _ completion: @escaping ((Bool?) -> Void ) = {_ in }) { 
        let alert = UIAlertController(title: (""), message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: titleOk, style: .default, handler: {_ in
            completion(true)
        }))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    public class func getLogFromDeviceAndSync() {
        let bleDevice = BLEHelper.shared.connectedPeripheral.filter({$0.discoveredPeripheral?.state == .connected})
        if bleDevice.count > 0 {
            for  discoverPeripheral in bleDevice {
                    BLEHelper.shared.getActuationNumber(peripheral: discoverPeripheral)
            }
        } else {
            Logger.logInfo("deviceuse: getLogFromDeviceAndSync ")
            BLEHelper.shared.apiCallForActuationlog()
        }
    }

    // MARK: - Alert
    public class func showMessageYesNo(message: String, cancelTitle: String = "Cancel", okTitle: String = "Ok", _ completion: @escaping ((Bool) -> Void ) = { _ in  }) {
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
                openBluetooth()
            } else {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            
        }))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Show Progress HUD
    
    class func showGlobalProgressHUD(_ viewcontroller: UIViewController, text: String = "") {
        DispatchQueue.main.async {
            let loadingNotification = MBProgressHUD.showAdded(to: viewcontroller.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = text
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
    
        
        func redirectBluetoothAppSetting() {
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

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
