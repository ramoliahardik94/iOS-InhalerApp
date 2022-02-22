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
        lblConnectProvider.font = UIFont(name: AppFont.AppBoldFont, size: 34)        
        btnSelectProvider.setButtonView(StringPoviders.selectProvider)
        btnSkipNow.setButtonViewGrey(StringPoviders.skipForNow)
        
    }
    
    
      // MARK: Actions
    @IBAction func tapSelectProvider(_ sender: UIButton) {
        let providerListVC = ProviderListVC.instantiateFromAppStoryboard(appStoryboard: .providers)
        pushVC(controller: providerListVC)
    }
    @IBAction func tapSkipNow(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let homeTabBar  = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
       
        //homeTabBar.selectedIndex = 1
        rootVC(controller: homeTabBar)
    }
    
    @IBAction func tapBack(_ sender: UIButton) {
        popVC()
    }
    
}
