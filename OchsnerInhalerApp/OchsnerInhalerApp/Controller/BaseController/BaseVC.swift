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
    
    func setCustomFontTextField(textField : UITextField , type : FontType , fontSize : CGFloat = 14) {
        if type == .regular {
            textField.font = UIFont(name: AppFont.AppRegularFont, size: fontSize)
        }
        if type == .bold {
            textField.font = UIFont(name: AppFont.AppBoldFont, size: fontSize)
        }
        if type == .semiBold {
            textField.font = UIFont(name: AppFont.AppSemiBoldFont, size: fontSize)
        }
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
}
