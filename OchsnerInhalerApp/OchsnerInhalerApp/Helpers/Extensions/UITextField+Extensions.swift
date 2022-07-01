//
//  UITextField+Extensions.swift

import UIKit.UITextField

extension UILabel {

    
    @IBInspectable var isTitle: Bool {
        get {
            return true
        }
        set {
            if newValue {
                font = UIFont(name: AppFont.AppBoldFont, size: 34)
            } else {
                font = UIFont(name: AppFont.AppRegularFont, size: 17)
            }
        }
    }
    func setFont(type: FontType = .regular, point: CGFloat = 17) {
        switch type {
        case .regular :
            font = UIFont(name: AppFont.AppRegularFont, size: point)
        case .bold :
            font = UIFont(name: AppFont.AppBoldFont, size: point)
        case .semiBold :
            font = UIFont(name: AppFont.AppSemiBoldFont, size: point)
        case .lightItalic :
            font = UIFont(name: AppFont.AppLightItalicFont, size: point)
        case .light :
            font = UIFont(name: AppFont.AppLightFont, size: point)
        }
        
    }
}

extension UITextField {
    
    @IBInspectable var paddingLeft: CGFloat {
           get {
               return leftView!.frame.size.width
           }
           set {
               let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
               leftView = paddingView
               leftViewMode = .always
               
           }
       }

       @IBInspectable var paddingRight: CGFloat {
           get {
               return rightView!.frame.size.width
           }
           set {
               let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
               rightView = paddingView
               rightViewMode = .always
               
           }
       }
    
    func setFont(type: FontType = .regular, point: CGFloat = 17) {
        switch type {
        case .regular :
            font = UIFont(name: AppFont.AppRegularFont, size: point)
        case .bold :
            font = UIFont(name: AppFont.AppBoldFont, size: point)
        case .semiBold :
            font = UIFont(name: AppFont.AppSemiBoldFont, size: point)
        case .lightItalic :
            font = UIFont(name: AppFont.AppLightItalicFont, size: point)
        case .light :
            font = UIFont(name: AppFont.AppLightFont, size: point)
        }
        
    }
    
    @IBInspectable var isOchsnerTextFiled: Bool {
        get {
            return true
        }
        set {
            if newValue {
                let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: frame.size.height))
                leftView = paddingView
                leftViewMode = .always
                layer.borderWidth = 1
                layer.borderColor = UIColor.TextFieldBorderColor.cgColor
                layer.cornerRadius = 4
                font = UIFont(name: AppFont.AppRegularFont, size: 17)
            }
        }
    }
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(self.text!)
    }
    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        if(isSecureTextEntry) {
            button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
            //            button.setImage(UIImage(named: "eye.slash.fill"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            //            button.setImage(UIImage(named: "eye.fill"), for: .normal)
        }
        button.tintColor = .lightGray
    }
    
    func enablePasswordToggle() {
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    @IBAction func togglePasswordView(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender as! UIButton)
    }
}



class CustomUITextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension UIView {
    @IBInspectable var isOchsnerView: Bool {
        get {
            return true
        }
        set {
            if newValue {
                layer.borderWidth = 1
                layer.borderColor = UIColor.TextFieldBorderColor.cgColor
                if self is UITextField {
                    layer.cornerRadius = 4
                } else {
                    layer.cornerRadius = 6
                }
            }
        }
    }
}
