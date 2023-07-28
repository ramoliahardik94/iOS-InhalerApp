//
//  UIApplication.swift

import Foundation
import UIKit

// Extension to get app version details
extension UIApplication {
    
    class func bundleID() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as! String
    }
    
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(selected)
            
        } else if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }

    var isKeyboardPresented: Bool {
        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"),
           self.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) {
            return true
        } else {
            return false
        }
    }
    
}
