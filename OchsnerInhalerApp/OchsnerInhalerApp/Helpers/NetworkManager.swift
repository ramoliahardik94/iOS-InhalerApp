//
//  NetworkManager.swift
//

import Foundation
import Alamofire
import CocoaLumberjack

enum ReachabilityStatus {
    case unknown, notReachable, cellular, ethernetOrWiFi
}

protocol NetworkConnectivityDelegate: class {
    func networkConnectionRestablish()
}

class NetworkManager: NSObject {
    static let shared = NetworkManager()
    var networkstatus: ReachabilityStatus = .unknown
    weak var connectionDelegate: NetworkConnectivityDelegate?
    let manager = Alamofire.NetworkReachabilityManager()
    
    func startListening() {
        manager?.listener = { status in
            switch status {
            case .reachable(.ethernetOrWiFi):
                self.networkstatus = .ethernetOrWiFi
            case .reachable(.wwan):
                self.networkstatus = .cellular
            case .notReachable:
                self.networkstatus = .notReachable
            case .unknown:
                self.networkstatus = .unknown
            }
            self.networkStatus(status: self.networkstatus)
        }
        manager?.startListening()
    }
    
    func networkStatus(status: ReachabilityStatus) {
        if status == .unknown || status == .notReachable {
            Logger.LogError("NetworkConnectionFailed with \(status)")
            if UIApplication.topViewController()!.isKind(of: UIAlertController.self) {
                UIApplication.topViewController()!.dismiss(animated: false) {
                    self.showNoInternetScreen()
                }
            } else {
                self.showNoInternetScreen()
            }
           
        } else if status == .cellular || status == .ethernetOrWiFi {
            Logger.LogInfo("NetworkConnection Restablish With \(status)")
            getWiFiSSID { (ssid) in
                Logger.LogInfo("SSID: \(ssid)")
            }
        }
    }
    
    func showNoInternetScreen() {
//        if !UIApplication.topViewController()!.isKind(of: NetworkConnectionVC.self) {
//            let vc = NetworkConnectionVC.instantiateFromAppStoryboard(appStoryboard: .extra)
//            vc.networkRetryCallback = { _ in
//                vc.dismiss(animated: true) {
//                    self.connectionDelegate?.networkConnectionRestablish()
//                }
//            }
//            vc.modalPresentationStyle = .fullScreen
//            UIApplication.topViewController()?.present(vc, animated: true)
//        }
    }
}
