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
    }
    
    // MARK: Actions
    @IBAction func tapGrant(_ sender: UIButton) {
        
        NotificationManager.shared.askUserPermission { isAllow in
            if isAllow {
                DispatchQueue.main.async {
                    UserDefaultManager.isGrantNotification = true
                    UserDefaultManager.isNotificationOn = true
                    let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                    self.pushVC(controller: addDeviceIntroVC)
                   
                }
            }
        }
    }
     
    
    @IBAction func tapSkip(_ sender: UIButton) {
        UserDefaultManager.isGrantNotification = true
        UserDefaultManager.isNotificationOn = false
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        self.pushVC(controller: addDeviceIntroVC)
    }
        
    

}
