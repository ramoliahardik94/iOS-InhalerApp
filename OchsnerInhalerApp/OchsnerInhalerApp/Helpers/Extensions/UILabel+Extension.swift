//
//  UILable+Extenstion.swift

import UIKit

extension UILabel {
    @IBInspectable var languageKey: String {
        
        get {
            return self.text!
        }
        set {
            self.text = newValue.local
//            self.text = LanguageManager.sharedInstance.getTranslationForKey(newValue, value: "")
        }
    }
}
