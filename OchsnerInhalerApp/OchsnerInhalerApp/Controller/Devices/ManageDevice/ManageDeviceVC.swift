//
//  ManageDeviceVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class ManageDeviceVC: BaseVC {
    @IBOutlet weak var tbvData: UITableView!
    private let itemCell = CellIdentifier.manageDeviceCell
    var manageDeviceVM = ManageDeviceVM()
    @IBOutlet weak var btnAddAnothDevice: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEConnect, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manageDeviceVM.apicallForGetDeviceList  { [weak self] result in
            guard let`self` = self else{ return }
            switch result {
            case .success(let status):
                print("Response sucess :\(status)")
                self.tbvData.reloadData()
                
            case .failure(let message):
                CommonFunctions.showMessage(message: message)
            }
        }
    }
    
    private func initUI() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.topItem?.title = StringAddDevice.titleAddDevice
        
        let nib = UINib(nibName: itemCell, bundle: nil)
        tbvData.register(nib, forCellReuseIdentifier: itemCell)
        tbvData.delegate = self
        tbvData.dataSource = self
        tbvData.separatorStyle = .none
        btnAddAnothDevice.setButtonView(StringDevices.addAnotherDevice)
    
    }
    @objc func inhalerConnected(notification: Notification) {
        BLEHelper.shared.getmacAddress()
        BLEHelper.shared.getBetteryLevel()
        DispatchQueue.main.async {
            self.tbvData.reloadData()
        }
    }
    
    // MARK: -
    @IBAction func tapAddAnotherDevice(_ sender: Any) {
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        addDeviceIntroVC.step = .step2
        addDeviceIntroVC.isFromAddAnother  = true
        pushVC(controller: addDeviceIntroVC)
    }
    
}
extension ManageDeviceVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manageDeviceVM.arrDevice.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCell, for: indexPath) as! ManageDeviceCell
        cell.selectionStyle = .none
        cell.btnRemoveDevice.tag = indexPath.row
        cell.btnEditDirection.tag = indexPath.row
        cell.device = manageDeviceVM.arrDevice[indexPath.row]
        return cell
    }
    
    
    
}
