//
//  ProviderListVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit



class ProviderListVC: BaseVC {

    @IBOutlet weak var viewProvider: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblSubHeader: UILabel!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewConform: UIView!
    @IBOutlet weak var searchProvider: UISearchBar!
    @IBOutlet weak var imgSelectedProvider: UIImageView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnChange: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupVC()
    }
    func setupVC(){
        self.btnCancel.isEnabled = false
        lblHeader.text = StringPoviders.selectOrganization
        lblSubHeader.text = StringPoviders.providerSubHeader
        self.view.backgroundColor = .Color_Header
        viewSearch.backgroundColor = .Color_HeaderSearch
        self.searchProvider.barTintColor = .Color_HeaderSearch
        self.searchProvider.backgroundColor = .Color_HeaderSearch
        self.searchProvider.searchTextField.borderStyle = .none
        self.searchProvider.searchTextField.backgroundColor = .white
        self.searchProvider.searchTextField.layer.cornerRadius = 10
        self.searchProvider.searchTextField.clipsToBounds = true
        self.btnCancel.setTitleColor(.lightGray, for: .disabled)
        self.btnCancel.setTitleColor(.white, for: .normal)
        self.searchProvider.layer.borderWidth = 1
        self.searchProvider.layer.borderColor = UIColor.Color_HeaderSearch.cgColor
        self.lblHeader.font = UIFont(name: AppFont.AppRegularFont, size: 15)
        self.lblSubHeader.font = UIFont(name: AppFont.AppRegularFont, size: 13)
        self.btnCancel.titleLabel?.font = UIFont(name: AppFont.AppRegularFont, size: 12)
        self.searchProvider.searchTextField.font = UIFont(name: AppFont.AppRegularFont, size: 12)
        self.searchProvider.delegate = self
        viewProvider.isOchsnerView = true
        self.btnContinue.setButtonView(StringPoviders.continueProvider)
        self.btnChange.setButtonView(StringPoviders.change,isDefaultbtn: false)
        viewConform.isHidden = true
    }
    @IBAction func btnCancelClick(_ sender: UIButton) {
        self.searchProvider.searchTextField.text = ""
        self.view.endEditing(true)
        sender.isEnabled = false
    }
    @IBAction func btnBackClick(_ sender: Any) {
        self.popVC()
    }
    
    @IBAction func btnContinueClick(_ sender: Any) {
        let vc  = AddAnotherDeviceVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        pushVC(vc: vc)
    }
    @IBAction func btnChangeClick(_ sender: Any) {
        viewConform.isHidden = true
    }
}
extension ProviderListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProviderCell = tableView.dequeueReusableCell(withIdentifier: "ProviderCell") as! ProviderCell
        if indexPath.row == 1 {
            cell.imgProvider.image = UIImage(named: "provider")
        } else if indexPath.row == 2{
            cell.imgProvider.image = UIImage(named: "provider1")
        }else {
            cell.imgProvider.image = UIImage(named: "provider2")
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if indexPath.row == 1 {
            imgSelectedProvider.image = UIImage(named: "provider")
        } else if indexPath.row == 2{
            imgSelectedProvider.image = UIImage(named: "provider1")
        }else {
            imgSelectedProvider.image = UIImage(named: "provider2")
        }
        viewConform.isHidden = false
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}



extension ProviderListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        btnCancel.isEnabled = searchBar.searchTextField.text!.count > 0
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
