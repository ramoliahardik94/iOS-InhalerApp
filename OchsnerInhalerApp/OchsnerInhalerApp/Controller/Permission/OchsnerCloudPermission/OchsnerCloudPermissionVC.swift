//
//  OchsnerCloudPermissionVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 13/01/22.
//

import UIKit

class OchsnerCloudPermissionVC: BaseVC {
    @IBOutlet weak var lblShareYourInhalerUsage: UILabel!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblShareYourInhalerUsage.text = StringPermissions.shareYourInhalerUsage
        
        btnSkip.setTitle(StringCommonMessages.skip, for: .normal)
        btnShare.setTitle(StringCommonMessages.share, for: .normal)
        
        btnShare.backgroundColor = .Button_Color_Blue
        btnShare.setTitleColor(.Color_White, for: .normal)
        
        btnSkip.backgroundColor = .Color_Gray
        btnSkip.setTitleColor(.Color_White, for: .normal)
    }
    

    //MARK: Actions
    @IBAction func tapShare(_ sender: UIButton) {
        
    }
    
    @IBAction func tapSkip(_ sender: UIButton) {
        popVC()
    }
 

}
