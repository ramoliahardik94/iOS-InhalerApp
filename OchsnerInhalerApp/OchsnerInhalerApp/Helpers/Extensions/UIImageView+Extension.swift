//
//  UIImageView+Extension.swift

import UIKit

extension UIImageView {
    func setImageColor(_ color: UIColor) {
        image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
    }
}
