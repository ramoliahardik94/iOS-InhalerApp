//
//  LocationManager.swift


import UIKit
import CoreLocation
import SystemConfiguration.CaptiveNetwork

class LocationManager: CLLocationManager {
    // MARK: Properties
    static var shared = LocationManager()
    var locationManager = CLLocationManager()
    var ssidCompletion: ((String) -> Void)!
    var locationCompletion: ((CLLocationCoordinate2D) -> Void)!
    var permissionCompletion: ((CLAuthorizationStatus) -> Void)?
    var cordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var lat: String = ""
    var long: String = ""
    override init() {
        super.init()
        if UserDefaultManager.isGrantLaocation {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
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
            // completion(cordinate)
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
            print("permissionCompletion")
            permissionCompletion?(.authorizedWhenInUse)
        default:
            print("permissionCompletion")
            permissionCompletion?(.notDetermined)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func offLocation() {
        LocationManager.shared.locationManager.stopUpdatingLocation()
        LocationManager.shared.locationManager.delegate = nil
        LocationManager.shared.cordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("LocationManager > didChangeAuthorization > Status : \(status.rawValue)")
        self.ssidCompletion?(getSSID())
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        // print("LocationManager > locations = \(locValue.latitude) \(locValue.longitude)")
        cordinate = manager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        if self.locationCompletion != nil {
            self.locationCompletion(manager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.logError("LocationManager > \(error)")
        if self.locationCompletion != nil {
            self.locationCompletion(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        }
    }
}
