//
//  Global.swift

import UIKit

class Constants: NSObject {
    
    static let appdel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    static let deviceName = "ochsner inhaler tracker"
    static let ScreenWidth  =  UIScreen.main.bounds.size.width
    static let ScreenHeight =  UIScreen.main.bounds.size.height
    
    static let DelayActuationAPICall =  0.5
    static let TimerScanAddtime =  15.0
    static let TimerScanAutoConnect =  30.0
    static let ScanningScreenDelay = 10.0
    static let PairDialogDelay = 15.0
    static let AppContainsFirmwareVersion = "1.0.4"
    static let firmwareFileName = "ble_tracker_v1.0.7_ota"
   
    
    static let titleFont = (UIFont(name: AppFont.AppBoldFont, size: 18))!
    static let titleColor = UIColor.white
    struct CustomFont {
        static let SFProTextSemibold = "SFProText-Semibold"
        static let SFProTextRegular = "SFProText-Regular"
        static let SFProDisplayBold = "SFProDisplay-Bold"
        static let SFProDisplayLightItalic = "SFProDisplay-LightItalic"
        static let SFProDisplayLight = "SFProDisplay-Light"
        static let SFProTextBold = "SFProText-Bold"
        static let SFProDisplayBoldItalic = "SFProDisplay-BoldItalic"
    }
  
    
}
var isAlertVersionDisplay = false

enum FontType {
    case regular
    case semiBold
    case bold
    case lightItalic
    case light
}
enum AddDeviceSteps {
    case step1 // "Add Device"
    case step2 // "Remove battery Isolation tag" step2 and step3 both are now combilde
    case step3 // "scan Device"
    case step4 // "Pair Device"
    case step5 // "Mount device to inhaler"
    case step6 // "let us now what inhaler medicine into"
 }
