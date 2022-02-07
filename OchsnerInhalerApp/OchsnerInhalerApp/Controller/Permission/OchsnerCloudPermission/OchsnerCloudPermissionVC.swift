//
//  OchsnerCloudPermissionVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 13/01/22.
//

import UIKit

class OchsnerCloudPermissionVC: BaseVC {
    @IBOutlet weak var lblShareYourInhalerUsage: UILabel!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lbOneLastThing: UILabel!
    @IBOutlet weak var lbConnectSensor: UILabel!
    @IBOutlet weak var lbKeepYourOchsner: UILabel!
    @IBOutlet weak var btnPrivacyPolicy: UIButton!
    @IBOutlet weak var lbShareYourInhaler: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblShareYourInhalerUsage.text = StringPermissions.shareYourInhalerUsage
        lbOneLastThing.text = StringPermissions.oneLastThing
        lbConnectSensor.text = StringAddDevice.ConnectedInhalerSensor
        lbKeepYourOchsner.text = StringPermissions.keepYourOchsner
        lbShareYourInhaler.text = StringPermissions.shareYourInhaler
        
        
        setCustomFontLabel(label: lbOneLastThing, type: .bold, fontSize: 32)
        setCustomFontLabel(label: lblShareYourInhalerUsage, type: .bold, fontSize: 32)
        setCustomFontLabel(label: lbConnectSensor, type: .semiBold, fontSize: 20)
        setCustomFontLabel(label: lbKeepYourOchsner, type: .regular, fontSize: 20)
        setCustomFontLabel(label: lbShareYourInhaler, type: .semiBold, fontSize: 20)
      
        
        
        btnShare.setButtonView(StringCommonMessages.share)
        btnSkip.setTitle(StringCommonMessages.skip, for: .normal)
        btnSkip.backgroundColor = .ColorGray
        btnSkip.setTitleColor(.ColorWhite, for: .normal)
        btnSkip.layer.cornerRadius = 5
        btnSkip.titleLabel?.font = UIFont(name: AppFont.AppSemiBoldFont, size: 17)
        
        let textColor =  #colorLiteral(red: 0.03921568627, green: 0.4784313725, blue: 1, alpha: 1) // #0A7AFF
        btnPrivacyPolicy.setTitleColor(textColor, for: .normal)
        btnPrivacyPolicy.setTitle(StringPermissions.privacyPolicy, for: .normal)
        btnPrivacyPolicy.titleLabel?.font = UIFont(name: AppFont.AppRegularFont, size: 16)
    }
    

        // MARK: Actions
    @IBAction func tapShare(_ sender: UIButton) {
        
        let connectProviderVC = ConnectProviderVC.instantiateFromAppStoryboard(appStoryboard: .providers)
       // let vc = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        pushVC(controller: connectProviderVC)
        
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        let vc  = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
//        pushVC(vc: vc)
    }
    
    @IBAction func tapSkip(_ sender: UIButton) {
        popVC()
    }
 
    @IBAction func tapPrivacyPolicy(_ sender: Any) {
        let privacyPolicyVC  = PrivacyPolicyVC.instantiateFromAppStoryboard(appStoryboard: .userManagement)
        pushVC(controller: privacyPolicyVC)
    }
    
}
