//
//  ProviderListVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit



class ProviderListVC: BaseVC {

    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblSubHeader: UILabel!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var searchProvider: UISearchBar!
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
        self.lblHeader.font = UIFont(name: AppFont.AppRegularFont, size: 14)
        self.btnCancel.titleLabel?.font = UIFont(name: AppFont.AppRegularFont, size: 12)
        self.searchProvider.searchTextField.font = UIFont(name: AppFont.AppRegularFont, size: 12)
        self.searchProvider.delegate = self
    }
    @IBAction func btnCancelClick(_ sender: UIButton) {
        self.searchProvider.searchTextField.text = ""
        self.view.endEditing(true)
        sender.isEnabled = false
    }
    @IBAction func btnBackClick(_ sender: Any) {
        self.popVC()
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
        let vc  = BluetoothPermissionVC.instantiateFromAppStoryboard(appStoryboard: .permissions)
        pushVC(vc: vc)
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
