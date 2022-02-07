//
//  LocationPermisionVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 13/01/22.
//

import UIKit

class LocationPermisionVC: BaseVC {
    @IBOutlet weak var lblLocationPermission: UILabel!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnGrant: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        lblLocationPermission.text = StringPermissions.locationPermission
        setCustomFontLabel(label: lblLocationPermission, type: .bold, fontSize: 32)
        btnSkip.setButtonViewGrey(StringCommonMessages.skip)
        btnGrant.setButtonView(StringCommonMessages.grant)
        
    }
    
    // MARK: Actions
    @IBAction func tapGrant(_ sender: UIButton) {
        LocationManager.shared.isAllowed(askPermission: true) { status in
            UserDefaultManager.isGrantLaocation = true
            print("ststus \(status)")
            if status == .denied {
                
                CommonFunctions.showMessagePermission(message: StringPermissions.locationPermission, cancelTitle: StringCommonMessages.cancel, okTitle: StringProfile.settings, isOpenBluetooth: false) {_ in }
            }
            
            if status == .authorizedWhenInUse || status == .authorizedAlways {
               
                let notificationPermissionVC = NotificationPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.pushVC(controller: notificationPermissionVC)
            }
        }
    }
    
    @IBAction func tapSkip(_ sender: UIButton) {
        UserDefaultManager.isGrantLaocation = true
        let notificationPermissionVC = NotificationPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
        pushVC(controller: notificationPermissionVC)
    }
  

}
