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
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var fileLogger: DDFileLogger!
    var eventStore: EKEventStore?
    let backgroundScanning = "com.ochsnerInhaler.scan"
    let backgroundReScanning = "com.ochsnerInhaler.rescan"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        navigationBarUI()
        
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
        Logger.logInfo("\n\n\n===========================\nLaunched Ochsner Inhaler App > Environment: , App Version: \(appVersion()), Device: \(UIDevice.modelName), iOS Version: \(UIDevice.current.systemVersion), Data Connection:)")
        
        initFirebase()
        registerBackgroundTaks()
        
        BGTaskScheduler.shared.getPendingTaskRequests { arrTask in
            for task in arrTask {
                Logger.logInfo("Pending Task :-> \(task.identifier)")
            }
        }
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
//        if UserDefaultManager.isLogin  && UserDefaultManager.isGrantBLE && UserDefaultManager.isGrantLaocation && UserDefaultManager.isGrantNotification {
//            if BLEHelper.shared.discoveredPeripheral != nil {
//                switch BLEHelper.shared.discoveredPeripheral!.state {
//                case .disconnected:
//                    BLEHelper.shared.connectPeriPheral()
//                default:
//                    break
//                }
//            }
//        }
    }
    
    @objc func backgroundCall() {
       print("App moved to background!")
        scheduleSanner(identifier: backgroundScanning)
        scheduleSanner(identifier: backgroundReScanning)
    }
    
    func navigationBarUI() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = .ButtonColorBlue
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().clipsToBounds = false
        UINavigationBar.appearance().backgroundColor = .ButtonColorBlue
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: (UIFont(name: AppFont.AppBoldFont, size: 18))!, NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        Logger.logInfo(" applicationWillTerminate")
        setNotification()
    }
    
//    func applicationWillResignActive(_ application: UIApplication) {
//        Logger.logInfo(" applicationWillResignActive")
//        setNotification()
//    }
    
    func setNotification() {
        Logger.logInfo(" setNotification start")
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        content.title = StringLocalNotifiaction.title
        content.body =  StringLocalNotifiaction.body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "identifier1", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
            //   Logger.logInfo(" withCompletionHandler")
            if let error = error {
                print("SOMETHING WENT WRONG\(error.localizedDescription))")
            }
        })
        Logger.logInfo(" setNotification End")
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
// MARK: - BG Task
extension AppDelegate {
    // MARK: Register BackGround Tasks
    private func registerBackgroundTaks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundScanning, using: nil) { task in
            // This task is cast with processing request (BGProcessingTask)
            Logger.logInfo(" background Scanning ")
            self.handleBLELogGet(task: task as! BGProcessingTask)
        }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundReScanning, using: nil) { task in
            // This task is cast with processing request (BGProcessingTask)
            
            Logger.logInfo(" background Rescanning ")
            self.handleBLELogGet(task: task as! BGProcessingTask)
        }
    }
    
    func handleBLELogGet(task: BGProcessingTask) {
        
        let workItem = DispatchWorkItem {
            Logger.logInfo("handleBLELogGet")
            if BLEHelper.shared.discoveredPeripheral == nil || BLEHelper.shared.discoveredPeripheral?.state != .connected {
                BLEHelper.shared.scanPeripheral(isTimer: false)
            } else {
                BLEHelper.shared.getAccuationNumber()
            }
        }
        
        workItem.notify(queue: .main, execute: {
            Logger.logInfo("Task Complited.")
            self.scheduleSanner(identifier: task.identifier == self.backgroundScanning ? self.backgroundReScanning : self.backgroundScanning)
        })
        let queue = DispatchQueue.global(qos: .utility)
        queue.async(execute: workItem)
//        // Get & Set New Data
        task.expirationHandler = {
            Logger.logInfo("This Block call by System")
            // This Block call by System
            // Canle your all tak's & queues
        }

//
//        task.setTaskCompleted(success: true)
    }
    
    func scheduleSanner(identifier: String ) {
        let request = BGProcessingTaskRequest(identifier: identifier)
        request.requiresNetworkConnectivity = true // Need to true if your task need to network process. Defaults to false.
        request.requiresExternalPower = false
        
        // If we keep requiredExternalPower = true then it required device is connected to external power.
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1) // fetch Scanne after 1 sec.
        // Note :: EarliestBeginDate should not be set to too far into the future.
        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.logInfo("Task submit success \(identifier)")
        } catch {
            Logger.logError("Could not schedule scanner Task: \(error)")
        }
    }
}
