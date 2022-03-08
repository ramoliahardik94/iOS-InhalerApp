//
//  LoginVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class LoginVC: BaseVC {

    @IBOutlet weak var btnForgotePsw: UIButton!
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnCreateAccount: UIButton!
    @IBOutlet weak var lblDontHaveAccount: UILabel!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblCreatePassword: UILabel!
    var login = LoginVM()
    override func viewDidLoad() {
       initUI()
    }
    private func initUI() {
        lblLogin.text = StringUserManagement.login
        lblDontHaveAccount.text = StringUserManagement.dontHaveAccout
        lblEmail.text = StringUserManagement.email
        lblCreatePassword.text = StringUserManagement.password.uppercased()
        
        
        btnLogin.setButtonView(StringUserManagement.login, 17)
        btnCreateAccount.setButtonView(StringUserManagement.createAccount, 17)
        
        lblLogin.setFont(type: .bold, point: 34)
        lblDontHaveAccount.setFont(type: .bold, point: 22)
        lblCreatePassword.setFont(type: .regular, point: 15)
        tfEmail.setFont()
        tfPassword.setFont()
      
        tfPassword.layer.borderWidth = 1
        tfPassword.layer.borderColor = UIColor.TextFieldBorderColor.cgColor
        tfEmail.layer.borderWidth = 1
        tfEmail.layer.borderColor = UIColor.TextFieldBorderColor.cgColor
      
        tfEmail.layer.cornerRadius = 4
        tfPassword.layer.cornerRadius = 4
        tfEmail.delegate = self
        tfPassword.delegate = self
        tfPassword.enablePasswordToggle()
        hideKeyBoardHideOutSideTouch(customView: self.view)
        addAstrickSing(label: lblEmail)
        addAstrickSing(label: lblCreatePassword)
        btnForgotePsw.setTitle(StringUserManagement.forgotePass, for: .normal)
        #if DEBUG
        
//        tfEmail.text = "nikita@gmail.com"
//        tfPassword.text = "password"

//         tfEmail.text = "mherzog@ochsner.org"
//        tfPassword.text = "password"

//      
//        tfEmail.text = "dhaval.sabhaya@volansys.com"
//         tfPassword.text = "dhaval123"
        
//        tfEmail.text = "himanshi.shah@volansys.com"
//        tfPassword.text = "abc123"

        tfEmail.text = "abc@mail.com"
        tfPassword.text = "Test123"
        
        #endif
    }
    
   
    deinit {
        print("deinit LoginVC")
    }
    
    
    func setNextView() {        
        
        if !UserDefaultManager.isGrantBLE {
            let bluetoothPermissionVC = BluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
            self.pushVC(controller: bluetoothPermissionVC)
            return
        }
        if !UserDefaultManager.isGrantLaocation {
            let locationPermisionVC = LocationPermisionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
            self.pushVC(controller: locationPermisionVC)
            return
        }
        
        if !UserDefaultManager.isNotificationOn {
            let notificationPermissionVC = NotificationPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
            self.pushVC(controller: notificationPermissionVC)
            return
        }
        let devicelist = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        if devicelist.count == 0 {
            BLEHelper.shared.isAllowed { isAllow in
                if isAllow {
                    let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                    self.pushVC(controller: addDeviceIntroVC)
                }
            }
        } else {
            BLEHelper.shared.scanPeripheral()
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let homeTabBar  = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
            // homeTabBar.selectedIndex = 1
            DispatchQueue.main.async {
                self.rootVC(controller: homeTabBar)
            }
        }
    }
    
    
    // MARK: Actions
    @IBAction func tapLogin(_ sender: UIButton) {
        self.view.endEditing(true)
       
        login.apiLogin {[weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success:
                UserDefaultManager.userEmailAddress = self.tfEmail.text ?? ""
                self.getDeviceFromAPI()
            case .failure(let message):
                CommonFunctions.showMessage(message: message)
            }
        }
      
    }
    func getDeviceFromAPI() {
        self.login.getDeviceList(completionHandler: { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let status):
                print("Response sucess :\(status)")
                self.setNextView()
            case .failure:
                break
                // CommonFunctions.showMessage(message: message)
            }
        })
    }
    
    @IBAction func btnForgotPassClick(_ sender: Any) {
        
        let forgotPassVC  = ForgotPassVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
        forgotPassVC.login = login
        pushVC(controller: forgotPassVC)
        
    }
    @IBAction func tapCreateAccount(_ sender: UIButton) {
        let createAccoutVC  = CreateAccoutVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
        pushVC(controller: createAccoutVC)
    }
    
    
}

extension LoginVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == tfPassword {
            return string != " "
        } else {
            return true
        }
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfEmail {
            login.loginModel.email = tfEmail.text
        } else if textField == tfPassword {
            login.loginModel.password = tfPassword.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }
}
