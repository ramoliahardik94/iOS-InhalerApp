//
//  ProfileVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class ProfileVC: BaseVC {
    @IBOutlet weak var btnUpdateEmail: UIButton!
    @IBOutlet weak var btnChangePassword: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnChangeProvider: UIButton!
    @IBOutlet weak var btnRemoveProvider: UIButton!
    @IBOutlet weak var btnAppVersion: UIButton!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblProvider: UILabel!
    @IBOutlet weak var lblSettings: UILabel!
    @IBOutlet weak var lblReceiveNotifications: UILabel!
    @IBOutlet weak var lblShareLocation: UILabel!
    @IBOutlet weak var lblShareUsageWithProvider: UILabel!
    @IBOutlet weak var lblUseFaceID: UILabel!
    @IBOutlet weak var viewRemovePriver: UIView!
    @IBOutlet weak var switchNotification: UISwitch!
    @IBOutlet weak var switchLocation: UISwitch!
    private var profileVM = ProfileVM()
    var tap = 1
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        setupButton(button: btnUpdateEmail, title: StringProfile.updateEmail)
       // setupButton(button: btnChangePassword, title: StringProfile.changePassword)
        setupButton(button: btnLogout, title: StringProfile.logOut)
        setupButton(button: btnChangeProvider, title: StringProfile.changeProvider)
        setupButton(button: btnRemoveProvider, title: StringProfile.remove)
        lblEmail.setFont(type: .regular, point: 19)
        lblProvider.setFont(type: .bold, point: 19)
        lblSettings.setFont(type: .bold, point: 24)
        lblReceiveNotifications.setFont(type: .regular, point: 21)
        lblShareLocation.setFont(type: .regular, point: 21)
        lblShareUsageWithProvider.setFont(type: .regular, point: 21)

        
        lblEmail.text =  ""
        lblProvider.text = ""
        
        lblSettings.text = StringProfile.settings
        lblReceiveNotifications.text = StringProfile.receiveNotifications
        lblShareLocation.text = StringProfile.shareLocation
        lblShareUsageWithProvider.text = StringProfile.shareUsageWithProvider

        btnAppVersion.setTitle("V - \(appVersion())", for: .normal)

        apiGetProfileData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        switchLocation.setOn(UserDefaultManager.isLocationOn, animated: true)
        switchNotification.setOn(UserDefaultManager.isNotificationOn, animated: true)
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.topItem?.title = StringAddDevice.titleAddDevice
    }
    
    private func setupButton(button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ButtonColorBlue, for: .normal)
        button.titleLabel?.font = UIFont(name: AppFont.AppRegularFont, size: 18)
        
    }
    
    func tapBack(sender: UIButton) {
        popVC()
    }
    
    @IBAction func tapUpdateEmail(_ sender: Any) {
        let updateProfileVC  = UpdateProfileVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
        pushVC(controller: updateProfileVC)
  
    }
   
    @IBAction func tapChangePassword(_ sender: Any) {
        let changePasswordVC  = ChangePasswordVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
        pushVC(controller: changePasswordVC)
    }
   
    @IBAction func tapLogout(_ sender: Any) {
        
        CommonFunctions.showMessageYesNo(message: StringProfile.sureLogout, cancelTitle: StringCommonMessages.cancel, okTitle: StringProfile.logOut) { isOk in
            if isOk {
                Logger.logInfo("Logout Click")                
                self.setRootLogin()
            }
            
        }
    }
   
    @IBAction func tapChangeProvider(_ sender: Any) {
        let providerListVC = ProviderListVC.instantiateFromAppStoryboard(appStoryboard: .providers)
        providerListVC.comeFrom = "profile"
        pushVC(controller: providerListVC)
    }
   
    @IBAction func tapRemoveProvider(_ sender: Any) {
        removeProvider()
    }
    
    @IBAction func onChangeSwitch(_ sender: UISwitch) {
        if sender.tag == SwitchButtonsTag.switchNotification.rawValue {
            UserDefaultManager.isNotificationOn = sender.isOn
            if sender.isOn {
                Logger.logInfo("Toggle On")
                NotificationManager.shared.addReminderLocal(userName: self.profileVM.userData.user?.firstName ?? "")
            } else {
                NotificationManager.shared.removeAllPendingLocalNotification()
            }
            
        } else if sender.tag == SwitchButtonsTag.switchLocation.rawValue {
            UserDefaultManager.isLocationOn = switchLocation.isOn
            if sender.isOn {
                LocationManager.shared.isAllowed(askPermission: true, completion: { status in
                    //   print("location status \(status)")
                    switch(status) {
                    case .notDetermined:
                        break
                    case .denied, .restricted:
                        DispatchQueue.main.async {
                            self.switchLocation.setOn(false, animated: true)
                        }
                        UserDefaultManager.isLocationOn = false
                        CommonFunctions.showMessage(message: StringProfile.locarionPermission, {_ in })
                    case .authorizedAlways, .authorizedWhenInUse:
                        LocationManager.shared = LocationManager()
                    @unknown default:
                        break
                    }
                    
                })
            } else {
                LocationManager.shared.offLocation()
            }
        }
    }
    
    func setRootLogin() {
        removeUser()
        for obj in BLEHelper.shared.connectedPeripheral {
            BLEHelper.shared.cleanup(peripheral: obj.discoveredPeripheral!)
        }
        BLEHelper.shared.connectedPeripheral.removeAll()
        NotificationManager.shared.removeAllPendingLocalNotification()
        let loginVC = LoginVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
        let nav: UINavigationController = UINavigationController()
        nav.isNavigationBarHidden = true
        nav.viewControllers  = [loginVC]
        UIApplication.shared.windows.first?.rootViewController = nav
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    private func apiGetProfileData() {
        CommonFunctions.showGlobalProgressHUD(self)
        profileVM.apiGetProfile { [weak self] result in
            guard let `self` = self else { return }
            CommonFunctions.hideGlobalProgressHUD(self)
            switch result {
            case .success(let status):
                print("Response sucess :\(status)")
                self.lblEmail.text =  self.profileVM.userData.user?.emailAddress ?? StringCommonMessages.notSet
                self.lblProvider.text = "Provider: \(self.profileVM.userData.user?.providerName ?? StringCommonMessages.notSet)"
                self.viewRemovePriver.isHidden = self.profileVM.userData.user?.providerName ?? "" == ""
            case .failure(let message):
                CommonFunctions.showMessage(message: message)
            }
        }
    }
  
    private func removeProvider() {
        let url =  "\(APIRouter.providerAuth.path)?providerId=\("")&accessToken=\("")&expiresIn=\("")&refreshToken=\("")"
        profileVM.removeProvider(url: url) { [weak self] result in
            guard let`self` = self else { return }
            switch(result) {
            case .success(let status):
                print("Response sucess :\(status)")
                self.apiGetProfileData()
                
            case .failure(let message) :
                CommonFunctions.showMessage(message: message)
            }
            
        }
        
    }
   
    @IBAction func btnAppVersionClick(_ sender: Any) {
        if tap == 3 {
            Constants.appdel.sendEmailLogs()
            tap = 1
        } else {
            tap += 1
        }
    }

}

enum SwitchButtonsTag: Int {
    case switchNotification = 0
    case switchLocation = 1
}
