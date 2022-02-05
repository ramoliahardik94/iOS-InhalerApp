//
//  UpdateProfileVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 20/01/22.
//

import UIKit

class UpdateProfileVC: BaseVC {
    
    @IBOutlet weak var lblCreateAccount: UILabel!
    @IBOutlet weak var btnUsePassword: UIButton!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var scrollViewMain: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        initUI()
    }
    
    private func initUI() {
        
        lblFirstName.text = StringUserManagement.firstName.uppercased()
        lblLastName.text = StringUserManagement.lastName.uppercased()
        lblEmail.text = StringUserManagement.email.uppercased()
        lblCreateAccount.text = StringUserManagement.updateProfile
        btnUsePassword.setButtonView(StringUserManagement.update)
        tfFirstName.isOchsnerTextFiled = true
        tfLastName.isOchsnerTextFiled = true
        tfEmail.isOchsnerTextFiled = true
        lblCreateAccount.isTitle = true
        lblFirstName.isTitle = false
        lblLastName.isTitle = false
        lblEmail.isTitle = false
                
        tfFirstName.placeholder = StringUserManagement.placeHolderFirstName
        tfLastName.placeholder = StringUserManagement.placeHolderLastName
        tfEmail.placeholder = StringUserManagement.emailPlaceHolder
        tfFirstName.autocapitalizationType = .words
        tfLastName.autocapitalizationType = .words
        
        addKeyboardAccessory(textFields: [tfFirstName, tfLastName, tfEmail], dismissable: true, previousNextable: true)
        hideKeyBoardHideOutSideTouch(customView: self.view)
        registerKeyboardNotifications()
    }
    
    @IBAction func tapUsePassword(_ sender: UIButton) {
        let connectProviderVC  = ConnectProviderVC.instantiateFromAppStoryboard(appStoryboard: .providers)
        pushVC(controller: connectProviderVC)
    }
    private func setTextFieldFont(textField: UITextField) {
        setCustomFontTextField(textField: textField, type: .regular, fontSize: 17)
    }
    @IBAction func tapBack(_ sender: UIButton) {
        popVC()
    }
    
     override func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        self.scrollViewMain.contentInset = contentInsets
        self.scrollViewMain.scrollIndicatorInsets = contentInsets
        var aRect: CGRect = self.view.frame
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

}
extension UpdateProfileVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }
}
