//
//  APIManager.swift
//

import UIKit
import Alamofire
import ObjectMapper

enum StatusCode: Int {
    case success = 200
    case tokenExpired = 4010
    case refreshTokenExpired = 4011
}

struct RuntimeError: Error {
    let message: String
    let statusCode: Int
    init(_ message: String, _ statusCode: Int = 0) {
        self.message = message
        self.statusCode = statusCode
    }
    public var localizedDescription: String {
        return message
    }
}

class APIManager {
    static let shared = APIManager()
    
    // MARK: Custom Variables
    typealias ResponseBlock = (_ error: RuntimeError?, _ response: Any?) -> Void
        
    @discardableResult
    func performRequest(route: String, isEncoding: Bool = true, parameters: Any, method: HTTPMethod, isBasicAuth: Bool = false, isAuth: Bool = false, showLoader: Bool = true, textLoader: String = "", isCommonMsg:Bool = false, completion: ResponseBlock?) -> DataRequest? {
        
        if !APIManager.isConnectedToNetwork {
            completion?(RuntimeError(StringCommonMessages.noInternetConnection), nil)
            return nil
        }
        
        
        var encoding: ParameterEncoding = JSONEncoding.default
        if method == .get || method == .delete {
            encoding = URLEncoding.queryString
        }
        var appHeader = APIManager.header
//        if route == APIRouter.refreshToken.path {
            appHeader = setUpHeaderDataWithRefreshToken(isAuth: isAuth)
//        }
        if isBasicAuth {
            if let param = parameters as? [String: Any] {
                let username = param["Email"] as? String
                let password = param["Password"] as? String
                let loginString = "\(username ?? ""):\(password ?? "")"
                if let loginData = loginString.data(using: String.Encoding.utf8) {
                    let base64LoginString = loginData.base64EncodedString()
                    appHeader = setUpHeaderDataWithBASICAuth(value: "Basic \(base64LoginString)")
                }
            }
        }

        Logger.logInfo("\n\n\nURL:\(route)\n Method:\(method)\nParameters: \(parameters)\nHeaders:\(appHeader)")
        var url = route
        if isEncoding, let encoded = route.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            url = encoded
        }
        if showLoader {
            CommonFunctions.showGlobalProgressHUD(UIApplication.topViewController()!, text: textLoader)
        }
        
        let request = Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: appHeader).responseJSON { (response) in
            if showLoader {
                CommonFunctions.hideGlobalProgressHUD(UIApplication.topViewController()!)
            }
            
            let statusCode = response.response?.statusCode
            if statusCode ?? 0 >= 200 && statusCode ?? 0 < 300 {
                if route == APIRouter.deviceuse.path || route == APIRouter.dashboard.path  || route == APIRouter.device.path {
                    Logger.logInfo("Response :: success  :: status code \(statusCode) :: \(route) \n\n \(String(describing: response.value!))")
                }
                switch response.result {
                case .success:
                    if let data = response.value as? [String: Any] {
                        let message = data["error"] as? String
                        if let data = response.value as? [String: Any] {
                            completion?(nil, data)
                        } else {
                            completion?(RuntimeError(message ?? ""), nil)
                        }
                    } else if let data = response.value as? [[String: Any]] {
                        completion?(nil, data)
                    } else {
                        completion?(nil, ["key": "Success"])
                    }
                case .failure:
                    completion?(RuntimeError(ValidationMsg.CommonError), nil)
                }
            } else {
                Logger.logError("Response :: failure :: status code \(statusCode) :: \(route) ::\n\n \(String(describing: response.value))")
                switch response.result {
                case .success:
                    if let data = response.value as? [String: Any] {
                        if let message = data["error"] as? String {
                            
                            completion?(RuntimeError(isCommonMsg ? ValidationMsg.CommonError : message, statusCode!), nil)
                                
                        } else if let message = data["Error"] as? String {
                            completion?(RuntimeError(isCommonMsg ? ValidationMsg.CommonError : message, statusCode!), nil)
                        }
                    } else {
                        completion?(RuntimeError(""), nil)
                    }
                case .failure:
                    completion?(RuntimeError(ValidationMsg.CommonError), nil)
                }
            }
        }
        
        return request
        
        // return nil
    }
    
    
    func resumeAPICallwithNewAccessToken(route: String, parameters: [String: Any]?, method: HTTPMethod, completion: ResponseBlock?) {
        self.performRequest(route: route, parameters: parameters!, method: method) { (error, basicModel) in
            if let basicModel = basicModel {
                completion?(nil, basicModel)
            } else {
                completion?(error, nil)
            }
        }
    }
    
    
    // MARK: - Other Methods
    static var isConnectedToNetwork: Bool {
        let network = NetworkReachabilityManager()
        return (network?.isReachable)!
    }
    
    static private var header: HTTPHeaders {
        
        var dictHeader = HTTPHeaders()
        dictHeader["app-type"] = CommanHeader.appType
        dictHeader["udid"] = MobileDeviceManager.shared.udid
        dictHeader["device_name"] = MobileDeviceManager.shared.name
        dictHeader["ac ken"] = UserDefaultManager.token
        return dictHeader
    }
    
    func setUpHeaderDataWithBASICAuth(value: String) -> HTTPHeaders {
        var dictHeader = HTTPHeaders()
        dictHeader["app-type"] = CommanHeader.appType
        dictHeader["udid"] = MobileDeviceManager.shared.udid
        dictHeader["device_name"] = MobileDeviceManager.shared.name
        dictHeader = ["Authorization": value]
        return dictHeader
    }
    
    func setUpHeaderDataWithRefreshToken(isAuth: Bool) -> HTTPHeaders {
        var dictHeader = HTTPHeaders()
        dictHeader["app-type"] = CommanHeader.appType
        dictHeader["udid"] = MobileDeviceManager.shared.udid
        dictHeader["device_name"] = MobileDeviceManager.shared.name
        if isAuth {
            dictHeader = ["Authorization": "Bearer " + UserDefaultManager.token]
        }
        return dictHeader
    }
}

class BasicModel: Mappable {
    var message: String?
    var statusCode: Int?
    var data = [String: Any]()
    var dataArray = [[String: Any]]()
    var accessToken: String?
    var lastEvaluatedKey: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        message <- map["message"]
        statusCode <- map["statusCode"]
        data <- map["data"]
        dataArray <- map["data"]
        accessToken <- map["accessToken"]
        lastEvaluatedKey <- map["lastEvaluatedKey"]
    }
    
    func checkStatusCode(_ code: StatusCode) -> Bool {
        return statusCode == code.rawValue
    }
}
