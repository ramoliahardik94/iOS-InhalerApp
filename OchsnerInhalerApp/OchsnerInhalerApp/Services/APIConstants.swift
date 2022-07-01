//
//  APIConstants.swift

import Foundation
import Alamofire

struct CommanHeader {
    static let appType = "CLIENT_APP"
}
struct BaseAPIURL {
    // production
    static let cloudProd = "https://inhlrtrackdev.ochsner.org/api/"
    static let localProd = "https://inhlrtrackdev.ochsner.org/api/"
    
    // development
    static let cloudDev = "https://inhlrtrackdev.ochsner.org/api/"
    static let localDev = "https://inhlrtrackdev.ochsner.org/api/"
}

enum EnvironmentType {
    case prod
    case dev
}

enum CommunicationType {
    case local // only local no internet
    case cloud // only internet no local
    //    case localCloud // local with internet
    case none // no internet no local
}

enum APIMethod {
    case post
    case get
    case put
    case delete
    
    // MARK: - HTTPMethod
    var method: HTTPMethod {
        switch self {
        case .post:
            return HTTPMethod.post
        case .get:
            return HTTPMethod.get
        case .put:
            return HTTPMethod.put
        case .delete:
            return HTTPMethod.delete
        }
    }
}


class BaseURLManager: NSObject {
    static let shared = BaseURLManager()
    var environment: EnvironmentType = .dev
    var currentCommunication: CommunicationType = .cloud
    
    func getBaseURL() -> String {
        switch (environment, currentCommunication) {
        case (.prod, .cloud):
            return BaseAPIURL.cloudProd
        case (.prod, .local):
            return BaseAPIURL.localProd
        case (.dev, .cloud):
            return BaseAPIURL.cloudDev
        case (.dev, .local):
            return BaseAPIURL.localDev
        case (_, .none):
            return ""
        }
    }
    
    func getCloudURL() -> String {
        switch environment {
        case .prod:
            return BaseAPIURL.cloudProd
        case .dev:
            return BaseAPIURL.cloudDev
        }
    }
    
    func getLocalURL() -> String {
        switch environment {
        case .prod:
            return BaseAPIURL.localProd
        case .dev:
            return BaseAPIURL.localDev
        }
    }
}
