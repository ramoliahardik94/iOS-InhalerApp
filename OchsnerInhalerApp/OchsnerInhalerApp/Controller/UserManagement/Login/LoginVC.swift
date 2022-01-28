//
//  LoginVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class LoginVC : BaseVC{

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
        
        
        btnLogin.setButtonView(StringUserManagement.login,17)
        btnCreateAccount.setButtonView(StringUserManagement.createAccount , 17)
        
        setCustomFontLabel(label: lblLogin, type: .bold,fontSize: 34)
        setCustomFontLabel(label: lblDontHaveAccount, type: .bold,fontSize: 22)
        setCustomFontLabel(label: lblEmail, type: .regular,fontSize: 15)
        setCustomFontLabel(label: lblCreatePassword, type: .regular,fontSize: 15)
        setCustomFontTextField(textField: tfEmail, type: .regular,fontSize: 17)
        setCustomFontTextField(textField: tfPassword, type: .regular,fontSize: 17)
      
        tfPassword.layer.borderWidth = 1
        tfPassword.layer.borderColor = UIColor.TextField_Border_Color.cgColor
        tfEmail.layer.borderWidth = 1
        tfEmail.layer.borderColor = UIColor.TextField_Border_Color.cgColor
      
        tfEmail.layer.cornerRadius = 4
        tfPassword.layer.cornerRadius = 4
        tfEmail.delegate = self
        tfPassword.delegate = self
        tfPassword.enablePasswordToggle()
        hideKeyBoardHideOutSideTouch(customView: self.view)
        addAstrickSing(label: lblEmail)
        addAstrickSing(label: lblCreatePassword)
    }
    
   
    deinit {
        debugPrint("deinit LoginVC")
    }
    
    
    //MARK: Actions
    @IBAction func tapLogin(_ sender: UIButton) {
        self.view.endEditing(true)
        login.apiLogin {[weak self] (result) in
            switch result {
            case .success(let status):
                print("Response sucess :\(status)")
                let vc = BluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self?.pushVC(vc: vc)
            case .failure(let message):
                CommonFunctions.showMessage(message: message)
            }
        }
        
        
      
    }
    
    @IBAction func tapCreateAccount(_ sender: UIButton) {
        let vc  = CreateAccoutVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
        pushVC(vc: vc)
    }
    
    
}

extension LoginVC : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfEmail {
            login.loginModel.email = tfEmail.text
            if !(tfEmail.text ?? "").isValidEmail {
                CommonFunctions.showMessage(message: ValidationMsg.email)
            }
        }else if textField == tfPassword {
            login.loginModel.password = tfPassword.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }
}
