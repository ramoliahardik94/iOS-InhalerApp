//
//  AddAnotherDeviceVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 19/01/22.
//

import UIKit

class AddAnotherDeviceVC: BaseVC {
    @IBOutlet weak var lblGreat: UILabel!
    @IBOutlet weak var lblAddDevice: UILabel!
    @IBOutlet weak var btnAddAnotherDevice: UIButton!
    @IBOutlet weak var btnGoHome: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        // Do any additional setup after loading the view.
    }
    
    func setUI(){
        lblGreat.font = UIFont(name: AppFont.AppBoldFont, size: 34)
        lblGreat.text = StringAddDevice.great
        lblAddDevice.font = UIFont(name: AppFont.AppBoldFont, size: 34)
        lblAddDevice.text =  StringAddDevice.addAnotherDevice
        
        btnGoHome.setButtonView(StringAddDevice.goHome)
        btnAddAnotherDevice.setButtonView(StringAddDevice.addAnotherDeviceBtn)
    }
    
    @IBAction func btnGohomeClick(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc  = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
        pushVC(vc: vc)
    }
    
    @IBAction func btnAnotherDeviceClick(_ sender: Any) {
        let vc = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        vc.step = .Step2
        vc.isFromAddAnother  = true
        pushVC(vc: vc)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
