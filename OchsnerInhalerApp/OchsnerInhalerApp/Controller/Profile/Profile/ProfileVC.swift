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
        setCustomFontLabel(label: lblEmail, type: .regular,fontSize: 19)
        setCustomFontLabel(label: lblProvider, type: .bold,fontSize: 19)
        setCustomFontLabel(label: lblSettings, type: .bold,fontSize: 24)
        setCustomFontLabel(label: lblReceiveNotifications, type: .regular,fontSize: 21)
        setCustomFontLabel(label: lblShareLocation, type: .regular,fontSize: 21)
        setCustomFontLabel(label: lblShareUsageWithProvider, type: .regular,fontSize: 21)
        setCustomFontLabel(label: lblUseFaceID, type: .regular,fontSize: 21)
        
        lblEmail.text = "lauren@ipsum.com"
        lblProvider.text = "Provider: Ochsner Health"
        
        lblSettings.text = StringProfile.settings
        lblReceiveNotifications.text = StringProfile.receiveNotifications
        lblShareLocation.text = StringProfile.shareLocation
        lblShareUsageWithProvider.text = StringProfile.shareUsageWithProvider
        lblUseFaceID.text = StringProfile.useFaceID
    }
    
    private func setupButton(button : UIButton , title : String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.Button_Color_Blue, for: .normal)
        button.titleLabel?.font = UIFont(name: AppFont.AppRegularFont, size: 18)
        
    }
    
    func tapBack(sender : UIButton) {
        
    popVC()
    }
    
    @IBAction func tapUpdateEmail(_ sender: Any) {
        let vc  = UpdateProfileVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
        pushVC(vc: vc)
  
    }
    @IBAction func tapChangePassword(_ sender: Any) {
        let vc  = ChangePasswordVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
        pushVC(vc: vc)
    }
    @IBAction func tapLogout(_ sender: Any) {
        
        let alert = UIAlertController(title: "", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { action in
            
            alert.dismiss(animated: true, completion: {
                self.setRootLogin()
            })
          
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil )
        }))
        self.present(alert, animated: true)
        
  
    }
    @IBAction func tapChangeProvider(_ sender: Any) {
  
    }
    @IBAction func tapRemoveProvider(_ sender: Any) {
  
    }
    
     func setRootLogin() {
         
         let vc = LoginVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
         let nav : UINavigationController = UINavigationController()
         nav.isNavigationBarHidden = true
         nav.viewControllers  = [vc]
         UIApplication.shared.windows.first?.rootViewController = nav
         UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
