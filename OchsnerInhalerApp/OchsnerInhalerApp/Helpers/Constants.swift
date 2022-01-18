//
//  Global.swift

import UIKit

class Constants: NSObject {
    
    static let appdel: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    static let ScreenWidth  =  UIScreen.main.bounds.size.width
    static let ScreenHeight =  UIScreen.main.bounds.size.height

    static let page_size = 25
    static let PIN_Length = 6
    static let HUB_Code_Length = 4
    static let MOBILE_NUMBER_Length = 13
    static let Customer_Support_Number = "+911234567890"
    static let Customer_Support_Email = "xyz@gmail.com"
    static let MQTT_Timeout = 60.0
    static let FavoriteDevices = 10.0
    static let Hub_Device_Name_Length = 20
    static let weekDays: [String] = ["MON".local, "TUE".local, "WED".local, "THU".local, "FRI".local, "SAT".local, "SUN".local]

    struct CustomFont {
        static let SFProText_Semibold = "SFProText-Semibold"
        static let SFProText_Regular = "SFProText-Regular"
        static let SFProDisplay_Bold = "SFProDisplay-Bold"
    }
    
    struct DirectoryPath {
        static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        static let Tmp = NSTemporaryDirectory()
    }
    
    struct Keys {
        static let enc_IV = "u03koH1cu4pXLz65"
        static let first16 = "3UI8b7FZBqhsavcm"
    }
}

enum FontType {
    case regular
    case semiBold
    case bold
}
