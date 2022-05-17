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
    @IBOutlet weak var btnUpdateAllHeight: NSLayoutConstraint!
    @IBOutlet weak var lblUpdateInfo: UILabel!
    @IBOutlet weak var btnUpdateAll: UIButton!
    
    @IBOutlet weak var viewUpdateInfoHeight: NSLayoutConstraint!
    @IBOutlet weak var viewUpdateInfo: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerBatteryLevel(notification:)), name: .BLEBatteryLevel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.medicationUpdate(notification:)), name: .medUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEDisconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEChange, object: nil)
        initUI()
        setUpdateAllView()
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
        
       setUpdateAllView()
    }
    func setUpdateAllView() {
        let connectedDeviceList = BLEHelper.shared.connectedPeripheral.filter({$0.version != Constants.AppContainsFirmwareVersion})
       // btnUpdateAllHeight.constant = connectedDeviceList.count == 0  ? 0 : 35
        viewUpdateInfoHeight.constant = connectedDeviceList.count == 0  ? 0 : 70
        btnUpdateAll.isHidden = connectedDeviceList.count == 0
        viewUpdateInfo.isHidden = connectedDeviceList.count == 0
        btnUpdateAll.setButtonView(StringDevices.upgradeAll, 14, AppFont.AppRegularFont, isBlankBG: true)
        lblUpdateInfo.setFont()
        lblUpdateInfo.text = StringDevices.upgradeInfo
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
    @IBAction func btnUpdateAllclick(_ sender: Any) {
        let connectedDeviceList = BLEHelper.shared.connectedPeripheral.filter({$0.version != Constants.AppContainsFirmwareVersion})
        let peripheral = connectedDeviceList[0]
        peripheral.discoveredPeripheral!.delegate = nil
        peripheral.isOTAUpgrade = true
        let bleUpgrade = BLEOTAUpgrade.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        bleUpgrade.selectedPeripheral = peripheral.discoveredPeripheral
        bleUpgrade.modalPresentationStyle = .overCurrentContext
        if let deviceDetail = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email).first(where: {$0.udid == peripheral.discoveredPeripheral!.identifier.uuidString}) {
            bleUpgrade.medname = deviceDetail.medname ?? ""
        }
        bleUpgrade.isUpdateAll = true
        // self.pushVC(controller: bleUpgrade)
        self.presentVC(controller: bleUpgrade)
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
        
        cell.btnUpgrade.tag = indexPath.row
        cell.btnUpgrade.accessibilityValue = "\(indexPath.section)"
        
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
    
    func upgradeDevice(index: Int, section: Int) {
        CommonFunctions.showMessageYesNo(message: "Do you want to upgrade device?", cancelTitle: "Skip", okTitle: "Continue", { isOK in
            if isOK {
                let device = section == 0 ? self.manageDeviceVM.arrRescue[index] : self.manageDeviceVM.arrMantainance[index]
                if let peripheral = BLEHelper.shared.connectedPeripheral.first(where: {$0.addressMAC == device.internalID}) {
                    peripheral.discoveredPeripheral!.delegate = nil
                    peripheral.isOTAUpgrade = true
                    let bleUpgrade = BLEOTAUpgrade.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                    bleUpgrade.selectedPeripheral = peripheral.discoveredPeripheral
                    bleUpgrade.modalPresentationStyle = .overCurrentContext
                    bleUpgrade.medname = device.medication.medName ?? ""
                   // self.pushVC(controller: bleUpgrade)
                    self.presentVC(controller: bleUpgrade)
                }
            }
        })
        
       
    }
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
            if isOk {
                NotificationManager.shared.clearDeviceRemindersNotification(macAddress: device.internalID)
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
