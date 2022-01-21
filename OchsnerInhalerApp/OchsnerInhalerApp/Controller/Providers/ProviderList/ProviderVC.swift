//
//  ProviderVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 17/01/22.
//

import UIKit

class ProviderVC: BaseVC {

    @IBOutlet weak var imgProvider: UIImageView!

    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var viewProvider: UIView!
    @IBOutlet weak var btnLogin: UIButton!
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setVC()
        // Do any additional setup after loading the view.
    }
    func setVC(){
      
        viewProvider.backgroundColor = .Color_ProviderView
        viewAlert.isOchsnerView = true
        btnLogin.setButtonViewGreen(StringPoviders.continueProvider)
        if index == 1 {
            imgProvider.image = UIImage(named: "provider")
        } else if index == 2{
            imgProvider.image = UIImage(named: "provider1")
        }else {
            imgProvider.image = UIImage(named: "provider2")
        }
    }
    
    
    @IBAction func btnLoginClick(_ sender: Any) {
        let vc  = BluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
        pushVC(vc: vc)
    }
    @IBAction func btnSwitchOrganization(_ sender: Any) {
        self.popVC()
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
