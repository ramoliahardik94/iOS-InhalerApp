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
    @IBOutlet weak var viewAddDose: UIView!
    var isFromDeviceList = false
    var medicationVM = MedicationVM()
    let timePicker = UIDatePicker()
    let myPicker: NMDatePicker = {
        let obj = NMDatePicker()
        return obj
    }()
    let dropDown = DropDown()
  private var userName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
        hideKeyBoardHideOutSideTouch(customView: self.view)
        self.navigationController?.isNavigationBarHidden = true
        if medicationVM.arrTime.count == 0 {
            btnAddDoseClick(UIButton())
        }
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
       
        swReminder.isOn =  UserDefaultManager.isAddReminder
        doGetProfileData()
        permissionForReminder(isShowMsg: false)
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        self.popVC()
    }
    
    @IBAction func btnDoneClick(_ sender: UIButton) {
        if swReminder.isOn {
            addReminderToCalender()
        }
        if medicationVM.arrTime.count > 0 && medicationVM.puff > 0 {
            medicationVM.apiAddDevice(isreminder: swReminder.isOn) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let status):
                    print("Response sucess :\(status)")
                    UserDefaultManager.isAddReminder = self.swReminder.isOn
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
                CommonFunctions.showMessage(message: ValidationMsg.addDose)
            }
        }
    }
    
    @IBAction func reminderValue(_ sender: UISwitch) {
        print(sender.isOn)
        if sender.isOn {
            permissionForReminder(isShowMsg: true)
        }
    }
    
    @IBAction func btnAddDoseClick(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let dosetime =  dateFormatter.string(from: Date())
        self.medicationVM.arrTime.append(dosetime)
        tblDoseTime.reloadData()
        lblAddDose.text =  self.medicationVM.arrTime.count == 0 ? StringMedication.addFirstDose : StringMedication.addDose
        viewAddDose.isHidden = self.medicationVM.arrTime.count  == 10
    }
    
    @IBAction func btnEditDose(_ sender: UIButton) {
        myPicker.tag = sender.tag
        myPicker.isHidden = false
    }
    
    @IBAction func btnRemoveDoseTimeClick(_ sender: UIButton) {
        self.medicationVM.arrTime.remove(at: sender.tag)
        tblDoseTime.reloadData()
        lblAddDose.text =  self.medicationVM.arrTime.count == 0 ? StringMedication.addFirstDose : StringMedication.addDose
        viewAddDose.isHidden = self.medicationVM.arrTime.count  == 10
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
  
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.medicationVM.medTypeId = 2
        
    }
    // for add reminder event
    
    private func permissionForReminder(isShowMsg: Bool) {
        NotificationManager.shared.isAllowed { isAllow in
            if !isAllow {
                DispatchQueue.main.async {
                    self.swReminder.setOn(false, animated: true)
                    if isShowMsg {
                        CommonFunctions.showMessage(message: StringMedication.permissionDose, {_ in })
                    }
                }
            }
        }
    }
    
    func addReminderToCalender() {
         UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["com.ochsner.inhalertrack.reminderdose"])
       /* for obj in self.medicationVM.arrTime {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                let today = Date()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let strDate = "\(dateFormatter.string(from: today)) \(obj)"
                dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
                if let date = dateFormatter.date(from: strDate) {
                    
                    let title = "\(StringAddDevice.titleAddDevice)\n\(StringDevices.yourNextDose) \(obj) for \(lblMedicationName.text ?? "")"
                    
                }
        }*/
        
       // var arrayDate = [Date]()
        var stingDate = ""
        var graterDate =  Date()
        var showDoesTime  = ""
        for obj in self.medicationVM.arrTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            let today = Date()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let strDate = "\(dateFormatter.string(from: today)) \(obj)"
            dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
            if stingDate == "" {
                stingDate = strDate
                showDoesTime = obj
            }
            
            if let date = dateFormatter.date(from: strDate) {
                if stingDate == "" {
                    graterDate = date
                }
                if date > dateFormatter.date(from: stingDate) ?? Date() {
                    stingDate = strDate
                    graterDate = date
                    showDoesTime = obj
                }
            }
        }
        print("graterDate \(graterDate)")
        let calendar = Calendar.current
        let datesub = calendar.date(byAdding: .minute, value: 30, to: graterDate) ?? Date()
        let title = "\(self.userName)Just reminding you about your scheduled \(lblMedicationName.text ?? "") doses at \(showDoesTime).Please take your dose and keep your device and Application nearby to update the latest reading. Ignore if the reading is already updated."
        setNotification(date: datesub, titile: title)
        
    }
    
    func setNotification(date: Date, titile: String) {
        Logger.logInfo(" setNotification start \(date)")
        let content = UNMutableNotificationContent()
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        content.title = StringAddDevice.titleAddDevice
        content.body =  titile
        content.sound = UNNotificationSound.default
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["com.ochsner.inhalertrack.reminderdose"])
        let request = UNNotificationRequest(identifier: "com.ochsner.inhalertrack.reminderdose", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
            if let error = error {
                print("SOMETHING WENT WRONG\(error.localizedDescription))")
            }
        })
        Logger.logInfo(" setNotification End")
    }
    private func doGetProfileData() {
        let profileVM = ProfileVM()
      
        profileVM.doGetProfile { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let status):
                print("Response sucess :\(status)")
                self.userName = "Hi \(profileVM.userData.user?.firstName ?? ""), "
            case .failure(let message):
                CommonFunctions.showMessage(message: message)
            }
        }
    }
 }
extension MedicationDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.medicationVM.arrTime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DoseTimeCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.doseTimeCell ) as! DoseTimeCell
        cell.lblDoseTime.text = "\((indexPath.row + 1).ordinal) Dose at \(self.medicationVM.arrTime[indexPath.row])"
        cell.btnRemove.isHidden = (indexPath.row == 0)
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
