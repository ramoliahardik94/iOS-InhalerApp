//
//  UIView+Extension.swift

import UIKit
import MBProgressHUD

extension UIView {
    
    @objc func viewDidRemove() {}
    
    func setBorder(_ width: CGFloat = 0.5, color: UIColor = .black, radius: CGFloat = 0) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        layer.cornerRadius = radius
    }
    
    func setRoundView() {
        layer.masksToBounds = true
        layer.cornerRadius = frame.height / 2
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func setCornerRadius(with CACornerMask: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], _ radius: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = [CACornerMask]
    }
    
    func addShadow(color: UIColor = .black, offset: CGSize = CGSize(width: 5, height: 4), contactRect: CGRect) {
        layer.cornerRadius = frame.height / 2
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.25
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
    }
    
    // Spinner related mathods
    func showProgress() {
        DispatchQueue.main.async {
            let progressHUD = MBProgressHUD.showAdded(to: self, animated: true)
            progressHUD.show(animated: true)
            Logger.logInfo("showProgress")       
        }
    }
    
    func hideProgress() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self, animated: true)
            Logger.logInfo("HideProgress")
        }
    }
}
