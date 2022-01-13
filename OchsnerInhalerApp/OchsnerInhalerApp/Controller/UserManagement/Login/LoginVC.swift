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
   
    override func viewDidLoad() {
       initUI()
    }
    private func initUI() {
        lblLogin.text = StringUserManagement.login
        
        btnLogin.setTitle(StringUserManagement.login, for: .normal)
        btnCreateAccount.setTitle(StringUserManagement.createAccount, for: .normal)
        
        btnLogin.backgroundColor = .Button_Color_Blue
        btnLogin.setTitleColor(.Color_White, for: .normal)
        
        btnCreateAccount.backgroundColor = .Button_Color_Blue
        btnCreateAccount.setTitleColor(.Color_White, for: .normal)
            
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
