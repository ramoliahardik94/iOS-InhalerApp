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
        setCustomFontLabel(label: lblLocationPermission, type: .bold,fontSize: 32)
        btnSkip.setButtonViewGrey(StringCommonMessages.skip)
        btnGrant.setButtonView(StringCommonMessages.grant)
        
    }
    
    //MARK: Actions
    @IBAction func tapGrant(_ sender: UIButton) {
        LocationManager.shared.isAllowed(askPermission: true) { status in
            
            print("ststus \(status)")
            if status == .denied {
                
                CommonFunctions.showMessagePermission(message: "Need to Location Permission", cancelTitle: "Cancel", okTitle: "Setting", isOpenBluetooth: false) { isGrant in
                    
                }
            }
            
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                UserDefaultManager.isGrantLaocation = true
                let vc = NotificationPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.pushVC(vc: vc)
            }
        }
    }
    
    @IBAction func tapSkip(_ sender: UIButton) {
        UserDefaultManager.isGrantLaocation = true
        let vc = NotificationPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
        pushVC(vc: vc)
    }
  

}
