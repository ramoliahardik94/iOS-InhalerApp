//
//  UIAlertController+Extensions.swift
import UIKit

extension UIViewController {

    func presentAlert(withTitle title: String, message: String, okButtonTitle: String = "Ok".local, completion: ((Bool) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: okButtonTitle, style: .default) { _ in
            completion?(true)
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentConfirmAlert(withTitle title: String?, message: String, okButtonTitle: String = "Ok", completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: okButtonTitle.local, style: .default) { _ in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel".local, style: .default) { _ in
            completionHandler(false)
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
