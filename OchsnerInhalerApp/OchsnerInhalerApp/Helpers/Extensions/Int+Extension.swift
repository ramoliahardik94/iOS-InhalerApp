//
//  Int+Extension.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 19/01/22.
//

import Foundation
import UIKit
extension Int {

    var ordinal: String {
        var suffix: String
        let ones: Int = self % 10
        let tens: Int = (self/10) % 10
        if tens == 1 {
            suffix = "th"
        } else if ones == 1 {
            suffix = "st"
        } else if ones == 2 {
            suffix = "nd"
        } else if ones == 3 {
            suffix = "rd"
        } else {
            suffix = "th"
        }
        return "\(self)\(suffix)"
    }

}
extension NSMutableAttributedString {
    var fontSize: CGFloat { return 17 }
    var boldFont: UIFont { return UIFont(name: AppFont.AppBoldFont, size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont: UIFont { return UIFont(name: AppFont.AppRegularFont, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
    
    var boldNotiFont: UIFont { return UIFont(name: AppFont.AppBoldFont, size: fontSize) ?? UIFont.boldSystemFont(ofSize: 14) }
    var normalNotiFont: UIFont { return UIFont(name: AppFont.AppRegularFont, size: fontSize) ?? UIFont.systemFont(ofSize: 16)}
    
    
    var italicFont: UIFont { return UIFont(name: Constants.CustomFont.SFProDisplayBoldItalic, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
    var normalSmallFont: UIFont { return UIFont(name: AppFont.AppRegularFont, size: 15) ?? UIFont.systemFont(ofSize: 15)}
  
    func bold(_ value: String) -> NSMutableAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont
        ]
        
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
    
    func normal(_ value: String) -> NSMutableAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont
        ]
        
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
    func normalNoti(_ value: String) -> NSMutableAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalNotiFont,
            .foregroundColor: UIColor.black
        ]
        
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
    func boldNoti(_ value: String) -> NSMutableAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldNotiFont,
            .foregroundColor: UIColor.notiBold
        ]
        
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
    /* Other styling methods */
    func orangeHighlight(_ value: String) -> NSMutableAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.orange
        ]
        
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
    
    func blackHighlight(_ value: String) -> NSMutableAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.black
            
        ]
        
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
    
    func italic(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: italicFont
        ]
        
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
    
    func underlined(_ value: String) -> NSMutableAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .underlineStyle: NSUnderlineStyle.single.rawValue
            
        ]
        
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
    
    func chanageColorString(_ value: String) -> NSMutableAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.ButtonColorBlue]
        
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
    func normalSmall(_ value: String) -> NSMutableAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalSmallFont
        ]
        
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
}
