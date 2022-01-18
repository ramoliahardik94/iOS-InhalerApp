//
//  CustomSplashVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 13/01/22.
//

import Foundation
import UIKit
class CustomSplashVC: BaseVC {
    
    @IBOutlet weak var lblCopyRight: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    @IBOutlet weak var lblConnectdInhalerSensor: UILabel!
   
    override func viewDidLoad() {
        
        _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.didFinishTimer), userInfo: nil, repeats: false)
        
        
        lblCopyRight.text = StringCommonMessages.copyRight
        lblConnectdInhalerSensor.text = StringSplash.connectdInhalerSensor
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        lblVersion.text = "V\(appVersion ?? "1")"
       
        setCustomFontLabel(label: lblConnectdInhalerSensor, type: .semiBold,fontSize: 22)
        setCustomFontLabel(label: lblCopyRight, type: .regular,fontSize: 12)
        setCustomFontLabel(label: lblVersion, type: .regular,fontSize: 12)
        lblConnectdInhalerSensor.textColor = .Color_SplashText
        lblVersion.textColor = .black
        lblCopyRight.textColor = .black
        
//        for fontFamily in UIFont.familyNames
//        {
//            print("Font family name = \(fontFamily as String)")
//            for fontName in UIFont.fontNames(forFamilyName: fontFamily as String)
//            {
//                print("- Font name = \(fontName)")
//            }
//        }
        
    }
    
    @objc func didFinishTimer() {
        let vc = LoginVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
        pushVC(vc: vc)
       
    }
    
    deinit {
        debugPrint("deinit CustomSplashVC")
    }
    
}
