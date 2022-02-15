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
        lblBluetoothPermission.setFont(type: .bold, point: 32)
    }
    
    @IBAction func tapGrant(_ sender: UIButton) {
        popVC()
    }
    deinit {
        print("deinit CancleBluetoothPermissionVC")
    }
}
