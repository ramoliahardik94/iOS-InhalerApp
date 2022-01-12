//
//  HomeVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class HomeVC: BaseVC {

    
    @IBOutlet weak var lbHome: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbHome.text = StringUserManagement.login
    }
    
    


}
