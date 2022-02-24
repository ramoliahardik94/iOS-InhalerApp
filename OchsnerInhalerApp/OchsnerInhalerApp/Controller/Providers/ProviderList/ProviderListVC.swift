//
//  ProviderListVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit
import SafariServices
import WebKit

class ProviderListVC: BaseVC {

    @IBOutlet weak var viewProvider: UIView!
   // @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblSubHeader: UILabel!
   // @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewConform: UIView!
   // @IBOutlet weak var searchProvider: UISearchBar!
    @IBOutlet weak var imgSelectedProvider: UIImageView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var tbvData: UITableView!
    @IBOutlet weak var viewWebviewMain: UIView!
    
    @IBOutlet weak var lbProviderName: UILabel!
    @IBOutlet weak var wvData: WKWebView!
    
    
    private var providerListVM = ProviderListVM()
    private var OAuthUrl = ""
    private var providerId = ""
    private var isCallFirstTime = true
    private var providerName = ""
  // private var webView: WKWebView!
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupVC()
    }
    func setupVC() {
       // self.btnCancel.isEnabled = false
        lblHeader.text = StringPoviders.selectOrganization
        lblSubHeader.text = StringPoviders.providerSubHeader
        lblHeader.setFont(type: .semiBold, point: 16)
        lblSubHeader.setFont(type: .regular, point: 14)
        lbProviderName.setFont(type: .semiBold, point: 16)
        lbProviderName.text = ""
        lbProviderName.textColor = .white
        self.view.backgroundColor = .ColorHeader
//        viewSearch.backgroundColor = .ColorHeaderSearch
//        self.searchProvider.barTintColor = .ColorHeaderSearch
//        self.searchProvider.backgroundColor = .ColorHeaderSearch
//        self.searchProvider.searchTextField.borderStyle = .none
//        self.searchProvider.searchTextField.backgroundColor = .white
//        self.searchProvider.searchTextField.layer.cornerRadius = 10
//        self.searchProvider.searchTextField.clipsToBounds = true
//        self.btnCancel.setTitleColor(.lightGray, for: .disabled)
//        self.btnCancel.setTitleColor(.white, for: .normal)
//        self.searchProvider.layer.borderWidth = 1
//        self.searchProvider.layer.borderColor = UIColor.ColorHeaderSearch.cgColor
//        self.lblHeader.font = UIFont(name: AppFont.AppRegularFont, size: 14)
//        self.btnCancel.titleLabel?.font = UIFont(name: AppFont.AppRegularFont, size: 12)
//        self.searchProvider.searchTextField.font = UIFont(name: AppFont.AppRegularFont, size: 12)
//        self.searchProvider.delegate = self
        viewProvider.isOchsnerView = true
        self.btnContinue.setButtonView(StringPoviders.continueProvider)
        self.btnChange.setButtonView(StringPoviders.change, isDefaultbtn: false)
        viewConform.isHidden = true
        doGetProviderList()
        
      
        wvData.navigationDelegate = self
        tbvData.separatorStyle = .none
        
    }
    @IBAction func btnCancelClick(_ sender: UIButton) {
      //  self.searchProvider.searchTextField.text = ""
        self.view.endEditing(true)
        sender.isEnabled = false
    }
    @IBAction func btnBackClick(_ sender: Any) {
        self.popVC()
    }
    
    @IBAction func btnContinueClick(_ sender: Any) {
        // viewConform.isHidden = true
        isCallFirstTime = true
        setUiWebview()
    }

    @IBAction func btnChangeClick(_ sender: Any) {
        viewConform.isHidden = true
        OAuthUrl = ""
    }
    
    @IBAction func tapBackWebview(_ sender: Any) {
        viewWebviewMain.isHidden = true
    }
    func doGetProviderList() {
        providerListVM.doGetProviderList { result in
            switch result {
            case .success(let status):
                print("Response sucess :\(status)")
                DispatchQueue.main.async {
                    self.tbvData.reloadData()
                }
            case .failure(let message):
                CommonFunctions.showMessage(message: message)
            }
        }
    }
    
    private func  setUiWebview() {
        viewWebviewMain.isHidden = false
        lbProviderName.text = providerName
        guard let url = URL(string: OAuthUrl) else { return }
        let myRequest = URLRequest(url: url)
        
        wvData.load(myRequest)
        
    }
    
    private func doSendAuthRequest(path: String) {
        providerListVM.doSendAuthRequest(url: path) { result in
            switch result {
            case .success(let status):
                print("Response sucess :\(status)")
                
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let homeTabBar  = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
               
                homeTabBar.selectedIndex = 1
                self.rootVC(controller: homeTabBar)
                
            case .failure(let message):
                CommonFunctions.showMessage(message: message)
                self.viewWebviewMain.isHidden = true
            }
            
        }
    }
    
}
extension ProviderListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providerListVM.providerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ProviderCell = tableView.dequeueReusableCell(withIdentifier: "ProviderCell") as! ProviderCell
        cell.imgProvider.image = UIImage(named: providerListVM.providerList[indexPath.row].iconFilename ?? "")
        
//        if indexPath.row == 1 {
//            cell.imgProvider.image = UIImage(named: "provider")
//        } else if indexPath.row == 2 {
//            cell.imgProvider.image = UIImage(named: "provider1")
//        } else {
//            cell.imgProvider.image = UIImage(named: "provider2")
//        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        imgSelectedProvider.image = UIImage(named: providerListVM.providerList[indexPath.row].iconFilename ?? "")
        providerName = providerListVM.providerList[indexPath.row].entryName ?? ""
//        if indexPath.row == 1 {
  //          imgSelectedProvider.image = UIImage(named: "provider")
//        } else if indexPath.row == 2 {
//            imgSelectedProvider.image = UIImage(named: "provider1")
//        } else {
//            imgSelectedProvider.image = UIImage(named: "provider2")
//        }
        let obj =  providerListVM.providerList[indexPath.row]
        OAuthUrl = obj.OAuthUrl ?? ""
        providerId = "\(obj.entryId ?? 0)"
        viewConform.isHidden = false
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}



extension ProviderListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       // btnCancel.isEnabled = searchBar.searchTextField.text!.count > 0
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
extension ProviderListVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        CommonFunctions.hideGlobalProgressHUD(self)
        print(error)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        CommonFunctions.showGlobalProgressHUD(self)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        CommonFunctions.hideGlobalProgressHUD(self)
     //  print("finish to load \(webView.url)")
       // doSendAuthRequest()
    }
    func webView(webView: WKWebView!, createWebViewWithConfiguration configuration: WKWebViewConfiguration!, forNavigationAction navigationAction: WKNavigationAction!, windowFeatures: WKWindowFeatures!) -> WKWebView! {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
      
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
       // print("decidePolicyFor \(webView.url?.absoluteString)")
        return .allow
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("didReceiveServerRedirectForProvisionalNavigation \(webView.url)")
        let url = webView.url?.absoluteString ?? ""
        if ((url.contains(StringPoviders.providerBaseUrl))) {
            
            var dict = [String: String]()
            let components = URLComponents(url: webView.url!, resolvingAgainstBaseURL: false)!
            if let queryItems = components.queryItems {
                for item in queryItems {
                    dict[item.name] = item.value!
                }
            }
          //  print(dict)
            if isCallFirstTime {
                CommonFunctions.hideGlobalProgressHUD(self)
                isCallFirstTime = false
                let urlFinal =  "\(APIRouter.providerAuth.path)?providerId=\(dict["provider"] ?? "")&accessToken=\(dict["accessToken"] ?? "")&expiresIn=\(dict["expiresIn"] ?? "")&refreshToken=\(dict["refreshToken"] ?? "")"
                doSendAuthRequest(path: urlFinal)
            }
        }
    }
}
