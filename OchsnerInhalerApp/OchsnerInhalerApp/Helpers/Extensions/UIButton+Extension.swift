//
//  UIButton+Extension.swift

import UIKit

extension UIButton {
    func setButtonView(_ title: String, _ size: CGFloat = 17, _ fontName: String = AppFont.AppSemiBoldFont, isDefaultbtn: Bool = true) {
        backgroundColor = isDefaultbtn ? .ButtonColorBlue : .gray
        layer.cornerRadius = 5
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
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
