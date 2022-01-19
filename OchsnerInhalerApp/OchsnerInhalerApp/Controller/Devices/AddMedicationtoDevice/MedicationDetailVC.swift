//
//  MedicationDetailVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 19/01/22.
//

import UIKit

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
    let timePicker = UIDatePicker()
    var index = 0
    var arrTime = ["8:30 am","6:30 pm"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
    }
    func setUI(){
        lblTitle.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblTitle.text = StringMedication.titleMedication
        
        viewMedicationName.layer.cornerRadius = 6
        viewMedicationName.backgroundColor = .Color_cell
        viewMedicationName.layer.borderColor = UIColor.TextField_Border_Color.cgColor
        viewMedicationName.layer.borderWidth = 1
        viewMedicationName.clipsToBounds = true
        
        lblMedicationName.font = UIFont(name: AppFont.SFProText_Bold, size: 17)
        lblNDCCode.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        
        lblPuffTitle.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblPuffTitle.text = StringMedication.puffTitle
        
        txtPuff.layer.cornerRadius = 6
        txtPuff.layer.borderColor = UIColor.TextField_Border_Color.cgColor
        txtPuff.layer.borderWidth = 1
        txtPuff.clipsToBounds = true
        txtPuff.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        
        lblDoseTime.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblDoseTime.text = StringMedication.doseTime
        
        lblReminder.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblReminder.text = StringMedication.reminder
        btnDone.setButtonView(StringMedication.done)
        
        btnAddDose.layer.cornerRadius = 6
        btnAddDose.layer.borderColor = UIColor.BlueText.cgColor
        btnAddDose.tintColor = .BlueText
        btnAddDose.layer.borderWidth = 1
        btnAddDose.clipsToBounds = true
        
        lblAddDose.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        lblAddDose.textColor = .BlueText
        
        switch index {
        case 0:
            lblNDCCode.text = "NCD Code: 59310-579-22"
            lblMedicationName.text = "ProAir"
        case 1:
            lblNDCCode.text = "NDC Code: 0093-3174-31"
            lblMedicationName.text = "Teva (ProAir Generic) "
        case 2:
            lblNDCCode.text = "NCD Code: 0173-0682-20"
            lblMedicationName.text = "Ventolin"
        default:
            lblNDCCode.text = "NDC Code: 66993-019-68"
            lblMedicationName.text = "Prasco (Ventolin Generic)"
        }
        
    }
    @IBAction func btnBackClick(_ sender: Any) {
        self.popVC()
    }
    @IBAction func btnDoneClick(_ sender: UIButton) {
        let vc = AddAnotherDeviceVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        pushVC(vc: vc)
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
    }
    @IBAction func btnAddDoseClick(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let Dosetime =  dateFormatter.string(from: Date())
        arrTime.append(Dosetime)
        tblDoseTime.reloadData()
    }
    
    
    @IBAction func btnRemoveDoseTimeClick(_ sender: UIButton) {
        arrTime.remove(at: sender.tag)
        tblDoseTime.reloadData()
    }
}
extension MedicationDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : DoseTimeCell = tableView.dequeueReusableCell(withIdentifier: "DoseTimeCell") as! DoseTimeCell
        cell.lblDoseTime.text = "\((indexPath.row + 1).ordinal) Dose at \(arrTime[indexPath.row])"
        cell.btnRemove.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        openTimePicker(i: indexPath.row)
        
    }
    
}
extension MedicationDetailVC {
    func openTimePicker(i :Int)  {
        timePicker.datePickerMode = UIDatePicker.Mode.time
        timePicker.tag = i
        timePicker.frame = CGRect(x: 0.0, y: (self.view.frame.height/2 + 60), width: self.view.frame.width, height: 150.0)
        timePicker.backgroundColor = UIColor.white
        self.view.addSubview(timePicker)
        timePicker.addTarget(self, action: #selector(startTimeDiveChanged(sender:)), for: .valueChanged)
    }

    @objc func startTimeDiveChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat =  "hh:mm a"
        let selectedTime = formatter.string(from: sender.date)
        
        arrTime.remove(at: sender.tag)
        arrTime.insert(selectedTime, at: sender.tag)
        arrTime[sender.tag] = selectedTime
        tblDoseTime.reloadData()
        timePicker.removeFromSuperview() // if you want to remove time picker
    }
}
