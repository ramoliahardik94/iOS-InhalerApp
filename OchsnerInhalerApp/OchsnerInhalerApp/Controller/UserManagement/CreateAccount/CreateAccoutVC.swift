//
//  CreateAccoutVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 13/01/22.
//

import UIKit

class CreateAccoutVC: BaseVC {
    @IBOutlet weak var lblCreateAccount: UILabel!
    @IBOutlet weak var btnUsePassword: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        initUI()
    }
    
    private func initUI() {
        
        lblCreateAccount.text = StringUserManagement.createAccount
        
        btnUsePassword.setTitle(StringUserManagement.usePassword, for: .normal)
        btnUsePassword.backgroundColor = .Button_Color_Blue
        btnUsePassword.setTitleColor(.Color_White, for: .normal)
       
        
    }

    
    
    @IBAction func tapUsePassword(_ sender: UIButton) {
        let vc  = ConnectProviderVC.instantiateFromAppStoryboard(appStoryboard: .providers)
        pushVC(vc: vc)
    }
    
    
    
    
    @IBAction func tapBack(_ sender: UIButton) {
        popVC()
    }
    
}
