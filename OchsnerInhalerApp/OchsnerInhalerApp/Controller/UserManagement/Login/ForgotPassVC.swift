//
//  ForgotPassVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 01/03/22.
//

import UIKit

class ForgotPassVC: BaseVC {

    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lbltitleScreen: UILabel!
    @IBOutlet weak var btnForgote: UIButton!
    var login = LoginVM()
    override func viewDidLoad() {
        super.viewDidLoad()
        setui()
        // Do any additional setup after loading the view.
    }
    func setui() {
        lbltitleScreen.text = StringUserManagement.forgotePass
        btnForgote.setButtonView(StringUserManagement.sendLink)
        lbltitleScreen.setFont(type: .bold, point: 34)
        txtEmail.layer.cornerRadius = 4
        lblEmail.text = StringUserManagement.email
        txtEmail.layer.borderWidth = 1
        txtEmail.layer.borderColor = UIColor.TextFieldBorderColor.cgColor
        txtEmail.text = login.loginModel.email
        txtEmail.keyboardType = .emailAddress
        addAstrickSing(label: lblEmail)
        hideKeyBoardHideOutSideTouch(customView: self.view)
        txtEmail.setFont()
    }
    @IBAction func btnForgotClick(_ sender: Any) {
        if (txtEmail.text!.isValidEmail) {
            print(txtEmail.text!.isValidEmail)
            
        } else {
            CommonFunctions.showMessage(message: ValidationMsg.email)
            
        }
    }
    @IBAction func btnBackClick(_ sender: Any) {
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
