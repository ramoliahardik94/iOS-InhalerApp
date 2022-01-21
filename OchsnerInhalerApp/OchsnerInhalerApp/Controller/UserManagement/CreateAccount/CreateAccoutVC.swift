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
    @IBOutlet weak var lblConfirmPassword: UILabel!
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
        lblConfirmPassword.text = StringUserManagement.confiremPassword.uppercased()
        btnUsePassword.setButtonView(StringUserManagement.signup,17)
       
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
        setCustomFontLabel(label: lblConfirmPassword, type: .regular,fontSize: 15)
       
        
        tfFirstName.placeholder = StringUserManagement.placeHolderFirstName
        tfLastName.placeholder = StringUserManagement.placeHolderLastName
        tfEmail.placeholder = StringUserManagement.emailPlaceHolder
        tfPassword.placeholder = StringUserManagement.passwordPlaceHolder
        tfConfirmPassword.placeholder = StringUserManagement.confirmPasswordPlaceHolder
        tfPassword.enablePasswordToggle()
        tfConfirmPassword.enablePasswordToggle()
        tfFirstName.autocapitalizationType = .words
        tfLastName.autocapitalizationType = .words
        
        addKeyboardAccessory(textFields: [tfFirstName,tfLastName,tfEmail,tfPassword,tfConfirmPassword], dismissable: true, previousNextable: true)
        hideKeyBoardHideOutSideTouch(customView: self.view)
        registerKeyboardNotifications()
    }

    
    
    @IBAction func tapUsePassword(_ sender: UIButton) {
        
        if validateData() {
            let vc  = ConnectProviderVC.instantiateFromAppStoryboard(appStoryboard: .providers)
            pushVC(vc: vc)
        }
        
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
    
    
     override func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        self.scrollViewMain.contentInset = contentInsets
        self.scrollViewMain.scrollIndicatorInsets = contentInsets
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize.height
    }
     override func keyboardWillHide(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        self.scrollViewMain.contentInset = contentInsets
        self.scrollViewMain.scrollIndicatorInsets = contentInsets
    }
   
    
    deinit {
       deregisterKeyboardNotifications()
        debugPrint("deinit CreateAccoutVC")
    }
    

    private func validateData() -> Bool {
        var isValid = true
        
        
        if tfFirstName.text == "" {
            self.showAlertMessage(title: "", msg:  StringUserManagement.placeHolderFirstName)
            isValid = false
        }
       
        if tfLastName.text == "" {
            self.showAlertMessage(title: "", msg:  StringUserManagement.placeHolderLastName)
            isValid = false
        }
        
        if !isValidEmail(email: tfEmail.text ?? "") {
            self.showAlertMessage(title: "", msg:  "Enter valid email")
            isValid = false
        }
        
        if tfPassword.text == "" {
            self.showAlertMessage(title: "", msg:  StringUserManagement.passwordPlaceHolder)
            isValid = false
        }
        if tfConfirmPassword.text == "" {
            self.showAlertMessage(title: "", msg:  StringUserManagement.confirmPasswordPlaceHolder)
            isValid = false
        }
        
        if  tfConfirmPassword.text != tfPassword.text  {
            
            self.showAlertMessage(title: "", msg:  "Confirm password doesn't match")
            isValid = false
        }
        return isValid
    }
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
