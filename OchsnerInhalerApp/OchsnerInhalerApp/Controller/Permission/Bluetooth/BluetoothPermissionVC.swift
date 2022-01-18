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
        lblBluetoothPermission.textColor = .black
        btnCancel.setButtonView(StringCommonMessages.cancel)
        btnGrant.setButtonView(StringCommonMessages.grant)
        setCustomFontLabel(label: lblBluetoothPermission, type: .bold,fontSize: 32)
     
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
        let vc = CancleBluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
        pushVC(vc: vc)
    }


}
