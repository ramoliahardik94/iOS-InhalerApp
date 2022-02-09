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
        NotificationCenter.default.addObserver(self, selector: #selector(self.getisAllow(notification:)), name: .BLEChange, object: nil)
    }
    

    deinit {
        Logger.logInfo("deinit LoginVC")
    }
    
    
    // MARK: Actions
    @IBAction func tapGrant(_ sender: UIButton) {
        BLEHelper.shared.setDelegate()
    }
    
    @objc func getisAllow(notification: Notification) {
        BLEHelper.shared.isAllowed { isAllow in
            Logger.logInfo("isAllow  \(isAllow)")
            if isAllow {
                UserDefaultManager.isGrantBLE = true
                let locationPermisionVC = LocationPermisionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
                self.pushVC(controller: locationPermisionVC)
            }
        }
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
