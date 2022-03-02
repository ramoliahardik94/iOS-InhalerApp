//
//  MedicationDetailVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 19/01/22.
//

import UIKit
import DropDown
import EventKit

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
    private var  eventStore = EKEventStore()
    private var reminders = [EKReminder]()
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
    }
    
    @IBAction func btnBackClick(_ sender: Any) {
        self.popVC()
    }
    
    @IBAction func btnDoneClick(_ sender: UIButton) {
        removeReminders()
       
        if swReminder.isOn {
            setReminders()
        }
        if medicationVM.arrTime.count > 0 && medicationVM.puff > 0 {
            medicationVM.apiAddDevice { [weak self] result in
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
    func setReminders() {
        let appDelegate = UIApplication.shared.delegate
        as! AppDelegate
        if appDelegate.eventStore == nil {
            permissionForReminder()
        } else {
            self.addReminderToCalender()
        }
    }
    
    func addReminderToCalender() {
        for obj in self.medicationVM.arrTime {
            let appDelegate = UIApplication.shared.delegate
            as! AppDelegate
            if let appleEventStore = appDelegate.eventStore {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                let today = Date()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let strDate = "\(dateFormatter.string(from: today)) \(obj)"
                dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
                if let date = dateFormatter.date(from: strDate) {
                    let reminder: EKReminder = EKReminder(eventStore: appleEventStore)
                    reminder.title = "\(StringAddDevice.titleAddDevice)\n\(StringDevices.yourNextDose) \(obj) for \(lblMedicationName.text ?? "")"
                    reminder.notes = ""
                    let cal = Calendar(identifier: .gregorian)
                    let nextyearDate = cal.date(byAdding: .year, value: 1, to: Date())
                    reminder.dueDateComponents = cal.dateComponents([.year, .month, .day, .hour, .minute], from: nextyearDate!)
                    print(nextyearDate!)
                    reminder.priority = 1
                    // reminder.
                    reminder.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .daily, interval: 7, end: nil))
                    // reminder.notes = ""
                    reminder.calendar = appleEventStore.defaultCalendarForNewReminders()
                    let alarm = EKAlarm(absoluteDate: date.addingTimeInterval(-600)) // Before 10 min alarm is show
                    reminder.addAlarm(alarm)
                   
                    do {
                        try appleEventStore.save(reminder, commit: true)
                        //                        save(event, span: .thisEvent)
                        
                        print("events added with dates:")
                        
                    } catch {
                       
                        print(error.localizedDescription)
                        return
                    }
                    print("Saved Event")
                }
            }
        }
    }
    
    @IBAction func reminderValue(_ sender: UISwitch) {
        print(sender.isOn)
        if sender.isOn {
            permissionForReminder()
        } else {
        }
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
    private func permissionForReminder() {
        let appDelegate = UIApplication.shared.delegate
        as! AppDelegate
        if appDelegate.eventStore == nil {
            appDelegate.eventStore = EKEventStore()
            
            appDelegate.eventStore?.requestAccess(
                to: .reminder, completion: { (granted, error) in
                    if !granted {
                        print("Access to store not granted")
                        print(error?.localizedDescription as Any)
                    } else {
                        print("Access granted")
                        
                    }
                })
        }
    }
    
    func removeReminders() {
        if reminders.count > 0 {
            for item in  reminders {
                if item.title.contains(StringDevices.yourNextDose) {
                    do {
                        try eventStore.remove(item, commit: true)
                        //                        save(event, span: .thisEvent)
                        print("events remove")
                        //   self.reminders.remove(at: index)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.medicationVM.medTypeId = 2
        doGetAddReminders()
    }
    private func doGetAddReminders() {
        eventStore.requestAccess(
            to: .reminder, completion: { (granted, error) in
                if !granted {
                    print("Access to store not granted")
                    print(error?.localizedDescription as Any)
                } else {
                    print("Access granted")
                    
                    let predicate = self.eventStore.predicateForReminders(in: nil)
                    
                    self.eventStore.fetchReminders(matching: predicate, completion: { reminders in
                        self.reminders = reminders ?? []
                       // print("remnders count  \(reminders?.count)")
                    })
                }
            })
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
