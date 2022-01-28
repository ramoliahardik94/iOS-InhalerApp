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
    var selectedIndex : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        // Do any additional setup after loading the view.
    }
    func setUp(){
        lblTitle.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblTitle.text = StringMedication.titleMedication
        lblmedicationType.font = UIFont(name: AppFont.AppBoldFont, size: 23)
        lblmedicationType.text = StringMedication.inhealerType
        btnRescue.titleLabel?.font = UIFont(name: AppFont.SFProText_Bold, size: 14)
        btnMantainance.titleLabel?.font = UIFont(name: AppFont.SFProText_Bold, size: 14)
        
        btnRescue.backgroundColor = .Color_cell
        btnRescue.isOchsnerView = true
        
        btnMantainance.backgroundColor = .Color_cell
        btnMantainance.isOchsnerView = true
        
        btnNext.setButtonView(StringAddDevice.next)
        tblMedication.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    //TODO: Rescue = 1 Mantainance =2 
    @IBAction func btnMedicationType(_ sender: UIButton) {        
            btnRescue.isSelected = sender == btnRescue
            btnMantainance.isSelected = sender == btnMantainance
    }

    @IBAction func btnNextClick(_ sender: UIButton) {
        
        if btnRescue.isSelected  {
            let vc = ConnectProviderVC.instantiateFromAppStoryboard(appStoryboard: .providers)
            self.pushVC(vc: vc)
        } else {
            let vc = MedicationDetailVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
            vc.index = selectedIndex
            pushVC(vc: vc)
        }
//        if selectedIndex != nil {
//            let vc = MedicationDetailVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
//            vc.index = selectedIndex
//            pushVC(vc: vc)
//        }
//        else{
//            let alert = UIAlertController(title: "Ochsner", message: "Please select Medication.", preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
    }

  

}
extension MedicationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : MedicationCell = tableView.dequeueReusableCell(withIdentifier: "MedicationCell") as! MedicationCell
        cell.setMedicationDetailes(index: indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        for i in 0...3 {
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? MedicationCell
            cell!.btnMedication.isSelected = false
        }
        
        let cell = tableView.cellForRow(at: indexPath) as? MedicationCell
        cell?.btnMedication.isSelected = true
        
    }
    
}
