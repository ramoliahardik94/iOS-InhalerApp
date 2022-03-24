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
    var deviceUDID = [String]()
    var timer: Timer!
    var isTime = false
    
    override func viewDidLoad() {
        DispatchQueue.global(qos: .userInteractive).sync {
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.didFinishTimer), userInfo: nil, repeats: false)
        }
        lblCopyRight.text = StringCommonMessages.copyRight
        lblConnectdInhalerSensor.text = StringSplash.connectdInhalerSensor
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        lblVersion.text = "V\(appVersion ?? "1")"
        lblConnectdInhalerSensor.setFont(type: .semiBold, point: 22)
        lblCopyRight.setFont(type: .regular, point: 12)
        lblVersion.setFont(type: .regular, point: 12)
        lblConnectdInhalerSensor.textColor = .ColorSplashText
        lblVersion.textColor = .black
        lblCopyRight.textColor = .black
        NotificationCenter.default.addObserver(self, selector: #selector(self.getisAllow(notification:)), name: .BLEOnOff, object: nil)
        let devicelist = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        deviceUDID = devicelist.map({$0.udid!})
        
        if UserDefaultManager.isLogin  && UserDefaultManager.isGrantBLE && UserDefaultManager.isGrantLaocation && UserDefaultManager.isGrantNotification && deviceUDID.count > 0 {
            BLEHelper.shared.setDelegate()
            delay(2) {
                if BLEHelper.shared.centralManager.state == .poweredOn {
                    BLEHelper.shared.scanPeripheral()
                }
            }
            
            BLEHelper.shared.apiCallDeviceUsage()
            if UserDefaultManager.isLocationOn {
                LocationManager.shared = LocationManager()
            }
        }
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
                isTime = true
                BLEHelper.shared.setDelegate()
         }
        } else {
            let loginVC = LoginVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
            // let vc = MedicationVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
            rootVC(controller: loginVC)
        }
    }
    @objc func getisAllow(notification: Notification) {
        BLEHelper.shared.isAllowed { [weak self] isAllow in
            guard let `self` = self else { return }
            
            if isAllow && self.isTime {
                BLEHelper.shared.setDelegate()
                let devicelist = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email).map({$0.udid})
                if devicelist.count == 0 {
                let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                    self.rootVC(controller: addDeviceIntroVC)
                } else {                    
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let homeTabBar  = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
                    DispatchQueue.main.async {
                        self.rootVC(controller: homeTabBar)
                    }
                }
            } else {
                DispatchQueue.global(qos: .userInteractive).sync {
                self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.didFinishTimer), userInfo: nil, repeats: false)
                }
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("deinit CustomSplashVC")
    }
    
}
