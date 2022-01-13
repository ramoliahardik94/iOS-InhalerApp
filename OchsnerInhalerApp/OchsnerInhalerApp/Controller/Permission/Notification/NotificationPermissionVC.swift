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
        
        btnSkip.setTitle(StringCommonMessages.skip, for: .normal)
        btnGrant.setTitle(StringCommonMessages.grant, for: .normal)
        
        btnGrant.backgroundColor = .Button_Color_Blue
        btnGrant.setTitleColor(.Color_White, for: .normal)
        
        btnSkip.backgroundColor = .Color_Gray
        btnSkip.setTitleColor(.Color_White, for: .normal)
        
    }
    
    //MARK: Actions
    @IBAction func tapGrant(_ sender: UIButton) {
        let vc = OchsnerCloudPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
        pushVC(vc: vc)
    }
    
    @IBAction func tapSkip(_ sender: UIButton) {
        popVC()
    }

}
