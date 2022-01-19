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
        btnSkip.setButtonView(StringCommonMessages.skip)
        btnGrant.setButtonView(StringCommonMessages.grant)
        
    }
    
    //MARK: Actions
    @IBAction func tapGrant(_ sender: UIButton) {
        let vc = NotificationPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
        pushVC(vc: vc)
    }
    
    @IBAction func tapSkip(_ sender: UIButton) {
        popVC()
    }
  

}
