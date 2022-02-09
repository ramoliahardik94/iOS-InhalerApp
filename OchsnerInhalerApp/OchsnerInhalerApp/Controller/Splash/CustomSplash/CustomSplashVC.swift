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
    var timer: Timer!
    override func viewDidLoad() {
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.didFinishTimer), userInfo: nil, repeats: false)
        
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.getisAllow(notification:)), name: .BLEChange, object: nil)
    }
    
    @objc func didFinishTimer() {
        if UserDefaultManager.isLogin {
            if !UserDefaultManager.isGrantBLE {
                let bluetoothPermissionVC = BluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.rootVC(controller: bluetoothPermissionVC)
                return
            } else if !UserDefaultManager.isGrantLaocation {
                let locationPermisionVC = LocationPermisionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.rootVC(controller: locationPermisionVC)
                return
            } else if !UserDefaultManager.isGrantNotification {
                let notificationPermissionVC = NotificationPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.rootVC(controller: notificationPermissionVC)
                return
            } else {
                BLEHelper.shared.setDelegate()
         }
        } else {
            let loginVC = LoginVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
            // let vc = MedicationVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
            
            rootVC(controller: loginVC)
        }
    }
    @objc func getisAllow(notification: Notification) {
        timer.invalidate()
        timer = nil
        BLEHelper.shared.isAllowed { [weak self] isAllow in
            guard let `self` = self else { return }
            
            if isAllow {
                if UserDefaultManager.addDevice.count == 0 {
                let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                    self.pushVC(controller: addDeviceIntroVC)
                } else {
                    BLEHelper.shared.scanPeripheral()
                    
                    let vc1 = TemporaryDashbord()
                    DispatchQueue.main.async {
                        
                        self.rootVC(controller: vc1)
                    }
                }
            } else {
                
                self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.didFinishTimer), userInfo: nil, repeats: false)
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit CustomSplashVC")
    }
    
}
