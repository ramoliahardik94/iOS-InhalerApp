//
//  ConnectProviderVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 13/01/22.
//

import UIKit

class ConnectProviderVC: BaseVC {
    
    @IBOutlet weak var lblConnectProvider: UILabel!
    
    @IBOutlet weak var btnSelectProvider: UIButton!
    @IBOutlet weak var btnSkipNow: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initUI()
    }
    
    private func initUI() {
        lblConnectProvider.text = StringPoviders.providerConnectLabel
        lblConnectProvider.font = UIFont(name: AppFont.AppBoldFont, size: 26)
        
        
//        for item in  UIFont.familyNames {
//
//            debugPrint("array font \(item)")
//
//        }
       
        
        btnSelectProvider.setTitle(StringPoviders.selectProvider, for: .normal)
        btnSkipNow.setTitle(StringPoviders.skipForNow, for: .normal)
        
        btnSelectProvider.backgroundColor = .Button_Color_Blue
        btnSelectProvider.setTitleColor(.Color_White, for: .normal)
        
        btnSkipNow.backgroundColor = .Color_Gray
        btnSkipNow.setTitleColor(.Color_White, for: .normal)
        
       
        
    }
    
    
    //MARK: Actions
    @IBAction func tapSelectProvider(_ sender: UIButton) {
        let vc = ProviderListVC.instantiateFromAppStoryboard(appStoryboard: .providers)
        pushVC(vc: vc)
    }
    @IBAction func tapSkipNow(_ sender: UIButton) {
        let vc = BluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
        pushVC(vc: vc)
    }
    
    @IBAction func tapBack(_ sender: UIButton) {
        popVC()
    }
    
}
