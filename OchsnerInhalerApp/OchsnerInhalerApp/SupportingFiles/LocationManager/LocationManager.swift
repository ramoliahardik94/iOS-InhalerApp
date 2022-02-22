//
//  LocationManager.swift


import UIKit
import CoreLocation
import SystemConfiguration.CaptiveNetwork

class LocationManager: CLLocationManager {
    
    // MARK: Properties
    static let shared = LocationManager()
    var locationManager = CLLocationManager()
    var ssidCompletion: ((String) -> Void)!
    var locationCompletion: ((CLLocationCoordinate2D) -> Void)!
    var permissionCompletion: ((CLAuthorizationStatus) -> Void)?
    var lat: String = ""
    var long: String = ""
    override init() {
        super.init()
    }
    
    func isAllowed(askPermission: Bool = false, completion: @escaping ((CLAuthorizationStatus) -> Void)) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            if askPermission {
                NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                                       name: UIApplication.didBecomeActiveNotification, object: nil)
                locationManager.requestWhenInUseAuthorization()
                permissionCompletion = completion
            } else {
                completion(.notDetermined)
            }
        case .authorizedAlways, .authorizedWhenInUse:
            completion(.authorizedWhenInUse)
        default:
            completion(.denied)
        }
    }
    
    // MARK: FetchLocation
    func checkLocationPermissionAndFetchLocation(completion: @escaping ((CLLocationCoordinate2D) -> Void)) {
        self.locationCompletion = completion
        let status = locationManager.authorizationStatus
        locationManager.delegate = self
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            self.locationCompletion(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        }
    }
    
    // MARK: FetchSSID
    func checkLocationPermissionAndFetchSSID(completion: @escaping ((String) -> Void)) {
        self.ssidCompletion = completion
        
        if #available(iOS 13.0, *) {
            let status = locationManager.authorizationStatus
            if status == .notDetermined {
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
            } else {
                self.ssidCompletion?(getSSID())
            }
        } else {
            self.ssidCompletion?(getSSID())
        }
    }
    
    func getSSID() -> String {
        var ssid = "No SSID found"
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = (interfaceInfo[kCNNetworkInfoKeySSID as String] as? String)!
                    break
                }
            }
        }
        return ssid
    }
    
    @objc func applicationDidBecomeActive() {
        NotificationCenter.default.removeObserver(self)
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            permissionCompletion?(.authorizedWhenInUse)
        default:
            permissionCompletion?(.notDetermined)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("LocationManager > didChangeAuthorization > Status : \(status.rawValue)")
        self.ssidCompletion?(getSSID())
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("LocationManager > locations = \(locValue.latitude) \(locValue.longitude)")
        self.locationCompletion(manager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.logError("LocationManager > \(error)")
        self.locationCompletion(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    }
}
