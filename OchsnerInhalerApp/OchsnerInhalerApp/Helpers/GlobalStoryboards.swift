//
//  GlobalStoryboards.swift

import Foundation
import UIKit

enum AppStoryBoardString: String {
    case main = "Main"
    case tabbar = "TabBar"
    case home = "Home"
    case device = "Devices"
    case automation = "Automations"
    case notification = "Notifications"
    case setting = "Settings"
    case userManagement = "UserManagement"
    case extra = "Extra"
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T: UIViewController>(viewControllerClass: T.Type) -> T {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        return instance.instantiateViewController(withIdentifier: storyboardID) as! T
    }
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}

extension UIViewController {
    class var storyboardID: String {
        return "\(self)"
    }
    
    static func instantiateFromAppStoryboard(appStoryboard: AppStoryBoardString) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
}
