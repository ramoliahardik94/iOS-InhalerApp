//
//  APIRouter.swift

import Foundation
import Alamofire

enum APIRouter {
    case createAccount
    case login
    case refreshToken
    case medication
<<<<<<< HEAD
    case device
=======
    case providerList
>>>>>>> origin/development
    
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
        }
    }
    

    
    func getPathWithLastKey(_ key: String?) -> String {
        if let key = key?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return path + "?lastEvaluatedKey=\(key)"
        }
        return path
    }
}
