//
//  NotificationManager.swift

import Foundation
import UIKit
import UserNotifications
import ObjectMapper

class NotificationManager: NSObject {
    // MARK: Properties
    static let shared = NotificationManager()
    
    var notifications: [UNNotification] = []
    
    var statusReceived: ((UNAuthorizationStatus) -> Void)?
    
    // MARK: APNS Notification Handlers
    func register() {
        UNUserNotificationCenter.current().delegate = self
        // Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print("NotificationManager > register > registered for remote notification > Granted > \(granted) > Error > \(String(describing: error?.localizedDescription))")
            foreground {
                if !granted {
                    self.statusReceived?(.notDetermined)
                } else {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func unregister() {
        print("NotificationManager > unregister > unregistered for remote notification")
        UserDefaultManager.deviceToken = ""
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    func isAllowed(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }
    
    func checkPushNotificationSettings(_ askPermission: Bool = false) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            foreground {
                switch settings.authorizationStatus {
                case .notDetermined:
                    if askPermission {
                        self.register()
                    } else {
                        self.statusReceived?(.notDetermined)
                    }
                case .authorized:
                    UIApplication.shared.registerForRemoteNotifications()
                default:
                    self.statusReceived?(.denied)
                }
            }
        })
    }
    
    func askUserPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            foreground {
                completion(true)
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // for add local notificaion reminders
    func setNotification(date: Date, titile: String, calendar: Calendar, macAddress: String, isFromTomorrow: Bool = false, dose: String) {
        Logger.logInfo("Set Reminder For Time : \(date)")
        let content = UNMutableNotificationContent()
        content.title = StringAddDevice.titleAddDevice
        content.body =  titile
        content.sound = UNNotificationSound.default
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "com.ochsner.inhalertrack.reminderdose\(macAddress).\(dose)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
            
            if let error = error {
                Logger.logInfo("SOMETHING WENT WRONG Notification\(error.localizedDescription))")
            } else {
                Logger.logInfo("Notification set for \(components)")
                Logger.logInfo("\(StringAddDevice.titleAddDevice)")
                Logger.logInfo("\(titile)")
            }
        })
    }
    
    func twomorowTimeInterval(dose: String, calender: Calendar) -> TimeInterval {
        Logger.logInfo("Notification set for: From twomotow")
        var fromDate = Date().getString(format: "dd-MM-yyyy", isUTC: false)
        fromDate = "\(fromDate) \(dose)"
        let toDay = fromDate.getDate(format: "dd-MM-yyyy hh:mm a").addingTimeInterval(30*60)
        let twomorrow = calender.date(byAdding: .day, value: 1, to: toDay)
        return twomorrow!.timeIntervalSince(Date())
    }
    
    // For Remove All local notification
    func removeAllPendingLocalNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    // add notification from local database
    func addReminderLocal(userName: String) {
        if UserDefaultManager.isNotificationOn {
            let arrDevice = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
            let arrScedule = arrDevice.filter({$0.scheduledoses != nil && $0.scheduledoses != ""})
            for objDevice in arrScedule {
                Logger.logInfo("main device Obj \(objDevice.mac ?? "Blank")  ) == >> \(objDevice.scheduledoses ?? "") ")
                if objDevice.reminder {
                    clearDeviceRemindersNotification(macAddress: objDevice.mac ?? "")
                    let arrDose = objDevice.scheduledoses?.components(separatedBy: ",")
                    
                    for item in arrDose ?? [] {
                        Logger.logInfo("sub array dose time device Obj \(item)")
                        var graterDate =  item.getDate(format: DateFormate.doseTime)
                        let strgraterDate = graterDate.getString(format: DateFormate.doseTime12Hr)
                        graterDate =  strgraterDate.getDate(format: DateFormate.doseTime12Hr)
                        //  let showDoesTime  = self.medicationVM.arrTime.last ?? ""
                        var calendar = Calendar(identifier: .gregorian)
                        calendar.timeZone = .current
                        let datesub = calendar.date(byAdding: .minute, value: 30, to: graterDate)
                        let title = String(format: StringLocalNotifiaction.reminderBody, userName .trimmingCharacters(in: .whitespacesAndNewlines), objDevice.medname ?? "", item )
                        setNotification(date: datesub ?? Date().addingTimeInterval(1800), titile: title, calendar: calendar, macAddress: objDevice.mac ?? "", dose: item)
                    }
                }
            }
        }
    }
    
    func clearDeviceRemindersNotification(macAddress: String) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            let filterArray = requests.map({ (item) -> String in item.identifier })
            let commonArray = filterArray.filter { item in
                return item.lowercased().contains(macAddress.lowercased())
            }
            print("filter Arrya \(filterArray)")
            // Logger.logInfo(" Filter notification \(commonArray)")
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: commonArray)
            Logger.logInfo(" Remove notification \(commonArray)")
            
        })
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound, .alert])
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        if let version = userInfo["version"] {
            if version as! Bool {
                // Move to Vesion UPDATE Screen
                print("Move to Vesion UPDATE Screen")
                let bleUpgrade = OTAUpgradeDetailsVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                BaseVC().rootVC(controller: bleUpgrade)
            }
        } else if let appVersion = userInfo["appversion"] {
            if appVersion as! Bool {
                //  Move to Vesion UPDATE Screen
                if let url = URL(string: Constants.appUrl) {
                    UIApplication.shared.open(url)
                }
            }
        }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications() // clear all the notification from notification center
        if UserDefaultManager.isNotificationOn {
            unregister()
        }
        completionHandler()
    }
}

extension NotificationManager {
    
    func showAlert(title: String, message: String) {
        if UIApplication.topViewController()!.isKind(of: UIAlertController.self) {
            UIApplication.topViewController()!.dismiss(animated: false) {
                UIApplication.topViewController()?.presentAlert(withTitle: title, message: message)
            }
        } else {
            UIApplication.topViewController()?.presentAlert(withTitle: title, message: message)
        }
    }
}
