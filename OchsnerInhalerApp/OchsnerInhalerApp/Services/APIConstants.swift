//
//  APIConstants.swift

import Foundation
import Alamofire

struct CommanHeader {
    static let app_type = "CLIENT_APP"
}
struct BaseAPIURL {
    //production
    static let cloud_prod = "https://inhlrtrackdev.ochsner.org/api/"
    static let local_prod = "https://inhlrtrackdev.ochsner.org/api/"
    
    //development
    static let cloud_dev = "https://inhlrtrackdev.ochsner.org/api/"
    static let local_dev = "https://inhlrtrackdev.ochsner.org/api/"
}

enum EnvironmentType {
    case prod
    case dev
}

enum CommunicationType {
    case local //only local no internet
    case cloud //only internet no local
    //    case localCloud // local with internet
    case none //no internet no local
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
            return BaseAPIURL.cloud_prod
        case (.prod, .local):
            return BaseAPIURL.local_prod
        case (.dev, .cloud):
            return BaseAPIURL.cloud_dev
        case (.dev, .local):
            return BaseAPIURL.local_dev
        case (_, .none):
            return ""
        }
    }
    
    func getCloudURL() -> String {
        switch environment {
        case .prod:
            return BaseAPIURL.cloud_prod
        case .dev:
            return BaseAPIURL.cloud_dev
        }
    }
    
    func getLocalURL() -> String {
        switch environment {
        case .prod:
            return BaseAPIURL.local_prod
        case .dev:
            return BaseAPIURL.local_dev
        }
    }
}
