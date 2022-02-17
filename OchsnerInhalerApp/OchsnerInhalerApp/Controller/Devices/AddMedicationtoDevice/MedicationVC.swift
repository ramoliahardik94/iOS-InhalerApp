//
//  MedicationVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 18/01/22.
//

import UIKit

class MedicationVC: BaseVC {

    @IBOutlet weak var lblmedicationType: UILabel!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnMantainance: UIButton!
    @IBOutlet weak var btnRescue: UIButton!
    @IBOutlet weak var tblMedication: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    var isFromDeviceList = false

    var selectedIndex: Int?
    let medicationVM = MedicationVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        // Do any additional setup after loading the view.
        BLEHelper.shared.getmacAddress()
        NotificationCenter.default.addObserver(self, selector: #selector(self.macDetail(notification:)), name: .BLEGetMac, object: nil)
        self.getMedication()
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
        lblTitle.text = StringMedication.titleMedication
        lblmedicationType.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblmedicationType.text = StringMedication.inhealerType
        btnRescue.titleLabel?.font = UIFont(name: AppFont.SFProTextBold, size: 14)
        btnMantainance.titleLabel?.font = UIFont(name: AppFont.SFProTextBold, size: 14)
        
        btnRescue.backgroundColor = .Colorcell
        btnRescue.isOchsnerView = true
        
        btnMantainance.backgroundColor = .Colorcell
        btnMantainance.isOchsnerView = true
        
        btnNext.setButtonView(StringAddDevice.next)
        tblMedication.separatorStyle = UITableViewCell.SeparatorStyle.none
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
        if selectedIndex != nil {
            if btnRescue.isSelected {
                medicationVM.selectedMedication.uuid = BLEHelper.shared.discoveredPeripheral!.identifier.uuidString
                UserDefaultManager.selectedMedi = medicationVM.selectedMedication.toDic()
                UserDefaultManager.addDevice.append(BLEHelper.shared.discoveredPeripheral!.identifier.uuidString)
                medicationVM.apiAddDevice { [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(let status):
                        print("Response sucess :\(status)")
                        if self.isFromDeviceList {
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let homeTabBar  = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
                                   
                            self.navigationController?.popToViewController(homeTabBar, animated: true)
                        } else {
                        let addAnotherDeviceVC = AddAnotherDeviceVC.instantiateFromAppStoryboard(appStoryboard: .providers)
                        self.pushVC(controller: addAnotherDeviceVC)
                        }
                    case .failure(let message):
                        CommonFunctions.showMessage(message: message)
                    }
                }
               
            } else {
                let medicationDetailVC = MedicationDetailVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                medicationDetailVC.isFromDeviceList = isFromDeviceList
                medicationDetailVC.medicationVM = medicationVM
                pushVC(controller: medicationDetailVC)
            }
        } else {
            CommonFunctions.showMessage(message: ValidationMsg.medication)
        }
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
