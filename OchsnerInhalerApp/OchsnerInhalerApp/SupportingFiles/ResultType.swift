//
//  ResultType.swift

enum APIResult {
    case success(Bool)
    case failure(String)
}

enum MQTTResult {
    case success(Any)
    case failure(String)
}
