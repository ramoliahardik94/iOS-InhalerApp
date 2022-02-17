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
   
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblProvider: UILabel!
    @IBOutlet weak var lblSettings: UILabel!
    @IBOutlet weak var lblReceiveNotifications: UILabel!
    @IBOutlet weak var lblShareLocation: UILabel!
    @IBOutlet weak var lblShareUsageWithProvider: UILabel!
    @IBOutlet weak var lblUseFaceID: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        setupButton(button: btnUpdateEmail, title: StringProfile.updateEmail)
        setupButton(button: btnChangePassword, title: StringProfile.changePassword)
        setupButton(button: btnLogout, title: StringProfile.logOut)
        setupButton(button: btnChangeProvider, title: StringProfile.changeProvider)
        setupButton(button: btnRemoveProvider, title: StringProfile.remove)
        lblEmail.setFont(type: .regular, point: 19)
        lblProvider.setFont(type: .bold, point: 19)
        lblSettings.setFont(type: .bold, point: 24)
        lblReceiveNotifications.setFont(type: .regular, point: 21)
        lblShareLocation.setFont(type: .regular, point: 21)
        lblShareUsageWithProvider.setFont(type: .regular, point: 21)

        
        lblEmail.text = "lauren@ipsum.com"
        lblProvider.text = "Provider: Ochsner Health"
        
        lblSettings.text = StringProfile.settings
        lblReceiveNotifications.text = StringProfile.receiveNotifications
        lblShareLocation.text = StringProfile.shareLocation
        lblShareUsageWithProvider.text = StringProfile.shareUsageWithProvider

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
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
            if isOk ?? false {
                self.setRootLogin()
            }
            
        }
    }
    @IBAction func tapChangeProvider(_ sender: Any) {
        let providerListVC = ProviderListVC.instantiateFromAppStoryboard(appStoryboard: .providers)
        pushVC(controller: providerListVC)
    }
    @IBAction func tapRemoveProvider(_ sender: Any) {
  
    }
    
     func setRootLogin() {
         removeUser()
         let loginVC = LoginVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
         let nav: UINavigationController = UINavigationController()
         nav.isNavigationBarHidden = true
         nav.viewControllers  = [loginVC]
         UIApplication.shared.windows.first?.rootViewController = nav
         UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
