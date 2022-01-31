//
//  CustomSplashVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 13/01/22.
//

import Foundation
import UIKit
class CustomSplashVC: BaseVC {
    
    @IBOutlet weak var lblCopyRight: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblConnectdInhalerSensor: UILabel!
   
    override func viewDidLoad() {
        
        _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.didFinishTimer), userInfo: nil, repeats: false)
        
        
        lblCopyRight.text = StringCommonMessages.copyRight
        lblConnectdInhalerSensor.text = StringSplash.connectdInhalerSensor
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        lblVersion.text = "V\(appVersion ?? "1")"
       
        setCustomFontLabel(label: lblConnectdInhalerSensor, type: .semiBold,fontSize: 22)
        setCustomFontLabel(label: lblCopyRight, type: .regular,fontSize: 12)
        setCustomFontLabel(label: lblVersion, type: .regular,fontSize: 12)
        lblConnectdInhalerSensor.textColor = .Color_SplashText
        lblVersion.textColor = .black
        lblCopyRight.textColor = .black
    }
    
    @objc func didFinishTimer() {
        
        if UserDefaultManager.isLogin {
            if !UserDefaultManager.isGrantBLE {
                let vc = BluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.pushVC(vc: vc)
                return
            }
            else if !UserDefaultManager.isGrantLaocation {
                let vc = LocationPermisionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.pushVC(vc: vc)
                return
            }
            else if !UserDefaultManager.isGrantNotification {
                let vc = NotificationPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.pushVC(vc: vc)
                return
            }
            BLEHelper.shared.isAllowed { isAllow in
                if isAllow {
                    let vc = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                    self.pushVC(vc: vc)
                }
                else {
                    CommonFunctions.showMessage(message: ValidationMsg.bluetooth, { ok in
                        if ok ?? true {
                            CommonFunctions.openBluetooth()
                        }
                    }
                    )
                }
            }
            
        } else {
            let vc = LoginVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
            // let vc = MedicationVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
             pushVC(vc: vc)
        }
        
     
       
    }
    
    deinit {
        debugPrint("deinit CustomSplashVC")
    }
    
}
