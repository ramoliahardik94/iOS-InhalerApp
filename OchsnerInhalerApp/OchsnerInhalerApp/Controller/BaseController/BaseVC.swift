//
//  BaseVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
    func pushVC(controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func presentVC(controller: UIViewController,animated: Bool = true) {
        self.navigationController?.present(controller, animated: animated, completion: nil)
    }
    func popPresent() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    func rootVC(controller: UIViewController) {
        let nav: UINavigationController = UINavigationController()
        nav.isNavigationBarHidden = true
        nav.navigationBar.barStyle = .black
        nav.view.backgroundColor = .ButtonColorBlue
        nav.viewControllers  = [controller]
        UIApplication.shared.windows.first?.rootViewController = nav
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    func setCustomFontLabel(label: UILabel, type: FontType, fontSize: CGFloat = 14) {
        if type == .regular {
            label.font = UIFont(name: AppFont.AppRegularFont, size: fontSize)
        }
        if type == .bold {
            label.font = UIFont(name: AppFont.AppBoldFont, size: fontSize)
        }
        if type == .semiBold {
            label.font = UIFont(name: AppFont.AppSemiBoldFont, size: fontSize)
        }
        if type == .lightItalic {
            label.font = UIFont(name: AppFont.AppLightItalicFont, size: fontSize)
        }
        if type == .light {
            label.font = UIFont(name: AppFont.AppLightFont, size: fontSize)
        }
        
    }
    
    func setCustomFontTextField(textField: UITextField, type: FontType, fontSize: CGFloat = 14) {
        if type == .regular {
            textField.font = UIFont(name: AppFont.AppRegularFont, size: fontSize)
        }
        if type == .bold {
            textField.font = UIFont(name: AppFont.AppBoldFont, size: fontSize)
        }
        if type == .semiBold {
            textField.font = UIFont(name: AppFont.AppSemiBoldFont, size: fontSize)
        }

    }
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    func addKeyboardAccessory(textFields: [UITextField], dismissable: Bool = true, previousNextable: Bool = true) {
        for (index, textField) in textFields.enumerated() {
            let toolbar: UIToolbar = UIToolbar()
            toolbar.sizeToFit()
            
            var items = [UIBarButtonItem]()
            if previousNextable {
                let previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: nil, action: nil)
                previousButton.width = 30
                if textField == textFields.first {
                    previousButton.isEnabled = false
                } else {
                    previousButton.target = textFields[index - 1]
                    previousButton.action = #selector(UITextField.becomeFirstResponder)
                }
                
                let nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: nil, action: nil)
                nextButton.width = 30
                if textField == textFields.last {
                    nextButton.isEnabled = false
                } else {
                    nextButton.target = textFields[index + 1]
                    nextButton.action = #selector(UITextField.becomeFirstResponder)
                }
                items.append(contentsOf: [previousButton, nextButton])
            }
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing))
            items.append(contentsOf: [spacer, doneButton])
            toolbar.setItems(items, animated: false)
            textField.inputAccessoryView = toolbar
        }
    }
    func hideKeyBoardHideOutSideTouch(customView: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        customView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func  tapNotification () {
        let notificationVC  = NotificationVC.instantiateFromAppStoryboard(appStoryboard: .main)
        self.pushVC(controller: notificationVC)
    }
    
    // MARK: For keyboard Observer
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
      
    }
    @objc func keyboardWillHide(notification: NSNotification) {
       
    }
    
    func deregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    // Done keyboard Observer
    
    deinit {
        print("deinit basevc ")
    }
    
    func addAstrickSing(label: UILabel) {
         let range = NSRange(location: label.text?.count ?? 0 + 1, length: 1) //
         let  attributedString = NSMutableAttributedString(string: "\(label.text ?? "")*")
         attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
         label.attributedText = attributedString
     }
   
}
