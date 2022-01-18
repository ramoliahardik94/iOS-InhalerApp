//
//  CreateAccoutVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 13/01/22.
//

import UIKit

class CreateAccoutVC: BaseVC , UITextFieldDelegate {
    @IBOutlet weak var lblCreateAccount: UILabel!
    @IBOutlet weak var btnUsePassword: UIButton!
    
    
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblCreatePassword: UILabel!
    
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    
    @IBOutlet weak var scrollViewMain: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
 
        initUI()
    }
    
    private func initUI() {
        
        lblFirstName.text = StringUserManagement.firstName.uppercased()
        lblLastName.text = StringUserManagement.lastName.uppercased()
        lblEmail.text = StringUserManagement.email.uppercased()
        lblCreatePassword.text = StringUserManagement.createPassword.uppercased()
        lblCreateAccount.text = StringUserManagement.createAccount
        
        
        btnUsePassword.setButtonView(StringUserManagement.usePassword,17)
       
        setBorderTextField(textField: tfFirstName)
        setBorderTextField(textField: tfLastName)
        setBorderTextField(textField: tfEmail)
        setBorderTextField(textField: tfPassword)
        setBorderTextField(textField: tfConfirmPassword)
        
        setCustomFontLabel(label: lblCreateAccount, type: .bold,fontSize: 32)
        setCustomFontLabel(label: lblFirstName, type: .regular,fontSize: 15)
        setCustomFontLabel(label: lblLastName, type: .regular,fontSize: 15)
        setCustomFontLabel(label: lblEmail, type: .regular,fontSize: 15)
        setCustomFontLabel(label: lblCreatePassword, type: .regular,fontSize: 15)
    }

    
    
    @IBAction func tapUsePassword(_ sender: UIButton) {
        let vc  = ConnectProviderVC.instantiateFromAppStoryboard(appStoryboard: .providers)
        pushVC(vc: vc)
    }
    private func setBorderTextField(textField : UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.TextField_Border_Color.cgColor
        textField.layer.cornerRadius = 4
        textField.delegate = self
        setCustomFontTextField(textField: textField, type: .regular,fontSize: 17)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }
    
    
    @IBAction func tapBack(_ sender: UIButton) {
        popVC()
    }
    
}
