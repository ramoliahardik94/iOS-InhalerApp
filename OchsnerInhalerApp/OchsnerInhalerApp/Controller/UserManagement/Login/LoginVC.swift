//
//  LoginVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class LoginVC : BaseVC {

    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnCreateAccount: UIButton!
    @IBOutlet weak var lblDontHaveAccount: UILabel!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    override func viewDidLoad() {
       initUI()
    }
    private func initUI() {
        lblLogin.text = StringUserManagement.login
        lblDontHaveAccount.text = StringUserManagement.dontHaveAccout
        
        btnLogin.setButtonView(StringUserManagement.login)
        btnCreateAccount.setButtonView(StringUserManagement.createAccount)
        setCustomFontLabel(label: lblLogin, type: .bold,fontSize: 20)
        setCustomFontLabel(label: lblDontHaveAccount, type: .bold,fontSize: 20)
    }
    
    
    deinit {
        debugPrint("deinit LoginVC")
    }
    
    
    //MARK: Actions
    @IBAction func tapLogin(_ sender: UIButton) {
        let vc  = ConnectProviderVC.instantiateFromAppStoryboard(appStoryboard: .providers)
        pushVC(vc: vc)
    }
    
    @IBAction func tapCreateAccount(_ sender: UIButton) {
        let vc  = CreateAccoutVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
        pushVC(vc: vc)
    }
    
    
}
