//
//  UIButton+Extension.swift

import UIKit

extension UIButton {
    func setButtonView(_ title: String, _ size: CGFloat = 17, _ fontName: String = AppFont.AppSemiBoldFont, isDefaultbtn: Bool = true, isBlankBG: Bool = false) {
        setTitleColor(.white, for: .normal)
        backgroundColor = isDefaultbtn ? .ButtonColorBlue : .gray
        if isBlankBG {
            backgroundColor = .clear
            layer.borderColor = isDefaultbtn ? (UIColor.ButtonColorBlue).cgColor : (UIColor.gray).cgColor
            layer.borderWidth = 1
            setTitleColor(isDefaultbtn ? .ButtonColorBlue : .gray, for: .normal)
        }
        layer.cornerRadius = 5
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont(name: fontName, size: size)
    }
    func setButtonViewGreen(_ title: String, _ size: CGFloat = 17) {
        backgroundColor = .ButtonColorGreen
        layer.cornerRadius = 5
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: AppFont.AppSemiBoldFont, size: size)
    }
    
    func setButtonViewGrey(_ title: String, _ size: CGFloat = 17) {
        backgroundColor = .ButtonColorGrey
        layer.cornerRadius = 5
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: AppFont.AppSemiBoldFont, size: size)
    }
    
    func setImageColor(_ color: UIColor) {
        let img = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
        setImage(img, for: .normal)
        tintColor = color
    }
}
