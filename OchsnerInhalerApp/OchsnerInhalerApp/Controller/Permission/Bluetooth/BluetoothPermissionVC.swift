//
//  BluetoothPermissionVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit
import CoreBluetooth
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
        btnCancel.isHidden = true
     
    }
    

    deinit {
        debugPrint("deinit LoginVC")
    }
    
    
    //MARK: Actions
    @IBAction func tapGrant(_ sender: UIButton) {
        
        BluetoothManager.shared.isAllowed { isAllow in
            if isAllow {
                UserDefaultManager.isGrantBLE = true
                let vc = LocationPermisionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.pushVC(vc: vc)
            }
          }
    }
    
    @IBAction func tapCancel(_ sender: UIButton) {
        let vc = CancleBluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
        pushVC(vc: vc)
    }
    func isBluetoothAuthorized() -> Bool {
        if #available(iOS 13.0, *) {
            return CBManager.authorization == .allowedAlways
        }else {
            return CBPeripheralManager.authorizationStatus() == .authorized
        }
       
    }

}
