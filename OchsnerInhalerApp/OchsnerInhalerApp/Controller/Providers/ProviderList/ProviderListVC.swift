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
    
    @IBOutlet weak var wvData: WKWebView!
    
    
    private var providerListVM = ProviderListVM()
    private var OAuthUrl = ""
    private var providerId = ""
    
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
        viewConform.isHidden = true
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
        guard let url = URL(string: OAuthUrl) else { return }
        let myRequest = URLRequest(url: url)
        wvData.load(myRequest)
        
    }
    
    private func doSendAuthRequest() {
        let params =  ProviderModel(jSon: [String: Any]())
        params.providerId = providerId
        params.accessToken = "0"
        params.refreshToken = "0"
        params.expiresIn = "0"
        // APIRouter.providerAuth.path
        
        providerListVM.doSendAuthRequest(url: "https://inhlrtrackdev.ochsner.org/api/LinkUser?providerId=1&accessToken=abcdef&expiresIn=3120&refreshToken=ghijkl" ,params: params) { result in
            switch result {
            case .success(let status):
                print("Response sucess :\(status)")
                
            case .failure(let message):
                CommonFunctions.showMessage(message: message)
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
       //print("finish to load \(webView.url)")
       // doSendAuthRequest()
    }
}
