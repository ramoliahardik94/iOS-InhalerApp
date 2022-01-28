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
        setCustomFontLabel(label: lblNotificationPermission, type: .bold,fontSize: 32)
        btnGrant.setButtonView(StringCommonMessages.grant)
        btnSkip.setButtonViewGrey(StringCommonMessages.skip)
    }
    
    //MARK: Actions
    @IBAction func tapGrant(_ sender: UIButton) {
        
//        NotificationManager.shared.askUserPermission { isAllow in
//            if isAllow {
//                DispatchQueue.main.async {
//                    UserDefaultManager.isGrantNotification = true
//                    UserDefaultManager.isNotificationOn = true
//                    let vc = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
//                    self.pushVC(vc: vc)
//
//                }
//            }
//        }
        let vc = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        pushVC(vc: vc)
    }
     
    
    @IBAction func tapSkip(_ sender: UIButton) {
        UserDefaultManager.isGrantNotification = true
        let vc = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .providers)
        pushVC(vc: vc)
    }
        
    

}
