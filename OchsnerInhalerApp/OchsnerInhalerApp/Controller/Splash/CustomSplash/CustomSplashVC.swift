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
       
        setCustomFontLabel(label: lblConnectdInhalerSensor, type: .semiBold, fontSize: 22)
        setCustomFontLabel(label: lblCopyRight, type: .regular, fontSize: 12)
        setCustomFontLabel(label: lblVersion, type: .regular, fontSize: 12)
        lblConnectdInhalerSensor.textColor = .ColorSplashText
        lblVersion.textColor = .black
        lblCopyRight.textColor = .black
    }
    
    @objc func didFinishTimer() {
        if UserDefaultManager.isLogin {
            if !UserDefaultManager.isGrantBLE {
                let bluetoothPermissionVC = BluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.pushVC(controller: bluetoothPermissionVC)
                return
            } else if !UserDefaultManager.isGrantLaocation {
                let locationPermisionVC = LocationPermisionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.pushVC(controller: locationPermisionVC)
                return
            } else if !UserDefaultManager.isGrantNotification {
                let notificationPermissionVC = NotificationPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.pushVC(controller: notificationPermissionVC)
                return
            }
            BLEHelper.shared.isAllowed { isAllow in
                if isAllow {
                    if UserDefaultManager.addDevice.count == 0 {
                    let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                    self.pushVC(controller: addDeviceIntroVC)
                    } else {
                        BLEHelper.shared.scanPeripheral()
                        let vc1 = TemporaryDashbord()
                        self.pushVC(controller: vc1)
                    }
                } else {
                    CommonFunctions.showMessage(message: ValidationMsg.bluetooth, { action in
                        if action ?? true {
                            CommonFunctions.openBluetooth()
                        }
                    }
                    )
                }
            }
            
        } else {
            let loginVC = LoginVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
            // let vc = MedicationVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
             pushVC(controller: loginVC)
        }
        
     
       
    }
    
    deinit {
        debugPrint("deinit CustomSplashVC")
    }
    
}
