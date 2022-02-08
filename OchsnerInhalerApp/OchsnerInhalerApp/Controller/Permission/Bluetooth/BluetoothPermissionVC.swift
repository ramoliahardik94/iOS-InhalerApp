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
        setCustomFontLabel(label: lblBluetoothPermission, type: .bold, fontSize: 32)
        btnCancel.isHidden = true
     
    }
    

    deinit {
        debugPrint("deinit LoginVC")
    }
    
    
    // MARK: Actions
    @IBAction func tapGrant(_ sender: UIButton) {
        BLEHelper.shared.setDelegate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            BLEHelper.shared.isAllowed { isAllow in
                debugPrint("isAllow  \(isAllow)")
                if isAllow {
                    UserDefaultManager.isGrantBLE = true
                    let locationPermisionVC = LocationPermisionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                    self.pushVC(controller: locationPermisionVC)
                } else {
                    CommonFunctions.showMessage(message: ValidationMsg.bluetooth, { action in
                        if action ?? true {
                            CommonFunctions.openBluetooth()
                        }
                    })
                }
                
            }
        })
    }
    
    @IBAction func tapCancel(_ sender: UIButton) {
        let cancleBluetoothPermissionVC = CancleBluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
        pushVC(controller: cancleBluetoothPermissionVC)
    }
    func isBluetoothAuthorized() -> Bool {
        if #available(iOS 13.0, *) {
            return CBManager.authorization == .allowedAlways
        } else {
            return CBPeripheralManager.authorizationStatus() == .authorized
        }
       
    }

}
