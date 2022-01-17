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
  

    func setCustomFontLabel(label : UILabel , type : FontType , fontSize : CGFloat = 14) {
        if type == .regular {
            label.font = UIFont(name: AppFont.AppRegularFont, size: fontSize)
        }
        if type == .bold {
            label.font = UIFont(name: AppFont.AppBoldFont, size: fontSize)
        }
        if type == .semiBold {
            label.font = UIFont(name: AppFont.AppSemiBoldFont, size: fontSize)
        }
    }
}
