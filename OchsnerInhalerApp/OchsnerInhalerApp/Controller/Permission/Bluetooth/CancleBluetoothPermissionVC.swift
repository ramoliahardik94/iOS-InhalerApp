//
//  CancleBluetoothPermissionVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 18/01/22.
//

import UIKit

class CancleBluetoothPermissionVC: BaseVC {
    @IBOutlet weak var lblBluetoothPermission: UILabel!
    @IBOutlet weak var btnGrant: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblBluetoothPermission.text = StringPermissions.sorrybluetoothPermission
        lblBluetoothPermission.textColor = .black
        btnGrant.setButtonView(StringCommonMessages.grant)
        setCustomFontLabel(label: lblBluetoothPermission, type: .bold, fontSize: 32)
     
    }
    
    @IBAction func tapGrant(_ sender: UIButton) {
        popVC()
    }
    deinit {
        Logger.logInfo("deinit CancleBluetoothPermissionVC")
    }
}
