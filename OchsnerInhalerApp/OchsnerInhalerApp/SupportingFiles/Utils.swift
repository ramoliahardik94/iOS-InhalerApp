//
//  Utils.swift

import UIKit
import SystemConfiguration.CaptiveNetwork

func getWiFiSSID(completion:@escaping ((String) -> Void)) {
    if !UserDefaultManager.latitude.isEmpty && !UserDefaultManager.longitude.isEmpty {
        LocationManager.shared.checkLocationPermissionAndFetchSSID { (ssid) in
            return completion(ssid)
        }
    } else {
        completion(LocationManager.shared.getSSID())
    }
}

func getLocation() {
    LocationManager.shared.checkLocationPermissionAndFetchLocation { (location) in
        Logger.LogInfo("Fetch locations > locations = \(location.latitude) \(location.longitude)")
    }
}

func appVersion() -> String {
    let dictionary = Bundle.main.infoDictionary!
    let version = dictionary["CFBundleShortVersionString"] as! String
//    let build = dictionary["CFBundleVersion"] as! String
    return "\(version)"
} 

func setUIAppearance() {
    setNavigationAppearance()
    setSegmentControlAppearance()
}

func setNavigationAppearance(_ color: UIColor = .NavigationBar_Color) {
    UINavigationBar.appearance().barTintColor = color
    UINavigationBar.appearance().isTranslucent = false
    UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white,
                                                        .font: UIFont(name: AppFont.AppSemiBoldFont, size: 18)!]
}

func setSegmentControlAppearance() {
    UISegmentedControl.appearance().setTitleTextAttributes([.font: UIFont(name: AppFont.AppSemiBoldFont, size: 15)!,
                                                            .foregroundColor: UIColor.Segment_Color_Normal], for: .normal)
    UISegmentedControl.appearance().setTitleTextAttributes([.font: UIFont(name: AppFont.AppSemiBoldFont, size: 15)!,
                                                            .foregroundColor: UIColor.Segment_Color_Selected], for: .selected)
    UISegmentedControl.appearance().setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
}

func getTime(_ val: Int) -> String {
    return "\(String(format: "%02d", val/60)):\(String(format: "%02d", val%60))s"
}

func removeUser() {
    UserDefaultManager.remove(forKey: .token)
    UserDefaultManager.remove(forKey: .isLogin)
    UserDefaultManager.remove(forKey: .grantBLEPermission)
    UserDefaultManager.remove(forKey: .grantLocationPermission)
    UserDefaultManager.remove(forKey: .grantNotificationPermission)
    
}

func openSettings() {
    if let url = URL(string: "\(UIApplication.openSettingsURLString)") {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        Logger.LogError("Cannot open settings")
    }
}
