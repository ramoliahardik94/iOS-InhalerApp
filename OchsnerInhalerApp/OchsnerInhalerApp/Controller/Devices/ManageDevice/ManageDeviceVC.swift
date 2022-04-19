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
        tbvData.reloadData()
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
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        let device = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        if BLEHelper.shared.connectedPeripheral.count !=  device.count {
            Logger.logInfo("Scan with ManageDeviceVC refresh")
            BLEHelper.shared.scanPeripheral()
        } else {
             let disconnectedDevice = BLEHelper.shared.connectedPeripheral.filter({$0.discoveredPeripheral?.state != .connected})
                for obj in disconnectedDevice {                    
                    BLEHelper.shared.connectPeriPheral(peripheral: obj.discoveredPeripheral!)
                }
        }
        tbvData.reloadData()
        apiCall()
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
        Logger.logInfo("Add Another Device Click")
        BLEHelper.shared.stopTimer()
        BLEHelper.shared.stopScanPeriphral()
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return manageDeviceVM.arrRescue.count
        } else {
         return manageDeviceVM.arrMantainance.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCell, for: indexPath) as! ManageDeviceCell
        cell.selectionStyle = .none
        cell.btnRemoveDevice.tag = indexPath.row
        cell.btnRemoveDevice.accessibilityValue = "\(indexPath.section)"
      
        cell.btnEditDirection.tag = indexPath.row
        cell.btnEditDirection.accessibilityValue = "\(indexPath.section)"
        
        if indexPath.section == 0 {
            cell.lblDeviceType.text = indexPath.row == 0 ? "Rescue Devices" : ""
            cell.device = manageDeviceVM.arrRescue[indexPath.row]
        } else {
            cell.lblDeviceType.text = indexPath.row == 0 ?  "Maintenance Devices" : ""
            cell.device = manageDeviceVM.arrMantainance[indexPath.row]
        }
        cell.viewTypeSaperator.isHidden = indexPath.row != 0
        cell.headerHeight.constant = indexPath.row != 0 ? 0 : 35
        cell.delegate = self
        return cell
    }
}

extension ManageDeviceVC: ManageDeviceDelegate {
    func editDirection(index: Int, section: Int) {
        
        Logger.logInfo("Edit Direction Click")
        let medicationDetailVC = MedicationDetailVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        let medication = MedicationVM()
        let device = section == 0 ? manageDeviceVM.arrRescue[index] : manageDeviceVM.arrMantainance[index]
        medication.selectedMedication = device.medication
        medication.isEdit = true
        medication.puff = device.puffs
        medication.arrTime = device.arrTime
        medication.macAddress = device.internalID
        medicationDetailVC.medicationVM = medication
        pushVC(controller: medicationDetailVC)
    }
    
    func removeDevice(index: Int, section: Int) {
        // TODO: - Remove device api call
        let device = section == 0 ? manageDeviceVM.arrRescue[index] : manageDeviceVM.arrMantainance[index]
        CommonFunctions.showMessageYesNo(message: ValidationMsg.removeDevice) { [weak self] isOk in
            guard let `self` = self else { return }
            if isOk ?? false {
                self.clearDeviceRemindersNotification(internalId: device.internalID)
                Logger.logInfo("Remove Device Click")
                let id = DatabaseManager.share.getUDID(mac: device.internalID)
                DatabaseManager.share.setRTCFor(udid: id, value: false)
                let intArrDevice = self.manageDeviceVM.arrDevice.firstIndex(where: {$0.internalID == device.internalID})
                self.apiCallOfRemoveDevice(index: intArrDevice ?? 0)
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
    
    private func clearDeviceRemindersNotification(internalId: String) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            let filterArray = requests.map({ (item) -> String in item.identifier })
            let commonArray = filterArray.filter { item in
                return item.contains("com.ochsner.inhalertrack.reminderdose\(internalId)")
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: commonArray)
            Logger.logInfo(" Remove notification \(commonArray)")
        })
    }
    
}
