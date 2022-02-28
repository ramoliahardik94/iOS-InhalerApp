//
//  Global.swift

import UIKit

class Constants: NSObject {
    
    static let appdel: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    static let ScreenWidth  =  UIScreen.main.bounds.size.width
    static let ScreenHeight =  UIScreen.main.bounds.size.height

    static let pageSize = 25
    static let PINLength = 6
    static let HUBCodeLength = 4
    static let MOBILENUMBERLength = 13
    static let CustomerSupportNumber = "+911234567890"
    static let CustomerSupportEmail = "xyz@gmail.com"
    static let MQTTTimeout = 60.0
    static let FavoriteDevices = 10.0
    static let HubDeviceNameLength = 20
    static let weekDays: [String] = ["MON".local, "TUE".local, "WED".local, "THU".local, "FRI".local, "SAT".local, "SUN".local]

    struct CustomFont {
        static let SFProTextSemibold = "SFProText-Semibold"
        static let SFProTextRegular = "SFProText-Regular"
        static let SFProDisplayBold = "SFProDisplay-Bold"
        static let SFProDisplayLightItalic = "SFProDisplay-LightItalic"
        static let SFProDisplayLight = "SFProDisplay-Light"
        static let SFProTextBold = "SFProText-Bold"
        static let SFProDisplayBoldItalic = "SFProDisplay-BoldItalic"
    }
    
    struct DirectoryPath {
        static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        static let Tmp = NSTemporaryDirectory()
    }
    
    struct Keys {
        static let encIV = "u03koH1cu4pXLz65"
        static let first16 = "3UI8b7FZBqhsavcm"
    }
}

enum FontType {
    case regular
    case semiBold
    case bold
    case lightItalic
    case light
}
enum AddDeviceSteps {
    case step1 // "Add Device"
    case step2 // "Remove battery Isolation tag"
    case step3 // "scan Device"
    case step4 // "Pair Device"
    case step5 // "Mount device to inhaler"
    case step6 // "let us now what inhaler medicine into"
 }
