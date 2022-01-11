//
//  UIButton+Extension.swift

import UIKit

extension UIButton {
    func setButtonView(_ title: String, _ size: CGFloat = 20) {
        backgroundColor = .Button_Color_Blue
        layer.cornerRadius = 5
        setTitle(title.local, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont(name: Constants.CustomFont.OpenSans_SemiBold, size: size)
    }
    
    func setImageColor(_ color: UIColor) {
        let img = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
        setImage(img, for: .normal)
        tintColor = color
    }
}
