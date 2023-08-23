//
//  ManageDeviceVC.swift //  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit
import CoreBluetooth


class ManageDeviceVC: BaseVC {
    @IBOutlet weak var lblNodata: UILabel!
    @IBOutlet weak var tbvData: UITableView!
    private let itemCell = CellIdentifier.manageDeviceCell
    var manageDeviceVM = ManageDeviceVM()
    @IBOutlet weak var btnAddAnothDevice: UIButton!
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var addDevicebtnHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "setBLEPermission")
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
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems =  [UIBarButtonItem(image: UIImage(named: "notifications_white"), style: .plain, target: self, action: #selector(tapNotification))]
        tbvData.reloadData()
        if self.manageDeviceVM.arrDevice.count == 0 {
            refresh(self)
        }
    }
    
    func apiCall() {
        manageDeviceVM.apicallForGetDeviceList { [weak self] result in
            guard let`self` = self else { return }
            self.refreshControl.endRefreshing()
            switch result {
            case .success(let status):
                print("Response sucess :\(status)")
                DispatchQueue.main.async {
                    self.tbvData.reloadData()
                    self.tbvData.isHidden = self.manageDeviceVM.arrDevice.count == 0
                    self.lblNodata.isHidden = self.manageDeviceVM.arrDevice.count > 0
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
        let device = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        btnAddAnothDevice.setButtonView(device.count != 0 ? StringDevices.addAnotherDevice : StringDevices.addDevice)
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
        lblNodata.setFont()
        lblNodata.text = StringAddDevice.noDevice
        self.tbvData.isHidden = device.count == 0
        self.lblNodata.isHidden = device.count > 0
    }
    
    @objc func inhalerConnected(notification: Notification) {
        DispatchQueue.main.async { [self] in
            self.tbvData.reloadData()
        }
    }
    
    @objc func inhalerBatteryLevel(notification: Notification) {
        DispatchQueue.main.async { [self] in
            self.tbvData.reloadData()
        }
    }
    
    @objc func medicationUpdate(notification: Notification) {
        apiCall()
    }
    
    // MARK: -
    @IBAction func tapAddAnotherDevice(_ sender: Any) {
        Logger.logInfo("Add Another Device Click")
        BLEHelper.shared.stopTimer()
        BLEHelper.shared.stopScanPeriphral()
        BLEHelper.shared.newDeviceId = ""
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
        medication.description = device.discription
        medicationDetailVC.medicationVM = medication
        pushVC(controller: medicationDetailVC)
    }
    
    func removeDevice(index: Int, section: Int) {
        // Remove device api call
        let device = section == 0 ? manageDeviceVM.arrRescue[index] : manageDeviceVM.arrMantainance[index]
        
        CommonFunctions.showMessageYesNo(message: ValidationMsg.removeDevice) { [weak self] isOk in
            guard let `self` = self else { return }
            if isOk {
                
                // TODO: 1172 Bug Changes
                if var deviceDetails = UserDefaults.standard.object(forKey: "DeviceJoiningDate&MacAdd") as? [[String: Any]] {
                    // OP: [["startDate": 2023-07-27 08:29:17 +0000, "deviceMacAddress": 70:05:00:00:03:f0], ["startDate": 2023-07-27 08:58:05 +0000, "deviceMacAddress": 70:05:00:00:03:c6]]
                    let index = deviceDetails.firstIndex(where: { dictionary in
                        guard let value = dictionary["deviceMacAddress"] as? String
                        else { return false }
                        return value == device.internalID
                    })
                    
                    if let index = index {
                        deviceDetails.remove(at: index)
                        print("deviceDetailUpdated", deviceDetails)
                        UserDefaults.standard.set(deviceDetails, forKey: "DeviceJoiningDate&MacAdd")
                        print("deviceDetailUpdated", UserDefaults.standard.object(forKey: "DeviceJoiningDate&MacAdd") ?? "")
                    }
                } else {
                    print("nil")
                }
                
                NotificationManager.shared.clearDeviceRemindersNotification(macAddress: device.internalID)
                NotificationManager.shared.removePushTokenRequest(mac: device.internalID)
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
}
