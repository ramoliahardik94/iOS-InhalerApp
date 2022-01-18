//
//  GlobalStoryboards.swift

import Foundation
import UIKit

enum AppStoryBoardString: String {
    case main = "Main"
    case providers = "Providers"
    case permissions = "Permissions"
    case deviceList = "DeviceList"
    case profile = "Profile"
    case userManagement = "UserManagement"
    case addDevice = "AddDevice"
    
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
