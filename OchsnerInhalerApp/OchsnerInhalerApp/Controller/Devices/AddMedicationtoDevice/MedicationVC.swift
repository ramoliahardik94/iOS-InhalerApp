//
//  MedicationVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 18/01/22.
//

import UIKit

class MedicationVC: BaseVC {

    @IBOutlet weak var viewContains: UIView!
    @IBOutlet weak var lblmedicationType: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnMantainance: UIButton!
    @IBOutlet weak var btnRescue: UIButton!
    @IBOutlet weak var tblMedication: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDiscription: UILabel!
    @IBOutlet weak var txtDiscription: UITextField!
    let refreshControl = UIRefreshControl()
    var isFromDeviceList = false
    var selectedIndex: Int?
    let medicationVM = MedicationVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        // Do any additional setup after loading the view.
        guard let discoverPeripheral = BLEHelper.shared.connectedPeripheral.first(where: {BLEHelper.shared.newDeviceId == $0.discoveredPeripheral?.identifier.uuidString}) else { return }
        BLEHelper.shared.getmacAddress(peripheral: discoverPeripheral)
        NotificationCenter.default.addObserver(self, selector: #selector(self.macDetail(notification:)), name: .BLEGetMac, object: nil)
        self.getMedication()
        txtDiscription.delegate = self
//        hideKeyBoardHideOutSideTouch(customView: self.viewContains)
//        registerKeyboardNotifications()
    }
    
    func getMedication() {
        medicationVM.apiGetMedicationLis { result in
            switch result {
            case .success(let status):
                print("Response sucess :\(status)")
                self.tblMedication.reloadData()
            case .failure(let message):
                CommonFunctions.showMessage(message: message)
            }
        }
    }
    
    func setUp() {
        lblTitle.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        txtDiscription.paddingLeft = 20.0
        lblDiscription.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblTitle.text = StringMedication.titleMedication
        lblmedicationType.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblmedicationType.text = StringMedication.inhealerType
        btnRescue.titleLabel?.font = UIFont(name: AppFont.SFProTextBold, size: 14)
        btnMantainance.titleLabel?.font = UIFont(name: AppFont.SFProTextBold, size: 14)
        btnRescue.isSelected = true
        btnMantainance.isSelected = false
        btnRescue.backgroundColor = .Colorcell
        btnRescue.isOchsnerView = true
        
        btnMantainance.backgroundColor = .Colorcell
        btnMantainance.isOchsnerView = true
        
        btnNext.setButtonView(StringAddDevice.next)
        tblMedication.separatorStyle = UITableViewCell.SeparatorStyle.none
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tblMedication.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
       // Code to refresh table view
        getMedication()
        refreshControl.endRefreshing()
    }
    
    @objc func macDetail(notification: Notification) {
        print(notification.object ?? "") // myObject
          print(notification.userInfo ?? "")  // [AnyHashable("key"): "Value"]
        if let mac = notification.userInfo!["MacAdd"] {
            medicationVM.macAddress = mac as! String
        }
    }
    
    /// Rescue=1 Mantainance=2
    @IBAction func btnMedicationType(_ sender: UIButton) {
        btnRescue.isSelected = sender == btnRescue
        btnMantainance.isSelected = sender == btnMantainance
        medicationVM.medTypeId =  btnRescue.isSelected ? 1 : 2
    }

    @IBAction func btnNextClick(_ sender: UIButton) {
        medicationVM.description = txtDiscription.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if selectedIndex != nil {
            if btnRescue.isSelected {
                if BLEHelper.shared.connectedPeripheral.count > 1 {
                    if let discoveredPeripheral = BLEHelper.shared.connectedPeripheral[BLEHelper.shared.connectedPeripheral.count - 1].discoveredPeripheral {
                        medicationVM.selectedMedication.uuid = discoveredPeripheral.identifier.uuidString
                    }
                }
                UserDefaultManager.selectedMedi = medicationVM.selectedMedication.toDic()
                medicationVM.apiAddDevice(isreminder: false) { [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(let status):
                        print("Response sucess :\(status)")
                        let devicelist = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
                        if devicelist.count == 1 && !self.medicationVM.isEdit {
                            self.medicationVM.selectedMedication.uuid = (BLEHelper.shared.connectedPeripheral.last!.discoveredPeripheral?.identifier.uuidString) ?? ""
                            UserDefaultManager.selectedMedi = self.medicationVM.selectedMedication.toDic()
                            let addAnotherDeviceVC = AddAnotherDeviceVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                            self.pushVC(controller: addAnotherDeviceVC)
                            
                        } else {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    case .failure(let message):
                        CommonFunctions.showMessage(message: message)
                    }
                }
            } else {
                // TODO: Uncoment for Only one mantance Logic
                
                if DatabaseManager.share.isMantenanceAllow(medName: medicationVM.selectedMedication.medName ?? "") {
                    let medicationDetailVC = MedicationDetailVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                    medicationDetailVC.isFromDeviceList = isFromDeviceList
                    medicationDetailVC.medicationVM = medicationVM
                    pushVC(controller: medicationDetailVC)
                } else {
                    CommonFunctions.showMessage(message: String(format: ValidationMsg.mantainance, medicationVM.selectedMedication.medName ?? ""))
                }
            }
        } else {
            CommonFunctions.showMessage(message: ValidationMsg.medication)
        }
    }
    @IBAction func btnBackClick(_ sender: Any) {
        self.popVC()
    }
    
  

}
extension MedicationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicationVM.medication.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MedicationCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.medicationCell) as! MedicationCell
        cell.setMedicationDetailes(medication: medicationVM.medication[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        
         let befor = medicationVM.medication.firstIndex(where: {$0.isSelected == true})
        
        if befor != nil {
            medicationVM.medication[befor!].isSelected = false
            tblMedication.reloadRows(at: [IndexPath(row: befor!, section: 0)], with: .none)
        }
        medicationVM.medication[indexPath.row].isSelected = true
        tblMedication.reloadRows(at: [indexPath], with: .none)
        medicationVM.selectedMedication = medicationVM.medication[indexPath.row]
    }
    
}
extension MedicationVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let acceptableChar = "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz0123456789"
        let set = CharacterSet(charactersIn: acceptableChar)
        let inverted = set.inverted
        let filtered = string.components(separatedBy: inverted).joined(separator: "")
        let maxLength = 50
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return (filtered == string)  && (newString.count <= maxLength)
    }
}
