//
//  ProviderVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 17/01/22.
//

import UIKit

class ProviderVC: BaseVC {
    @IBOutlet weak var imgProvider: UIImageView!
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var viewProvider: UIView!
    @IBOutlet weak var btnLogin: UIButton!
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setVC()
        // Do any additional setup after loading the view.
    }
    
    func setVC() {
        viewProvider.backgroundColor = .ColorProviderView
        viewAlert.isOchsnerView = true
        btnLogin.setButtonViewGreen(StringPoviders.continueProvider)
        if index == 1 {
            imgProvider.image = UIImage(named: "provider")
        } else if index == 2 {
            imgProvider.image = UIImage(named: "provider1")
        } else {
            imgProvider.image = UIImage(named: "provider2")
        }
    }
    
    @IBAction func btnLoginClick(_ sender: Any) {
        let bluetoothPermissionVC  = BluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
        pushVC(controller: bluetoothPermissionVC)
    }
  
    @IBAction func btnSwitchOrganization(_ sender: Any) {
        self.popVC()
    }
  
}
