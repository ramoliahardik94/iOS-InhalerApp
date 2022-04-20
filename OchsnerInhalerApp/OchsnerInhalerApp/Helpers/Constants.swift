//
//  Global.swift

import UIKit

class Constants: NSObject {
    
    static let appdel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    static let deviceName = "ochsner inhaler tracker"
    static let ScreenWidth  =  UIScreen.main.bounds.size.width
    static let ScreenHeight =  UIScreen.main.bounds.size.height
    
    static let DelayActuationAPICall =  2.0
    static let TimerScanAddtime =  15.0
    static let TimerScanAutoConnect =  30.0
    static let ScanningScreenDelay = 15.0
    static let PairDialogDelay = 15.0
    
    
    
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
