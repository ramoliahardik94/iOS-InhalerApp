//
//  LoginVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class LoginVC: BaseVC {

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
        
        setCustomFontLabel(label: lblLogin, type: .bold, fontSize: 34)
        setCustomFontLabel(label: lblDontHaveAccount, type: .bold, fontSize: 22)
        setCustomFontLabel(label: lblEmail, type: .regular, fontSize: 15)
        setCustomFontLabel(label: lblCreatePassword, type: .regular, fontSize: 15)
        setCustomFontTextField(textField: tfEmail, type: .regular, fontSize: 17)
        setCustomFontTextField(textField: tfPassword, type: .regular, fontSize: 17)
      
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
        #if targetEnvironment(simulator)
        tfEmail.text = "nikita@gmail.com"
        tfPassword.text = "password"
        #endif
    }
    
   
    deinit {
        Logger.logInfo("deinit LoginVC")
    }
    
    
    // MARK: Actions
    @IBAction func tapLogin(_ sender: UIButton) {
        self.view.endEditing(true)
        login.apiLogin {[weak self] (result) in
            switch result {
            case .success(let status):
                Logger.logInfo("Response sucess :\(status)")
                
                if !UserDefaultManager.isGrantBLE {
                    let bluetoothPermissionVC = BluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                    self?.pushVC(controller: bluetoothPermissionVC)
                    return
                }
                if !UserDefaultManager.isGrantLaocation {
                    let locationPermisionVC = LocationPermisionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                    self?.pushVC(controller: locationPermisionVC)
                    return
                }
                
                if !UserDefaultManager.isNotificationOn {
                    let notificationPermissionVC = NotificationPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                    self?.pushVC(controller: notificationPermissionVC)
                    return
                }
                
                BLEHelper.shared.isAllowed { isAllow in
                    if isAllow {
                        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                        self?.pushVC(controller: addDeviceIntroVC)
                    }
                }
                
                
            case .failure(let message):
                CommonFunctions.showMessage(message: message)
            }
        }
        
        
      
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
