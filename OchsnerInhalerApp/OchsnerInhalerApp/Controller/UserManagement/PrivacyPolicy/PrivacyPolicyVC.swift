//
//  PrivacyPolicyVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 18/01/22.
//

import UIKit
import WebKit
class PrivacyPolicyVC: BaseVC {

    @IBOutlet weak var lblPrivacyPolicy: UILabel!
    
    @IBOutlet weak var webviewPrivacy: WKWebView!
    @IBOutlet weak var viewProgress: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblPrivacyPolicy.text = StringPermissions.privacyPolicy
        webviewPrivacy.navigationDelegate = self
       
        guard let url = URL(string: StringCommonMessages.privacyUrl) else { return }
        let myRequest = URLRequest(url: url)
        webviewPrivacy.load(myRequest)
    }
    

    @IBAction func tapBack(_ sender: Any) {
        popVC()
    }
    

}

extension PrivacyPolicyVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        CommonFunctions.hideGlobalProgressHUD(self)
        print(error)
    }
   
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        viewProgress.isHidden = false
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewProgress.isHidden = true
        let contentSize: CGSize = webView.scrollView.contentSize
        let viewSize: CGSize = self.view.bounds.size
        let ratio = viewSize.width / contentSize.width
        webView.scrollView.minimumZoomScale = ratio
        webView.scrollView.maximumZoomScale = ratio
        webView.scrollView.zoomScale = ratio
    }
    
}
