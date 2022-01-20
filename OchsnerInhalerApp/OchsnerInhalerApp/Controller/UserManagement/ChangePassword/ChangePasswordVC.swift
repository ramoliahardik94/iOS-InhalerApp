//
//  ChangePasswordVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 20/01/22.
//

import UIKit

class ChangePasswordVC: BaseVC {
    @IBOutlet weak var txtCurrentPassword: UITextField!
    @IBOutlet weak var lblChangePassTitle: UILabel!
    @IBOutlet weak var lblCurrentPassword: UILabel!
    @IBOutlet weak var lblNewPassword: UILabel!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var lblConfirmPass: UILabel!
    @IBOutlet weak var txtConfirmPass: UITextField!
    @IBOutlet weak var btnConfirm: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        // Do any additional setup after loading the view.
    }
    
    func setUI(){
        
        lblChangePassTitle.isTitle = true
        lblChangePassTitle.text = StringUserManagement.changePassTitle
        
        
        lblCurrentPassword.text = StringUserManagement.currentPass.uppercased()
        lblCurrentPassword.isTitle = false
        
        txtCurrentPassword.isOchsnerTextFiled = true
        
        txtCurrentPassword.placeholder = StringUserManagement.currrentPassPlaceholder
        
        
        lblNewPassword.text = StringUserManagement.newPass.uppercased()
        lblNewPassword.isTitle = false
        
        txtNewPassword.isOchsnerTextFiled = true
        
        txtNewPassword.placeholder = StringUserManagement.newPassPlaceholder
        
        lblConfirmPass.text = StringUserManagement.confiremPass.uppercased()
        lblConfirmPass.isTitle = false
        
        txtConfirmPass.isOchsnerTextFiled = true
        txtConfirmPass.placeholder = StringUserManagement.confiremPassPlaceholder
        
        btnConfirm.setButtonView(StringUserManagement.updatePass)
        
        txtCurrentPassword.enablePasswordToggle()
        txtNewPassword.enablePasswordToggle()
        txtConfirmPass.enablePasswordToggle()
        
    }
    @IBAction func btnBackClick(_ sender: UIButton) {
        popVC()
    }
    @IBAction func btnUpdatePassClick(_ sender: Any) {
        let vc = UpdateProfileVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
         pushVC(vc: vc)
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

extension ChangePasswordVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }
}
