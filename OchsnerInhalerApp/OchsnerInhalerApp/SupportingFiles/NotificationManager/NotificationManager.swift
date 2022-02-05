//
//  NotificationManager.swift

import Foundation


import UIKit
import UserNotifications
// import FirebaseMessaging
// import Firebase
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
            Logger.logInfo("NotificationManager > register > registered for remote notification > Granted > \(granted) > Error > \(String(describing: error?.localizedDescription))")
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
        Logger.logInfo("NotificationManager > unregister > unregistered for remote notification")
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
    
//    func saveToken(_ data: Data) {
//        Messaging.messaging().apnsToken = data
//        if let token = Messaging.messaging().fcmToken {
//            Logger.LogInfo("NotificationManager > saveToken > Token: \(token)")
//            Logger.LogInfo("FCM Token: \(String(describing: Messaging.messaging().fcmToken))")
//            UserDefaultManager.deviceToken = token
//            self.statusReceived?(.authorized)
//        }
//    }
    
//    func receivePushNotification(_ dict: [AnyHashable: Any]) {
//        guard let operation = dict["operation"] as? String,
//              let data = dict["data"] as? [String: Any] else {
//            return
//        }
//
//        switch operation {
//        case "alarm":
//       //    self.handelAlarm(data: data)
//            break
//        default:
//            if let message = dict["message"] as? String {
//                self.showAlert(title: "Notification", message: message)
//            } else {
//                Logger.LogInfo("Alert Not show: \(dict)")
//            }
//            break
//        }
//    }
    
//    func handleNotification() -> AlarmModel? {
//        if let notification = notifications.popLast() {
//            Logger.LogInfo("notification Payload: \(notification.request.content.userInfo)")
//            if let dict = notification.request.content.userInfo["gcm.notification.payload"],
//               let payload = self.convertToDictionary(text: dict as! String),
//                let data = payload["data"] as? [String: Any]
//            {
//                if let operation = payload["operation"] as? String{
//                    switch operation {
//                    case "alarm":
//                        let alarmObj = Mapper<AlarmModel>().map(JSON: data)
//                        return alarmObj
//                    default:
//                        return nil
//                    }
//                }
//
//            }
//        }
//        return nil
//    }
    
//    func handelShowPushType(_ dict: [AnyHashable: Any]) -> UNNotificationPresentationOptions{
//        Logger.LogInfo("handelShowPushType: \(dict)")
//        guard let operation = dict["operation"] as? String,
//              let data = dict["data"] as? [String: Any] else {
//            return [.alert,.badge]
//        }
//        switch operation {
//        case "alarm":
//            if let hubId = data["hubId"] as? String,
//               let partitionId = data["partitionId"] as? String,
//               let currentHub = HubManager.shared.hubData,
//               hubId == currentHub.id {
//                let currentPartition = HubManager.shared.hubData.partitions.first(where: { $0.isSelected == true })
//                if partitionId == currentPartition!.id {
//                    return []
//                }
//            }
//            break
//        default:
//            break
//        }
//        return [.alert,.badge]
//    }
    
    func askUserPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
          //  Logger.LogInfo("NotificationManager > register > registered for remote notification > Granted > \(granted) > Error > \(String(describing: error?.localizedDescription))")
            foreground {
                completion(true)
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Logger.logInfo(notification.request.content.userInfo)
//        if let dict = notification.request.content.userInfo["gcm.notification.payload"] {
//            completionHandler([self.handelShowPushType(self.convertToDictionary(text: dict as! String)!)])
//            return
//        }
        completionHandler([.banner, .badge])
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
        UNUserNotificationCenter.current().removeAllDeliveredNotifications() // clear all the notification from notification center
//        if let dict = response.notification.request.content.userInfo["gcm.notification.payload"],
//           var payload = self.convertToDictionary(text: dict as! String)
//        {
//            Logger.LogInfo("Push notification Received.\(response.notification)")
//            if DeviceListManager.shared.isDeviceListRetrieved.value {//Display notification when device list has load
//                guard let _ = payload["operation"] as? String,
//                      let _ = payload["data"] as? [String: Any] else {
//                    Logger.LogInfo("operation & data not received.\(payload)")
//                    return
//                }
//                if payload["message"]  == nil {
//                    payload["message"] = response.notification.request.content.body
//                    Logger.LogInfo("message not received add message in payload.\(payload)")
//                }
//                receivePushNotification(payload)
//            } else {
//                Logger.LogInfo("Push notification added: \(response.notification)")
//                notifications.append(response.notification)
//            }
//        }
        completionHandler()
    }
}

// extension NotificationManager: MessagingDelegate {
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print(fcmToken as Any)
//    }
// }
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
    
//    func handelAlarm(data: [String: Any]) {
//        if let hubId = data["hubId"] as? String,
//           let partitionId = data["partitionId"] as? String,
//           hubId == HubManager.shared.hubData.id {
//            let currentPartition = HubManager.shared.hubData.partitions.first(where: { $0.isSelected == true })
//            if partitionId == currentPartition!.id {
//                //current partition
//                Logger.LogInfo("current partition notification")
//                if AlarmManager.shared.currentAlarm == nil {
//                    if let navVC = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
//                       let tabBar = navVC.children.first as? TabBarVC {
//                        let vc = NotificationDetailsVC.instantiateFromAppStoryboard(appStoryboard: .notification)
//                        let alarmObj = Mapper<AlarmModel>().map(JSON: data)
//                        AlarmManager.shared.currentAlarm = alarmObj!
//                        vc.setAlarmData(alarmObj!)
//                        let nav = UINavigationController(rootViewController: vc)
//                        nav.modalPresentationStyle = .fullScreen
//                        tabBar.present(nav, animated: true, completion: nil)
//                    }
//                }
//            } else {
//                //other partition
//                Logger.LogInfo("Other partition notification")
//                let partitionObj = HubManager.shared.hubData.partitions.first(where: { $0.id == partitionId })
//                self.showAlert(title: data["alarmName"] as! String, message: "There is alarm in \(partitionObj?.name ?? "")")
//            }
//        } else {
//            //other hub
//            Logger.LogInfo("Other HUB notification")
//            self.showAlert(title: data["alarmName"] as! String, message: "There is alarm in other hub.")
//        }
//
//    }
}
