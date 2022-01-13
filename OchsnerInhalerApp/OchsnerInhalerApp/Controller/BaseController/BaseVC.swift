//
//  BaseVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
    func pushVC(vc : UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
  

}
