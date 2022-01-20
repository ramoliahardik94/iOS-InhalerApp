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
    
    let myPicker: NMDatePicker = {
        let v = NMDatePicker()
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
        hideKeyBoardHideOutSideTouch(customView: self.view)
        
    }
    func setDatePicker(){
        myPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myPicker)
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            
            // custom picker view should cover the whole view
            myPicker.topAnchor.constraint(equalTo: g.topAnchor),
            myPicker.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            myPicker.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            myPicker.bottomAnchor.constraint(equalTo: g.bottomAnchor),
        ])
        
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
            
            self.arrTime.remove(at: self.myPicker.tag)
            self.arrTime.insert(selectedTime, at: self.myPicker.tag)
            self.tblDoseTime.reloadData()
            
            self.myPicker.isHidden = true
        }
        myPicker.changeClosure = { [weak self] val in
            guard let self = self else {
                return
            }
            print(val)
            // do something with the selected date
        }
    }
    func setUI(){
        lblTitle.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblTitle.text = StringMedication.titleMedication

        viewMedicationName.backgroundColor = .Color_cell
        viewMedicationName.isOchsnerView = true
        viewMedicationName.clipsToBounds = true
        
        lblMedicationName.font = UIFont(name: AppFont.SFProText_Bold, size: 17)
        lblNDCCode.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        
        lblPuffTitle.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblPuffTitle.text = StringMedication.puffTitle
        
        txtPuff.isOchsnerView = true
        txtPuff.clipsToBounds = true
        txtPuff.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        
        lblDoseTime.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblDoseTime.text = StringMedication.doseTime
        
        lblReminder.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblReminder.text = StringMedication.reminder
        btnDone.setButtonView(StringMedication.done)
        
        btnAddDose.layer.borderColor = UIColor.BlueText.cgColor
        btnAddDose.tintColor = .BlueText
        btnAddDose.layer.borderWidth = 1
        btnAddDose.clipsToBounds = true
        
        lblAddDose.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        lblAddDose.textColor = .BlueText
        self.setDatePicker()
        
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
    
    @IBAction func btnEditDose(_ sender: UIButton) {
        myPicker.tag = sender.tag
        myPicker.isHidden = false
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

extension MedicationDetailVC :UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
