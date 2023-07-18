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
        if BLEHelper.shared.logCounter == 0 {
            if bleDevice.count > 0 {
                for  discoverPeripheral in bleDevice {
                    BLEHelper.shared.getActuationNumber(peripheral: discoverPeripheral)
                }
            } else {
                Logger.logInfo("deviceuse: getLogFromDeviceAndSync ")
                BLEHelper.shared.apiCallForActuationlog()
            }
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .DataSyncDone, object: nil)
            }
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
    
    
    public class func upgradeApp(appVersionOnCloud: String) {
        DispatchQueue.main.async {
            switch UIApplication.shared.applicationState {
            case .active:
                // app is currently active, can update badges count here
                CommonFunctions.alertAppVersion()
                
            case .inactive:
                // app is transitioning from background to foreground (user taps notification), do what you need when user taps here
                // setNotificationAppUpdate(version: appVersionOnCloud)
                break
                
            case .background:
                // app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
                // setNotificationAppUpdate(version: appVersionOnCloud)
                break
                
            default:
                break
            }
        }
    }
    
    // MARK: Version Popup
    public class func alertAppVersion() {
        if !Constants.isSkipAppUpdate  {
        if !isAlertVersionDisplay {
            isAlertVersionDisplay = true
            let isCustomSplash = UIApplication.topViewController() is CustomSplashVC
            delay(isCustomSplash ? 5 : 0) {
                CommonFunctions.showMessageYesNo(message: StringLocalNotifiaction.bodyAppVersion, cancelTitle: StringAddDevice.laterbtn, okTitle: StringAddDevice.continuebtn) { isUpgrade in
                    if isUpgrade {
                        let arrConnected = BLEHelper.shared.connectedPeripheral.filter({$0.discoveredPeripheral?.state == .connected})
                        for obj in arrConnected {
                            BLEHelper.shared.cleanup(peripheral: obj.discoveredPeripheral!)
                        }
                        if let url = URL(string: Constants.appUrl) {
                            DispatchQueue.main.async() {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(url)
                                } else {
                                    UIApplication.shared.openURL(url)
                                }
                            }
                        }
                    }
                    Constants.isSkipAppUpdate = true
                    isAlertVersionDisplay = false
                }
            }
          }
        }
    }
    public class func checkVersion() {
        if (UIApplication.topViewController() != nil) && !(UIApplication.topViewController()! is OTAUpgradeDetailsVC) &&  !(UIApplication.topViewController()! is BLEOTAUpgradeVC) && !(UIApplication.topViewController()! is AddDeviceIntroVC) {
            apiCallAppVersion(isUpgradeAppVersion: { isUpgradeApp, version in
                if isUpgradeApp {
                    
                    CommonFunctions.upgradeApp(appVersionOnCloud: version)
                } else {
                    if UserDefaultManager.isLogin {
                        CommonFunctions.checkFWVersionDetails()
                    }
                }
            })
        }
    }
    
    public class func apiCallAppVersion(isUpgradeAppVersion: @escaping ((Bool, String) -> Void)) {
        background {
            APIManager.shared.performRequest(route: APIRouter.appVersion.path, parameters: [String: Any](), method: .get, showLoader: false) { _, response in
                if response != nil {
                    if let res = response as? [String: Any] {
                        if let appVersionOnCloud = res["appVersion_iOS"] as? String {
                            //                        if let isFouceUpdate =  res["isForceUpdate_iOS"] as? Bool {
                            if appVersionOnCloud != appVersion() {
                                isUpgradeAppVersion(true, appVersionOnCloud)
                            } else {
                                isUpgradeAppVersion(false, appVersion())
                            }
                        } else {
                            isUpgradeAppVersion(false, appVersion())
                        }
                    } else {
                        isUpgradeAppVersion(false, appVersion())
                    }
                } else {
                    isUpgradeAppVersion(false, appVersion())
                }
            }
        }
    }
    
    // MARK: Version Popup
    public class func checkFWVersionDetails() {
        if !Constants.isDisplay {
            // Permition is Granted
            if UserDefaultManager.isGrantBLE  && UserDefaultManager.isGrantLaocation  && UserDefaultManager.isGrantNotification {
                
                // Not in specific screens
                if (UIApplication.topViewController() != nil) && !(UIApplication.topViewController()! is OTAUpgradeDetailsVC) && !(UIApplication.topViewController()! is CustomSplashVC) && !(UIApplication.topViewController()! is BLEOTAUpgradeVC) && !(UIApplication.topViewController()! is AddDeviceIntroVC) {
                    
                    // missmatche version list in db
                    let deviceMissMatch = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email).filter({$0.version != Constants.AppContainsFirmwareVersion && $0.udid != ""})
                    var showAlert = false
                    var index = 0
                    
                    if deviceMissMatch.count > 0 {
                        repeat {
                            showAlert = BLEHelper.shared.connectedPeripheral.contains(where: {$0.addressMAC == deviceMissMatch[index].mac && $0.discoveredPeripheral?.state == .connected})
                            
                            if showAlert {
                                index = 0
                                break
                            } else {
                                index += 1
                            }
                        } while (index == (deviceMissMatch.count - 1))
                        
                        if showAlert {
                            
                            if !isAlertVersionDisplay {
                                isAlertVersionDisplay = true
                                CommonFunctions.showMessageYesNo(message: OTAMessages.AlertUpgrade, cancelTitle: StringAddDevice.laterbtn, okTitle: StringAddDevice.continuebtn) { isUpgrade in
                                    if isUpgrade {
                                        let bleUpgrade = OTAUpgradeDetailsVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                                        BaseVC().rootVC(controller: bleUpgrade)
                                    }
                                    isAlertVersionDisplay = false
                                    Constants.isDisplay = true
                                }
                            }
                        }
                    }
                }
            }
        }
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
    
    public class func setNotificationAppUpdate(version: String) {
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        content.title = StringLocalNotifiaction.title
        content.body =  String(format: StringLocalNotifiaction.bodyAppVersion)
        content.sound = UNNotificationSound.default
        content.userInfo = ["appversion": true]
        let request = UNNotificationRequest(identifier: "AppUpgration", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
            if let error = error {
                print("SOMETHING WENT WRONG\(error.localizedDescription))")
            }
        })
        Logger.logInfo(" setNotification End")
    }
    
    // MARK: - Show Progress HUD
    
    class func showGlobalProgressHUD(_ viewcontroller: UIViewController, text: String = "", isMsg: Bool = false) {
        DispatchQueue.main.async {
            let loadingNotification = MBProgressHUD.showAdded(to: viewcontroller.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = text
            if isMsg {
                delay(1.2) {
                    hideGlobalProgressHUD(viewcontroller)
                }
            }
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
