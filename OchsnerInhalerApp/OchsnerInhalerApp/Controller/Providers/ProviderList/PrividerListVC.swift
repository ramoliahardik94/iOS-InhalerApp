//
//  PrividerListVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class PrividerListVC: BaseVC {
    @IBOutlet weak var lblLogin: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblLogin.text = StringPoviders.selectOrganization
    }
    

    @IBAction func tapBack(_ sender: UIButton) {
        popVC()
    }

}
