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
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerBatteryLevel(notification:)), name: .BLEBatteryLevel, object: nil)
        initUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.topItem?.title = StringAddDevice.titleAddDevice
        tbvData.reloadData()
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
        tbvData.separatorStyle = .none
        btnAddAnothDevice.setButtonView(StringDevices.addAnotherDevice)
        apiCall()
    }
    @objc func inhalerConnected(notification: Notification) {
        BLEHelper.shared.getmacAddress()
        BLEHelper.shared.getBetteryLevel()
        DispatchQueue.main.async {
            self.tbvData.reloadData()
        }
    }
    @objc func inhalerBatteryLevel(notification: Notification) {
        self.tbvData.reloadData()
    }
    // MARK: -
    @IBAction func tapAddAnotherDevice(_ sender: Any) {
        let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        addDeviceIntroVC.step = .step2
        addDeviceIntroVC.isFromAddAnother  = true
        addDeviceIntroVC.isFromDeviceList  = true
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

extension ManageDeviceVC: ManageDeviceDelegate, MedicationDelegate {

    func medicationUpdated() {
        apiCall()
    }
    
    func editDirection(index: Int) {
        let medicationDetailVC = MedicationDetailVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        let medication = MedicationVM()
        medication.selectedMedication = manageDeviceVM.arrDevice[index].medication
        medication.isEdit = true
        medication.puff = manageDeviceVM.arrDevice[index].puffs
        medication.arrTime = manageDeviceVM.arrDevice[index].arrTime
        medication.macAddress = manageDeviceVM.arrDevice[index].internalID
        medicationDetailVC.medicationVM = medication
        medicationDetailVC.delegate = self
        pushVC(controller: medicationDetailVC)
    }
    
    func removeDevice(index: Int) {
        // TODO: - Remove device api call
        CommonFunctions.showMessage(message: "Remove device is under development.")
    }
}
