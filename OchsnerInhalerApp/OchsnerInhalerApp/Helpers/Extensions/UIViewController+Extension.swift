//
//  UIViewController+Extension.swift

import UIKit

extension UIViewController: UIPopoverPresentationControllerDelegate {
    
    // Class methods
    class func setAsRootVC(_ storyBoard: AppStoryBoardString) {
        let controller = self.instantiateFromAppStoryboard(appStoryboard: storyBoard)
        let nav = UINavigationController(rootViewController: controller)
        UIApplication.shared.windows.first?.rootViewController = nav
    }
    
    class func popFromVC(_ controller: UIViewController) {
        if let controller = controller.navigationController?.viewControllers.first(where: { $0 is Self }) {
            controller.navigationController?.popToViewController(controller, animated: true)
        }
    }
    
    // Navigation related methods
    func setBackButton(color: UIColor = .white, isPopToRoot: Bool = false, selector: Selector? = nil) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: 40))
        btn.setTitle("Back".local, for: .normal)
        btn.setImage(#imageLiteral(resourceName: "ic_back_arrow_white"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        btn.setImageColor(color)
        view.addSubview(btn)
        
        if let selector = selector {
            btn.addTarget(self, action: selector, for: .touchUpInside)
        } else if isPopToRoot {
            btn.addTarget(navigationController, action: #selector(UINavigationController.popToRootViewController(animated:)), for: .touchUpInside)
        } else {
            btn.addTarget(navigationController, action: #selector(UINavigationController.popViewController(animated:)), for: .touchUpInside)
        }
        
        let leftBarButtonItem = UIBarButtonItem(customView: view)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func setNavigationColor(_ color: UIColor, titleColor: UIColor) {
        navigationController?.navigationBar.barTintColor = color
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: titleColor]
    }
    
//    func showToast(message: String, keayboardHeight: Int = 1) {
//            let font = UIFont(name: Constants.CustomFont.OpenSans_Regular, size: 12)
//            let toastLabel = UILabel()
//            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//            toastLabel.textColor = .white
//            toastLabel.font = font
//            toastLabel.textAlignment = .center
//            toastLabel.text = message
//            toastLabel.alpha = 1.0
//            toastLabel.layer.cornerRadius = 5
//            toastLabel.clipsToBounds = true
//            toastLabel.layer.name = "Toast"
//            toastLabel.numberOfLines = 0
//            
//            let maxWidthPercentage: CGFloat = 0.8
//            let maxTitleSize = CGSize(width: view.bounds.size.width * maxWidthPercentage, height: view.bounds.size.height * maxWidthPercentage)
//            var titleSize = toastLabel.sizeThatFits(maxTitleSize)
//            titleSize.width += 20
//            titleSize.height += 10
//            if UIApplication.shared.isKeyboardPresented && keayboardHeight != 0 {
//                var keyboardHeight: CGFloat = -40
//                if !self.hasTopNotch {
//                    keyboardHeight = -10
//                }
//                if getTabbar() == nil {
//                    keyboardHeight = 40
//                }
//                toastLabel.frame = CGRect(x: view.frame.size.width / 2 - titleSize.width / 2, y: view.frame.size.height - (KeyboardManager.shared.keyboardHeight + keyboardHeight ), width: titleSize.width, height: titleSize.height)
//            } else {
//                toastLabel.frame = CGRect(x: view.frame.size.width / 2 - titleSize.width / 2, y: view.frame.size.height - titleSize.height - 50, width: titleSize.width, height: titleSize.height)
//            }
//            if let subview = view.subviews.first(where: {$0.layer.name == "Toast"}) {
//                subview.removeFromSuperview()
//            }
//            view.addSubview(toastLabel)
//            UIView.animate(withDuration: 1, delay: 2, options: .curveEaseOut, animations: {
//                toastLabel.alpha = 0.0
//            }, completion: { _ in
//                toastLabel.removeFromSuperview()
//            })
//        }
    
    func setSwipeBack(_ isEnable: Bool = true) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnable
    }
    
    func isPresented() -> Bool {
        return presentingViewController?.presentedViewController == self ||
            self.navigationController?.presentingViewController?.presentedViewController == self.navigationController
    }
}

// MARK: - Authentication related methods
extension UIViewController {
    func checkLocalAuthentication(isBiometryChecked: Bool = false, isForce: Bool = false, completion: @escaping (Bool?) -> Void) {
//        if !isBiometryChecked, UserDefaultManager.biometry {
//            checkBiometry(isForce: isForce, completion)
//            return
//        }
//        if UserDefaultManager.appPin != nil {
//            checkAppPin(isForce: isForce, completion)
//            return
//        }
        completion(nil)
    }
    
    func askForAuthentication(isBiometryChecked: Bool = false, isForce: Bool = false, completion: @escaping (Bool) -> Void) {
//        if !isBiometryChecked, UserDefaultManager.biometry {
//            checkBiometry(isForce: isForce, completion)
//            return
//        }
//        if UserDefaultManager.appPin != nil {
//            checkAppPin(isForce: isForce, completion)
//            return
//        }
    }
    
}


// MARK: - Container view related methods
extension UIViewController {
    func addChildController(_ childVC: UIViewController, to containerView: UIView) {
        removeChildControllers()
        addChild(childVC)
        childVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        childVC.view.frame = containerView.bounds
        containerView.addSubview(childVC.view)
        childVC.didMove(toParent: self)
    }
    
    func removeChildControllers() {
        children.forEach { childVC in
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
    }
}



// MARK: - Check device contain safe area or not
extension UIViewController {
    var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}
