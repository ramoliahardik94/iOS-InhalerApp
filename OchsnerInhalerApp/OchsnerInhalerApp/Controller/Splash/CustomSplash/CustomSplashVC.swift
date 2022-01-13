//
//  CustomSplashVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 13/01/22.
//

import Foundation

class CustomSplashVC: BaseVC {
    
    
    override func viewDidLoad() {
        
        _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.didFinishTimer), userInfo: nil, repeats: false)
        
    }
    
    @objc func didFinishTimer() {
        let vc = LoginVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
        pushVC(vc: vc)
    }
    
    deinit {
        debugPrint("deinit CustomSplashVC")
    }
    
}
