//
//  UITableView+Extension.swift

import UIKit

extension UITableView {
    func setEmptyMessage(_ message: String) {
        self.separatorStyle = .none
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .Empty_Table_Font_Color
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: AppFont.AppRegularFont, size: 20)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }

    func restore() {
        self.backgroundView = nil
    }
    
    func addSpinner(isBottom: Bool = true) {
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 44))
        spinner.startAnimating()
        //spinner.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
        spinner.color = .Color_Blue
        if isBottom {
            tableFooterView = spinner
            tableFooterView?.isHidden = false
        } else {
            self.backgroundView = spinner
        }
    }
}

extension UITableViewCell {
       var viewControllerForTableView: UIViewController? {
           return ( self.superview as? UITableView )?.delegate as? UIViewController
       }
}
