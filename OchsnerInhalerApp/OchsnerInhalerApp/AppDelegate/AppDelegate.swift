//
//  AppDelegate.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 11/01/22.
//

import UIKit
import CoreData
import EventKit
import CocoaLumberjack
import MessageUI
import Firebase
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var fileLogger: DDFileLogger!
    var eventStore: EKEventStore?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        navigationBarUI()
        IQKeyboardManager.shared.enable = true

        NotificationCenter.default.addObserver(self, selector: #selector(backgroundCall), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(foregroundCall), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if paths.count != 0 {
            print("Library Directory : ", paths[0] )
        }
        
        if UserDefaultManager.isNotificationOn {
            NotificationManager.shared.register()
        }
        initLoggers()
        
        if UserDefaultManager.isFirstLaunch == false {
            DatabaseManager.share.deleteAllActuationLog()
            UserDefaultManager.isFirstLaunch = true
        }
        
        Logger.logInfo("\n\n\n===========================\nLaunched Ochsner Inhaler App > Environment: , App Version: \(appVersion()), Device: \(UIDevice.modelName), iOS Version: \(UIDevice.current.systemVersion), Data Connection:)")
        
        initFirebase()
        return true
    }
    
    func initFirebase() {
        FirebaseApp.configure()
    }
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "OchsnerDB")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    @objc func foregroundCall() {
        print("App moved to foreground")
        CommonFunctions.checkVersion()
        if UserDefaultManager.isLogin  && UserDefaultManager.isGrantBLE && UserDefaultManager.isGrantLaocation && UserDefaultManager.isGrantNotification {                                       
            if BLEHelper.shared.logCounter == 0 {
                CommonFunctions.getLogFromDeviceAndSync()
            } else {
                BLEHelper.shared.apiCallForActuationlog()
            }
            if !BLEHelper.shared.connectedPeripheral.isEmpty {
                for peripheral in BLEHelper.shared.connectedPeripheral where peripheral.discoveredPeripheral!.state != .connected {
                    if let peri = peripheral.discoveredPeripheral {
                        BLEHelper.shared.connectPeriPheral(peripheral: peri)
                    }
                }
            }
        }
    }
    
    @objc func backgroundCall() {
        Constants.isDisplay = false
        print("App moved to background!")
        if UserDefaultManager.isLogin {
            let device = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
            if  !BLEHelper.shared.isAddAnother  && ( BLEHelper.shared.connectedPeripheral.count < device.count || (BLEHelper.shared.connectedPeripheral.contains(where: {$0.discoveredPeripheral?.state != .connected })) ) {
                BLEHelper.shared.scanPeripheral()
            }
        }
    }
    
    func navigationBarUI() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = .ButtonColorBlue
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().clipsToBounds = false
        UINavigationBar.appearance().backgroundColor = .ButtonColorBlue
        UINavigationBar.appearance().backItem?.title = ""
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: Constants.titleFont, NSAttributedString.Key.foregroundColor: Constants.titleColor]
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Logger.logInfo(" applicationWillTerminate")
        Constants.isSkipAppUpdate = false
//        setNotification()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let value = userInfo["some-key"] as? String {
            print(value) // output: "some-value"
            Logger.logInfo("##### Silent Message ##### \(value)")
            //            NotificationManager.shared.setSilentNotification(value: value)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .BLEConnect, object: nil)
            }
            BLEHelper.shared.scanPeripheral(isTimer: false)
            NotificationManager.shared.BLEREConnection_1()
        }
        // Inform the system after the background operation is completed.
        completionHandler(.newData)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}
extension AppDelegate {
    // MARK: Loggers
    func initLoggers() {
        fileLogger                                        = DDFileLogger()// File Logger
        fileLogger.rollingFrequency                       = TimeInterval(60*60*24*7)// 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        fileLogger.logFormatter                           = LogFormatter()
        DDLog.add(fileLogger)
    }
    
    func sendEmailLogs() {
        guard MFMailComposeViewController.canSendMail() else {
            showError(message: "CONFIGURE_EMAIL".local)
            return
        }
        
        guard let logData = getAppLogData() else {
            showError(message: "ERROR_APPLOG".local)
            return
        }
        
        // Send Mail
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        let emailSubject = "Application Logs - Ochsner Inhaler | Version: " + appVersion() + " | iOS Version: \(UIDevice.current.systemVersion)"
        composeVC.setSubject(emailSubject)
        composeVC.setMessageBody(emailSubject, isHTML: false)
        
        composeVC.addAttachmentData(logData, mimeType: "text/plain", fileName: "app-debug.log")
        UIApplication.topViewController()?.present(composeVC, animated: true)
        
    }
    
    func getAppLogData() -> Data? {
        guard !fileLogger.logFileManager.sortedLogFilePaths.isEmpty else {
            Logger.logError("App Log Data > Log File Empty: \(fileLogger.logFileManager.sortedLogFilePaths.isEmpty) > Can Send Mail: \(MFMailComposeViewController.canSendMail())")
            return nil
        }
        
        // Get log attachments
        var logFileDataArray = [Data]()
        for logFilePath in fileLogger.logFileManager.sortedLogFilePaths {
            if let logFileData = try? NSData(contentsOfFile: logFilePath, options: NSData.ReadingOptions.mappedIfSafe) {
                // Insert at front to reverse the order, so that oldest logs appear first.
                logFileDataArray.insert(logFileData as Data, at: 0)
            }
        }
        
        var attachmentData = Data()
        for logFileData in logFileDataArray {
            attachmentData.append(logFileData)
        }
        return attachmentData
    }
    private func showError(message: String) {
        
        let alert = UIAlertController(title: "Error".local, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
}
extension AppDelegate: MFMailComposeViewControllerDelegate {
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
