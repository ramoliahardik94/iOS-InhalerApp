//
//  ProviderVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 17/01/22.
//

import UIKit

class ProviderVC: BaseVC {

    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var viewSwitchOrganization: UIView!
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var btnSwitchOrganization: UIButton!
    @IBOutlet weak var viewProvider: UIView!
    @IBOutlet weak var btnLogin: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setVC()
        // Do any additional setup after loading the view.
    }
    func setVC(){
        btnSwitchOrganization.setTitle(StringPoviders.switchOrganization, for: .normal)
        viewHeader.backgroundColor = .lightGray
        viewSwitchOrganization.layer.borderWidth = 1
        viewSwitchOrganization.layer.cornerRadius = 6
        viewSwitchOrganization.layer.borderColor = UIColor.black.cgColor
        btnSwitchOrganization.titleLabel?.font = UIFont(name:AppFont.AppBoldFont , size: 14)
        btnSwitchOrganization.tintColor = .black
        viewProvider.backgroundColor = .Color_ProviderView
        viewAlert.layer.borderWidth = 1
        viewAlert.layer.cornerRadius = 6
        viewAlert.layer.borderColor = UIColor.lightGray.cgColor
        btnLogin.setButtonViewGreen("Continue to Login")
        
    }
    
    
    @IBAction func btnLoginClick(_ sender: Any) {
        
    }
    @IBAction func btnSwitchOrganization(_ sender: Any) {
        self.popVC()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
