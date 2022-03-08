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
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var addDevicebtnHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerBatteryLevel(notification:)), name: .BLEBatteryLevel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.medicationUpdate(notification:)), name: .medUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEDisconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEChange, object: nil)
        initUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.topItem?.title = StringAddDevice.titleAddDevice
        if self.manageDeviceVM.arrDevice.count == 0 {
            apiCall()
        }
        tbvData.reloadData()
        let device = BLEHelper.shared.centralManager.retrieveConnectedPeripherals(withServices: TransferService.serviceArray)
        print("\(device)")
        BLEHelper.shared.centralManager.de
        refresh(self)
    }
    
    func apiCall() {
        CommonFunctions.showGlobalProgressHUD(self)
        manageDeviceVM.apicallForGetDeviceList { [weak self] result in
           
            guard let`self` = self else { return }
            CommonFunctions.hideGlobalProgressHUD(self)
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
    private func initUI() {
        let nib = UINib(nibName: itemCell, bundle: nil)
        tbvData.register(nib, forCellReuseIdentifier: itemCell)
        
        tbvData.delegate = self
        tbvData.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tbvData.addSubview(refreshControl)
        tbvData.separatorStyle = .none
        btnAddAnothDevice.setButtonView(StringDevices.addAnotherDevice)
        
//        addDevicebtnHeight.constant = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email).count == Constants.maximumDevice ? 0 : 50
//        btnAddAnothDevice.isHidden = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email).count == Constants.maximumDevice
        apiCall()
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        if BLEHelper.shared.discoveredPeripheral == nil || BLEHelper.shared.discoveredPeripheral!.state == .disconnected {
            BLEHelper.shared.scanPeripheral()
        }
        refreshControl.endRefreshing()
    }
    
    @objc func inhalerConnected(notification: Notification) {
        DispatchQueue.main.async {
            self.tbvData.reloadData()
        }
    }
    @objc func inhalerBatteryLevel(notification: Notification) {
        self.tbvData.reloadData()
    }
    @objc func medicationUpdate(notification: Notification) {
        apiCall()
    }
    // MARK: -
    @IBAction func tapAddAnotherDevice(_ sender: Any) {
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        addDeviceIntroVC.step = .step1
        addDeviceIntroVC.isFromAddAnother  = true
        addDeviceIntroVC.isFromDeviceList  = true
        BLEHelper.shared.isAddAnother = true
        pushVC(controller: addDeviceIntroVC)
    }
    
    deinit {
        self.navigationController?.isNavigationBarHidden = true
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
        cell.delegate = self
        return cell
    }
}

extension ManageDeviceVC: ManageDeviceDelegate {

   
    func editDirection(index: Int) {
        let medicationDetailVC = MedicationDetailVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        let medication = MedicationVM()
        medication.selectedMedication = manageDeviceVM.arrDevice[index].medication
        medication.isEdit = true
        medication.puff = manageDeviceVM.arrDevice[index].puffs
        medication.arrTime = manageDeviceVM.arrDevice[index].arrTime
        medication.macAddress = manageDeviceVM.arrDevice[index].internalID
        medicationDetailVC.medicationVM = medication
        pushVC(controller: medicationDetailVC)
    }
    
    func removeDevice(index: Int) {
        // TODO: - Remove device api call
        CommonFunctions.showMessageYesNo(message: ValidationMsg.removeDevice) { [weak self] isOk in
            guard let `self` = self else { return }
            if isOk ?? false {
                self.apiCallOfRemoveDevice(index: index)
            }
        }
        
    }
    func apiCallOfRemoveDevice (index: Int) {
        manageDeviceVM.apicallForRemoveDevice(index: index) { [weak self] result in
            guard let`self` = self else { return }
            switch result {
            case .success(let status):
                print("Response sucess :\(status)")
                DispatchQueue.main.async {
                    self.tbvData.reloadData()
                    
//                    self.addDevicebtnHeight.constant = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email).count == Constants.maximumDevice ? 0 : 50
//                    self.btnAddAnothDevice.isHidden = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email).count == Constants.maximumDevice
                    if self.manageDeviceVM.arrDevice.count == 0 {
                        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                        addDeviceIntroVC.step = .step1
                        addDeviceIntroVC.isFromAddAnother  = false
                        addDeviceIntroVC.isFromDeviceList  = true
                        self.pushVC(controller: addDeviceIntroVC)
                        self.view.layoutSubviews()
                    }
                    
                }
            case .failure(let message):
                
                CommonFunctions.showMessage(message: message)
            }
        }
    }
}
