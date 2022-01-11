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
    typealias ResponseBlock = (_ error: RuntimeError?, _ response: BasicModel?) -> Void
    
    @discardableResult
    func performRequest(route: String, isEncoding: Bool = true, parameters: [String: Any], method: HTTPMethod, completion: ResponseBlock?) -> DataRequest? {
        if !APIManager.isConnectedToNetwork {
            Logger.LogInfo("No Internet connection")
            completion?(RuntimeError("No_Internet_Connection".local), nil)
            return nil
        }
        
        
        var encoding: ParameterEncoding = JSONEncoding.default
        if method == .get {
            encoding = URLEncoding.queryString
        }
        var appHeader = APIManager.header
        if route == APIRouter.refreshToken.path {
            appHeader = setUpHeaderDataWithRefreshToken()
        }
        Logger.LogInfo("URL:\(route) -> Method:\(method) -> Parameters: \(parameters) -> Headers:\(appHeader)")
        
        var url = route
        if isEncoding, let encoded = route.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            url = encoded
        }
        
        let request = Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: appHeader).responseJSON { (response) in
            
            switch response.result {
            case .success:
                Logger.LogInfo("Response :: success :: \(String(describing: response.value))")
                guard let basicModelObj =  BasicModel(JSON: response.value as! [String: Any]) else {
                    completion?(RuntimeError(""), nil)
                    return
                }
                guard let statusCode = basicModelObj.statusCode else {
                    completion?(RuntimeError("Status code not received."), nil)
                    return
                }
                
                if statusCode == StatusCode.tokenExpired.rawValue {
                    Logger.LogInfo("Response:: expire:: Access Token Expired")
                    self.generateNewAccessToken(route: route, parameters: parameters, method: method, completion: completion)
                } else if statusCode == StatusCode.refreshTokenExpired.rawValue {
                    Logger.LogInfo("Response:: expire:: Refresh Token Expired")
                    removeUser()
                } else if statusCode >= StatusCode.success.rawValue && statusCode < 300 {
                    completion?(nil, basicModelObj)
                } else {
                    if let message = basicModelObj.message {
                        completion?(RuntimeError(message, statusCode), nil)
                    }
                }
            case .failure:
                Logger.LogError("Add Response :: failure :: \(String(describing: response.value))")
                 completion?(RuntimeError("Server Error"), nil)
            }
        }
        
        return request
        
        //return nil
    }
    
    func generateNewAccessToken(route: String, parameters: [String: Any]?, method: HTTPMethod, completion: ResponseBlock?) {
        self.performRequest(route: APIRouter.refreshToken.path, parameters: [String: Any](), method: HTTPMethod.post) { (error, basicModel) in
            guard let basicModel = basicModel else {
                completion?(error, nil)
                return
            }
            
            if basicModel.checkStatusCode(.success) {
//                if let shareobj = UserDefaultManager.loggedInUserModel {
//                    shareobj.token = (basicModel.data["accessToken"] as! String)
//                    UserDefaultManager.loggedInUserModel = shareobj
//                }
                self.resumeAPICallwithNewAccessToken(route: route, parameters: parameters, method: method, completion: completion)
            } else {
                Logger.LogError("Add Response :: failure :: API Error Generating New Access Token -> \(error!.localizedDescription)")
                completion?(error, nil)
                return
            }
        }
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
        dictHeader["app-type"] = CommanHeader.app_type
        dictHeader["udid"] = MobileDeviceManager.shared.udid
        dictHeader["device_name"] = MobileDeviceManager.shared.name

//        if let shareobj = UserDefaultManager.loggedInUserModel {
//            dictHeader["access-token"] = String(describing: shareobj.token!)
//            dictHeader["userId"] = String(describing: shareobj.id!)
//        }
        
        return dictHeader
    }
    
    func setUpHeaderDataWithRefreshToken() -> HTTPHeaders {
        var dictHeader = HTTPHeaders()
        dictHeader["app-type"] = CommanHeader.app_type
        dictHeader["udid"] = MobileDeviceManager.shared.udid
        dictHeader["device_name"] = MobileDeviceManager.shared.name

//        if let shareobj = UserDefaultManager.loggedInUserModel {
//            dictHeader["refresh-token"] = String(describing: shareobj.refreshToken!)
//        }
//
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
