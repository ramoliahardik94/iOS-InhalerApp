//
//  BluetoothPermissionVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class BluetoothPermissionVC: BaseVC {
    @IBOutlet weak var lblBluetoothPermission: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnGrant: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        lblBluetoothPermission.text = StringPermissions.bluetoothPermission
        
        btnCancel.setTitle(StringCommonMessages.cancel, for: .normal)
        btnGrant.setTitle(StringCommonMessages.grant, for: .normal)
        
        btnGrant.backgroundColor = .Button_Color_Blue
        btnGrant.setTitleColor(.Color_White, for: .normal)
        
        btnCancel.backgroundColor = .Color_Gray
        btnCancel.setTitleColor(.Color_White, for: .normal)
     
    }
    

    deinit {
        debugPrint("deinit LoginVC")
    }
    
    
    //MARK: Actions
    @IBAction func tapGrant(_ sender: UIButton) {
        let vc = LocationPermisionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
        pushVC(vc: vc)
    }
    
    @IBAction func tapCancel(_ sender: UIButton) {
        popVC()
    }


}
