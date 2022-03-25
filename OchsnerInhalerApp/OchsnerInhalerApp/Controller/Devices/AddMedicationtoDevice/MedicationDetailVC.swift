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
            myPicker.topAnchor.constraint(equalTo: conObj.topAnchor),
            myPicker.leadingAnchor.constraint(equalTo: conObj.leadingAnchor),
            myPicker.trailingAnchor.constraint(equalTo: conObj.trailingAnchor),
            myPicker.bottomAnchor.constraint(equalTo: conObj.bottomAnchor)
        ])
        myPicker.isHidden = true
        myPicker.mode = .time
        myPicker.dismissClosure = { [weak self] val in
            guard let self = self else {
                return
            }
            let formatter = DateFormatter()
            formatter.dateFormat =  DateFormate.doseTime
            let selectedTime = formatter.string(from: val)
            if !self.validateTime(time: selectedTime, isEdit: true, index: self.myPicker.tag) {
                self.view.makeToast(ValidationMsg.doseError)
            } else {
                self.medicationVM.arrTime.remove(at: self.myPicker.tag)
                self.medicationVM.arrTime.insert(selectedTime, at: self.myPicker.tag)
            }
            self.setArrTime(descending: false)
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
    
    func validateDosesOnDone() -> Bool {
        for (index, element) in self.medicationVM.arrTime.enumerated() {
            print("Item \(index): \(element)")
            if !validateTime(time: element, isEdit: true, index: index) {
                return false
            }
        }

        return true
    }
    
    @IBAction func btnDoneClick(_ sender: UIButton) {
        if validateDosesOnDone() {
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
        } else {
            CommonFunctions.showMessage(message: ValidationMsg.doseError)
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
        dateFormatter.dateFormat = DateFormate.doseTime
        var displayDate: Date
        let date = self.medicationVM.arrTime.map({dateFormatter.date(from: $0)!})
        //TODO: Hours gap for two dose add time
        let hour = 8
        if date.count > 0 {
            displayDate = date[self.medicationVM.arrTime.count - 1].addingTimeInterval(TimeInterval((60*60) * hour))
        } else {
            displayDate = Date()
        }
        let dosetime =  dateFormatter.string(from: displayDate)
        if !validateTime(time: dosetime) {
            self.view.makeToast(ValidationMsg.doseError)
        }
        self.medicationVM.arrTime.append(dosetime)
        setArrTime(descending: false)
        tblDoseTime.reloadData()
        lblAddDose.text =  self.medicationVM.arrTime.count == 0 ? StringMedication.addFirstDose : StringMedication.addDose
        viewAddDose.isHidden = self.medicationVM.arrTime.count  == 10
    }
    
    @IBAction func btnEditDose(_ sender: UIButton) {
        myPicker.tag = sender.tag
        myPicker.isHidden = false
        myPicker.tag = sender.tag
        myPicker.isHidden = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormate.doseTime
        let dosetime = dateFormatter.date(from: self.medicationVM.arrTime[sender.tag])
        myPicker.selectedDate = dosetime!
        myPicker.dPicker.setDate(dosetime ?? Date(), animated: false)
        
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
        if self.medicationVM.arrTime.count > 0 {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["com.ochsner.inhalertrack.reminderdose"])
            if let graterDate =  self.medicationVM.arrTime.last?.getDate(format: DateFormate.doseTime) {
                let time = self.medicationVM.arrTime.last!
                var showDoesTime  = " "
                if time.count >= 2 {
                    showDoesTime = "\(time[0]) \(time[1])"
                }
                var calendar = Calendar(identifier: .gregorian)
                calendar.timeZone = .current
                let datesub = calendar.date(byAdding: .minute, value: 30, to: graterDate)
             
                let title = String(format: StringLocalNotifiaction.reminderBody, self.userName.trimmingCharacters(in: .whitespacesAndNewlines), lblMedicationName.text ?? "", showDoesTime )
                
                // let title = "\(self.userName)Just reminding you about your scheduled \(lblMedicationName.text ?? "") doses at \(showDoesTime).Please take your dose and keep your device and Application nearby to update the latest reading. Ignore if the reading is already updated."
                setNotification(date: datesub ?? Date().addingTimeInterval(1800), titile: title, calendar: calendar)
            }
        }
    }
    
    func setNotification(date: Date, titile: String, calendar: Calendar) {
        Logger.logInfo("Set Reminder For Time : \(date)")
        let content = UNMutableNotificationContent()
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        content.title = StringAddDevice.titleAddDevice
        content.body =  titile
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "com.ochsner.inhalertrack.reminderdose", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
            
            if let error = error {
                Logger.logInfo("SOMETHING WENT WRONG Notification\(error.localizedDescription))")
            } else {
                Logger.logInfo("Notification set for \(components)")
            }
        })
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
    
    func setArrTime(descending: Bool) {
        if descending {
            self.medicationVM.arrTime = self.medicationVM.arrTime.map({$0.getDate(format: DateFormate.doseTime, isUTC: true)}).sorted(by: { $0.compare($1) == .orderedDescending }).map({$0.getString(format: DateFormate.doseTime, isUTC: true)})
        } else {
            self.medicationVM.arrTime = self.medicationVM.arrTime.map({$0.getDate(format: DateFormate.doseTime, isUTC: true)}).sorted().map({$0.getString(format: DateFormate.doseTime, isUTC: true)})
        }
        print(self.medicationVM.arrTime)
    }
    
    func validateTime(time: String, isEdit: Bool = false, index: Int = 0) -> Bool {
        var inx = 0
        if self.medicationVM.arrTime.count > 1 {
            while(inx !=  self.medicationVM.arrTime.count - 1 ) {
                if (isEdit && inx != index) || !isEdit {
                    let timeformatter = DateFormatter()
                    timeformatter.timeZone = .current
                    timeformatter.dateFormat = DateFormate.doseTime
                    guard let time1 = timeformatter.date(from: self.medicationVM.arrTime[inx]),
                          let time2 = timeformatter.date(from: time) else { return false }
                    let interval = time2.timeIntervalSince(time1)
                    let hour = interval / 3600
                    // TODO: minimum time for two dose
                    if abs(hour) == 0 { //  if abs(hour) < 1 { for minimum one hour
                        return false
                    }
                    print("\(inx) == \(self.medicationVM.arrTime.count)")
                }
                inx += 1
            }
        }
        return true
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
