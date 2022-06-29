//
//  NotificationPermissionVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 13/01/22.
//

import UIKit

class NotificationPermissionVC: BaseVC {
    @IBOutlet weak var lblNotificationPermission: UILabel!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnGrant: UIButton!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNotificationPermission.text = StringPermissions.notificationPermission
        lblNotificationPermission.setFont(type: .bold, point: 32)
        btnGrant.setButtonView(StringCommonMessages.grant)
        btnSkip.setButtonViewGrey(StringCommonMessages.skip)
        UserDefaultManager.isGrantNotification = true
    }
    // MARK: Actions
    @IBAction func tapGrant(_ sender: UIButton) {
        
        NotificationManager.shared.askUserPermission { isAllow in
            if isAllow {
                DispatchQueue.main.async { [self] in
                    UserDefaultManager.isGrantNotification = true
                    UserDefaultManager.isNotificationOn = true
                    setFlow()
                }
            }
        }
    }
    
    
    func setFlow() {
        let devicelist = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email).map({$0.udid})
        if devicelist.count == 0 {
            let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
            DispatchQueue.main.async {
                HealthKitAssistant.shared.getHealthKitPermission { isAllow in
                    print(isAllow)
                    if isAllow {
                        print("HealthKit Permittion Allowed")
                    } else {
                        print("HealthKit Permittion decline")
                    }
                    DispatchQueue.main.async {
                        self.rootVC(controller: addDeviceIntroVC)
                    }
                }
            }
        } else {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let homeTabBar  = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
            DispatchQueue.main.async {
                HealthKitAssistant.shared.getHealthKitPermission { isAllow in
                    print(isAllow)
                    if isAllow {
                        print("HealthKit Permittion Allowed")
                    } else {
                        print("HealthKit Permittion decline")
                    }
                    DispatchQueue.main.async {
                        self.rootVC(controller: homeTabBar)
                    }
                }
            }
        }
    }
    @IBAction func tapSkip(_ sender: UIButton) {
        UserDefaultManager.isNotificationOn = false
        setFlow()       
    }
}
