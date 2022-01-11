//
//  APIRouter.swift

import Foundation
import Alamofire

enum APIRouter {
    case login
    case logout
    case weather
    case eula
    case verifyEula(userId: String)
    case checkEmail
    case forgotPassword
    case fetchSecretQuestion(email: String)
    case verifySecretQuestion(email: String)
    case sendOTP
    case verifyOTP
    case resetPassword
    case refreshToken
    case connectionStatus
    case updateBurglary(userId: String)
    case updatePushToken
    case updateLocation
    case addHubUserCode
    case panicButton
    case deviceList(id: String)
    case addSubUser
    case secretQuestion
    case subUserListByHubId(locationId: String, hubId: String)
    case removeSubUser(hubId: String, locationId: String, userId: String)
    case editSubUser(userId: String)
    case fetchHubCodes(userId: String, hubId: String)
    case fetchAllQuestions
    case updateUser(userId: String)
    case updateNameSystem(hubId: String)
    case updateUserContact(userId: String, hubId: String)
    case fetchTermsData(url: String)
    case setSubUserStatus(userId: String, hubId: String)
    case logoutAllDevices
    case setUserHubCode
    case fetchAllLocation(userId: String)
    case makePreferedPartion(partitionId: String)
    case sendSettingOTP
    case fetchSubUser(code: String)
    case signupSubUser
    case securityTimer(partitionId: String)
    case savePreferences
    case fetchCustomerAccessCode(hubId: String)
    case addCustomerAccessCode
    case deleteCustomerAccessCode(codeId: String)
    case fetchWeather(hubId: String)
    case fetchHubdata(userId: String, hubId: String)
    case fetchNotificationList(hubId: String, type: String)
    case fetchUserInfo(userId: String)
    case fetchUserQuestionAnswer
    case senserDeviceProperty
    case deviceEvents(deviceId: String)
    case fetchMessageCenterList(hubId: String)
    case updateSingleMessage(hubId: String, messageId: String)
    case setAmbushHubCode(hubId: String)
    case fetchAmbushHubCode(hubId: String)
    case fetchAlarmWithHubdata(userId: String, hubId: String)
    case fetchAlarmInfo(alarmId: String)
    case fetchCurrentAlarm(partitionId: String)

    // MARK: - Path
    var path: String {
        switch self {
        case .login:
            return BaseURLManager.shared.getBaseURL() + "auth/login"
        case .logout:
            return BaseURLManager.shared.getBaseURL() + "auth/logout"
        case .refreshToken:
            return BaseURLManager.shared.getBaseURL() + "auth/refreshToken"
        case .eula:
            return BaseURLManager.shared.getBaseURL() + "systemInfo/fetchLatestEULA"
        case .verifyEula(let userId):
            return BaseURLManager.shared.getBaseURL() + "user/eulaAccept/\(userId)"
        case .checkEmail:
            return BaseURLManager.shared.getBaseURL() + "auth/checkEmail"
        case .forgotPassword:
            return BaseURLManager.shared.getCloudURL() + "auth/forgotPassword"
        case .fetchSecretQuestion(let email):
            return BaseURLManager.shared.getBaseURL() + "auth/secretQuestion/\(email)"
        case .verifySecretQuestion(let email):
            return BaseURLManager.shared.getBaseURL() + "auth/verifySecretQuestion/\(email)"
        case .sendOTP:
            return BaseURLManager.shared.getCloudURL() + "auth/sendOtp"
        case .verifyOTP:
            return BaseURLManager.shared.getCloudURL() + "auth/verifyOtp"
        case .resetPassword:
            return BaseURLManager.shared.getCloudURL() + "auth/updatePassword"
        case .weather:
            if BaseURLManager.shared.currentCommunication == .cloud {
                return BaseURLManager.shared.getCloudURL()
            }
            return BaseURLManager.shared.getLocalURL()
        case .connectionStatus:
            return BaseURLManager.shared.getCloudURL() + "server"
        case .updateBurglary(let userId):
            return BaseURLManager.shared.getBaseURL() + "user/\(userId)"
        case .updatePushToken:
            return BaseURLManager.shared.getBaseURL() + "notification/"
        case .updateLocation:
            return BaseURLManager.shared.getBaseURL() + "user/location/"
        case .addHubUserCode:
            return BaseURLManager.shared.getBaseURL() + "user/addHubUserCode/"
        case .panicButton:
            return BaseURLManager.shared.getBaseURL() + "event/"
        case .deviceList(let id):
            return BaseURLManager.shared.getBaseURL() + "clientDashboard/devices/\(id)"
        case .addSubUser:
            return BaseURLManager.shared.getBaseURL() + "user/subUser"
        case .secretQuestion:
            return BaseURLManager.shared.getBaseURL() + "secretQuestion/"
        case .subUserListByHubId(let locationId, let hubId):
            return BaseURLManager.shared.getBaseURL() + "user/subUser/\(hubId)/\(locationId)"
        case .removeSubUser(let hubId, let locationId, let userId):
            return BaseURLManager.shared.getBaseURL() + "user/subUser/\(hubId)/\(locationId)/\(userId)"
        case .editSubUser(let userId):
            return BaseURLManager.shared.getBaseURL() + "user/subUser/\(userId)"
        case .fetchHubCodes(let userId, let hubId):
            return BaseURLManager.shared.getBaseURL() + "user/subUser/hubUserCode/\(hubId)/\(userId)"
        case .fetchAllQuestions:
            return BaseURLManager.shared.getBaseURL() + "auth/list/secretQuestion"
        case .updateUser(let userId):
            return BaseURLManager.shared.getBaseURL() + "user/\(userId)"
        case .updateUserContact(let userId, let hubId):
            return BaseURLManager.shared.getBaseURL() + "settings/\(userId)/\(hubId)"
        case .updateNameSystem(let hubId):
            return BaseURLManager.shared.getBaseURL() + "settings/\(hubId)"
        case .fetchTermsData(let url):
            return BaseURLManager.shared.getBaseURL() + "menu/\(url)"
        case .setSubUserStatus(let userId, let hubId):
            return BaseURLManager.shared.getBaseURL() + "user/subUser/\(hubId)/\(userId)"
        case .logoutAllDevices:
            return BaseURLManager.shared.getBaseURL() + "auth/globalLogout"
        case .setUserHubCode:
            return BaseURLManager.shared.getBaseURL() + "user/addHubUserCode"
        case .fetchAllLocation(let userId):
            return BaseURLManager.shared.getBaseURL() + "settings/listLocationPartition/\(userId)"
        case .sendSettingOTP:
            return BaseURLManager.shared.getCloudURL() + "settings/sendOtp"
        case .fetchSubUser(let code):
            return BaseURLManager.shared.getCloudURL() + "user/signupSubUser/\(code)"
        case .signupSubUser:
            return BaseURLManager.shared.getCloudURL() + "user/signupSubUser"
        case .securityTimer(let partitionId):
            return BaseURLManager.shared.getCloudURL() + "settings/delay/\(partitionId)"
        case .savePreferences:
            return BaseURLManager.shared.getCloudURL() + "settings/preferences"
        case .makePreferedPartion(let partitionId):
            return BaseURLManager.shared.getBaseURL() + "partition/prefered/\(partitionId)"

        case .fetchCustomerAccessCode(let hubId):
            return BaseURLManager.shared.getBaseURL() + "settings/customer/access/code/\(hubId)"
        case .addCustomerAccessCode:
            return BaseURLManager.shared.getCloudURL() + "settings/customer/access/code"
        case .deleteCustomerAccessCode(let codeId):
            return BaseURLManager.shared.getBaseURL() + "settings/customer/access/code/\(codeId)"
        case .fetchWeather(let hubId):
            return BaseURLManager.shared.getCloudURL() + "weather/\(hubId)"
        case .fetchHubdata(let userId, let hubId):
            return BaseURLManager.shared.getBaseURL() + "hub/\(hubId)/\(userId)"
        case .fetchNotificationList(let hubId, let type):
            return BaseURLManager.shared.getBaseURL() + "event/\(hubId)/\(type)"
        case .fetchUserInfo(let userId):
            return BaseURLManager.shared.getBaseURL() + "user/\(userId)"
        case .fetchUserQuestionAnswer:
            return BaseURLManager.shared.getBaseURL() + "settings/fetchUserQuestionAnswers"
        case .senserDeviceProperty:
            return BaseURLManager.shared.getBaseURL() + "menu/deviceProperties"
        case .deviceEvents(let deviceId):
            return BaseURLManager.shared.getBaseURL() + "event/\(deviceId)"
        case .fetchMessageCenterList(let hubId):
            return BaseURLManager.shared.getBaseURL() + "messages/\(hubId)"
        case .updateSingleMessage(let hubId, let messageId):
            return BaseURLManager.shared.getBaseURL() + "messages/\(hubId)/\(messageId)"
        case .setAmbushHubCode(let hubId):
            return BaseURLManager.shared.getBaseURL() + "settings/ambush/code/\(hubId)"
        case .fetchAmbushHubCode(let hubId):
            return BaseURLManager.shared.getBaseURL() + "hub/\(hubId)"
        case .fetchAlarmWithHubdata(let userId, let hubId):
            return BaseURLManager.shared.getBaseURL() + "splashScreen/activeAlarm/\(hubId)/\(userId)"
        case .fetchAlarmInfo(let alarmId):
            return BaseURLManager.shared.getBaseURL() + "alarm/\(alarmId)"
        case .fetchCurrentAlarm(let partitionId):
            return BaseURLManager.shared.getBaseURL() + "/alarm/partition/\(partitionId)"
        }
    }
    
    func getPathWithLastKey(_ key: String?) -> String {
        if let key = key?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return path + "?lastEvaluatedKey=\(key)"
        }
        return path
    }
}
