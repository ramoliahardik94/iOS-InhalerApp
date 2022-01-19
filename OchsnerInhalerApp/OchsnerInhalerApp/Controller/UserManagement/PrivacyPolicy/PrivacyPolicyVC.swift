//
//  PrivacyPolicyVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 18/01/22.
//

import UIKit

class PrivacyPolicyVC: BaseVC {

    @IBOutlet weak var lblPrivacyPolicy: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblPrivacyPolicy.text = StringPermissions.privacyPolicy
    }
    

    @IBAction func tapBack(_ sender: Any) {
        popVC()
    }
    

}
