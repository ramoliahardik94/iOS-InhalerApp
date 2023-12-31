//
//  APIRouter.swift

import Foundation
import Alamofire

enum APIRouter {
    case createAccount
    case login
    case forgote
    case refreshToken
    case medication
    case device
    case providerList
    case providerAuth
    case dashboard
    case deviceuse
    case user // this is for profile
    case upgradeerror
    case appVersion
    
    // MARK: - Path
    var path: String {
        switch self {
        case .login:
            return BaseURLManager.shared.getBaseURL() + "login"
        case .createAccount :
            return BaseURLManager.shared.getBaseURL() + "user"
        case .refreshToken :
            return BaseURLManager.shared.getBaseURL() + "login"
        case .medication :
            return BaseURLManager.shared.getBaseURL() + "medication"
        case .device :
            return BaseURLManager.shared.getBaseURL() +  "device"
        case .providerList :
            return BaseURLManager.shared.getBaseURL() + "ProviderList"
        case .providerAuth :
            return BaseURLManager.shared.getBaseURL() + "LinkUser"
        case .dashboard :
            return BaseURLManager.shared.getBaseURL() + "dashboard"
        case .deviceuse :
            return BaseURLManager.shared.getBaseURL() + "deviceuse"
        case .user :
            return BaseURLManager.shared.getBaseURL() + "user"
        case .forgote :
            return BaseURLManager.shared.getBaseURL() + "forgotpassword"
        case .upgradeerror:
            return BaseURLManager.shared.getBaseURL() + "upgradeerror"
        case .appVersion:
            return BaseURLManager.shared.getBaseURL() + "version"            
        }
    }
    

    
    func getPathWithLastKey(_ key: String?) -> String {
        if let key = key?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return path + "?lastEvaluatedKey=\(key)"
        }
        return path
    }
}
