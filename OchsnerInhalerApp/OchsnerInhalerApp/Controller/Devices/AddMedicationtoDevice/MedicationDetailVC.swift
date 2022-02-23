//
//  MedicationDetailVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 19/01/22.
//

import UIKit
import DropDown


protocol MedicationDelegate: AnyObject {
    func medicationUpdated()
}

class MedicationDetailVC: BaseVC {
    
    @IBOutlet weak var lblAddDose: UILabel!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewMedicationName: UIView!
    @IBOutlet weak var lblMedicationName: UILabel!
    @IBOutlet weak var lblDoseTime: UILabel!
    @IBOutlet weak var lblNDCCode: UILabel!
    @IBOutlet weak var txtPuff: UITextField!
    @IBOutlet weak var lblReminder: UILabel!
    @IBOutlet weak var swReminder: UISwitch!
    @IBOutlet weak var btnAddDose: UIButton!
    @IBOutlet weak var lblPuffTitle: UILabel!
    @IBOutlet weak var tblDoseTime: UITableView!
    @IBOutlet weak var btnPuff: UIButton!
    var isFromDeviceList = false

    var medicationVM = MedicationVM()
    
    let timePicker = UIDatePicker()
   
    
    let myPicker: NMDatePicker = {
        let obj = NMDatePicker()
        return obj
    }()
    let dropDown = DropDown()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
        hideKeyBoardHideOutSideTouch(customView: self.view)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setDatePicker() {
        myPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myPicker)
        let conObj = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            
            // custom picker view should cover the whole view
            myPicker.topAnchor.constraint(equalTo: conObj.topAnchor),
            myPicker.leadingAnchor.constraint(equalTo: conObj.leadingAnchor),
            myPicker.trailingAnchor.constraint(equalTo: conObj.trailingAnchor),
            myPicker.bottomAnchor.constraint(equalTo: conObj.bottomAnchor)])
        
        // hide custom picker view
        myPicker.isHidden = true
        myPicker.mode = .time
        // add closures to custom picker view
        myPicker.dismissClosure = { [weak self] val in
            guard let self = self else {
                return
            }
            let formatter = DateFormatter()
            formatter.dateFormat =  "hh:mm a"
            let selectedTime = formatter.string(from: val)
            
            self.medicationVM.arrTime.remove(at: self.myPicker.tag)
            self.medicationVM.arrTime.insert(selectedTime, at: self.myPicker.tag)
            self.tblDoseTime.reloadData()
            
            self.myPicker.isHidden = true
        }
    }
    
    func setUI() {
        lblTitle.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblTitle.text = StringMedication.titleMedicationDetail

        viewMedicationName.backgroundColor = .Colorcell
        viewMedicationName.isOchsnerView = true
        viewMedicationName.clipsToBounds = true
        
        lblMedicationName.font = UIFont(name: AppFont.SFProTextBold, size: 17)
        lblNDCCode.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        
        lblPuffTitle.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblPuffTitle.text = StringMedication.puffTitle
        
        txtPuff.isOchsnerView = true
        txtPuff.clipsToBounds = true
        txtPuff.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        txtPuff.text =  "\(medicationVM.puff)" 
        lblDoseTime.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblDoseTime.text = StringMedication.doseTime
        
        lblReminder.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblReminder.text = StringMedication.reminder
        btnDone.setButtonView(StringMedication.done)
        
        btnAddDose.layer.borderColor = UIColor.BlueText.cgColor
        btnAddDose.layer.cornerRadius = 6
        btnAddDose.tintColor = .BlueText
        btnAddDose.layer.borderWidth = 1
        btnAddDose.clipsToBounds = true
        
        lblAddDose.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        lblAddDose.text =  self.medicationVM.arrTime.count == 0 ? StringMedication.addFirstDose : StringMedication.addDose
        lblAddDose.textColor = .BlueText
        self.setDatePicker()
        
        lblNDCCode.text = "NDC Code: \(medicationVM.selectedMedication!.ndc ?? "")"
        lblMedicationName.text = medicationVM.selectedMedication.medName
       
        
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        self.popVC()
    }
    
    @IBAction func btnDoneClick(_ sender: UIButton) {
        
        if medicationVM.arrTime.count > 0 && medicationVM.puff > 0 {
            medicationVM.apiAddDevice { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let status):
                    print("Response sucess :\(status)")
                    if self.isFromDeviceList {
                        
                        self.navigationController?.popToRootViewController(animated: true)
                    } else if !self.medicationVM.isEdit {
                        self.medicationVM.selectedMedication.uuid = BLEHelper.shared.discoveredPeripheral!.identifier.uuidString
                        UserDefaultManager.selectedMedi = self.medicationVM.selectedMedication.toDic()
                        let addAnotherDeviceVC = AddAnotherDeviceVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
                        self.pushVC(controller: addAnotherDeviceVC)
                    } else {
                        self.popVC()
                    }
                case .failure(let message):
                    CommonFunctions.showMessage(message: message)
                }
            }
        } else {
            if medicationVM.puff == 0 {
            CommonFunctions.showMessage(message: ValidationMsg.addPuff)
            } else {
                CommonFunctions.showMessage(message: StringMedication.addDose)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func reminderValue(_ sender: UISwitch) {
        print(sender.isOn)
        // TODO: Set Local push notification
    }
    
    @IBAction func btnAddDoseClick(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let dosetime =  dateFormatter.string(from: Date())
        self.medicationVM.arrTime.append(dosetime)
        tblDoseTime.reloadData()
        lblAddDose.text =  self.medicationVM.arrTime.count == 0 ? StringMedication.addFirstDose : StringMedication.addDose
    }
    
    @IBAction func btnEditDose(_ sender: UIButton) {
        myPicker.tag = sender.tag
        myPicker.isHidden = false
    }
    
    @IBAction func btnRemoveDoseTimeClick(_ sender: UIButton) {
        self.medicationVM.arrTime.remove(at: sender.tag)
        tblDoseTime.reloadData()
        lblAddDose.text =  self.medicationVM.arrTime.count == 0 ? StringMedication.addFirstDose : StringMedication.addDose
    }
    
    @IBAction func tapNoOfDose(_ sender: UIButton) {
        dropDown.anchorView = btnPuff
        dropDown.dataSource = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]

        dropDown.selectionAction = { [weak self] (_, item) in
            guard let `self` = self else { return }
            self.txtPuff.text = item
            self.medicationVM.puff = Int(item) ?? 0
        }
        dropDown.show()
    }
    deinit {
        self.navigationController?.isNavigationBarHidden = false
    }
}
extension MedicationDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.medicationVM.arrTime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DoseTimeCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.doseTimeCell ) as! DoseTimeCell
        cell.lblDoseTime.text = "\((indexPath.row + 1).ordinal) Dose at \(self.medicationVM.arrTime[indexPath.row])"
        cell.btnRemove.tag = indexPath.row
        cell.btnEditDose.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}

extension MedicationDetailVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
   
}
