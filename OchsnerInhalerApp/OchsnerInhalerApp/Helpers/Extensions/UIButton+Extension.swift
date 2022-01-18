//
//  UIButton+Extension.swift

import UIKit

extension UIButton {
    func setButtonView(_ title: String, _ size: CGFloat = 17) {
        backgroundColor = .Button_Color_Blue
        layer.cornerRadius = 5
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: AppFont.AppSemiBoldFont, size: size)
    }
    func setButtonViewGreen(_ title: String, _ size: CGFloat = 17) {
        backgroundColor = .Button_Color_Green
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
