//
//  ProviderListVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit



class ProviderListVC: BaseVC {

    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var searchProvider: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupVC()
    }
    func setupVC(){
        self.btnCancel.isEnabled = false
        lblLogin.text = StringPoviders.selectOrganization
        viewHeader.backgroundColor = .Color_Header
        self.view.backgroundColor = .Color_HeaderSearch
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
        //self.searchProvider.searchTextField.font = UIFont(name: <#T##String#>, size: <#T##CGFloat#>)
    }

    @IBAction func tapBack(_ sender: UIButton) {
        popVC()
    }
    
}
extension ProviderListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ProviderCell = tableView.dequeueReusableCell(withIdentifier: "ProviderCell") as! ProviderCell
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}



