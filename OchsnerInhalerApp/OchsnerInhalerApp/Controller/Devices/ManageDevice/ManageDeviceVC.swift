//
//  ManageDeviceVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class ManageDeviceVC: BaseVC {
    @IBOutlet weak var tbvData: UITableView!
    private let itemCell = "ManageDeviceCell"
    
    @IBOutlet weak var btnAddAnothDevice: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    private func initUI() {
        let nib = UINib(nibName: itemCell, bundle: nil)
        tbvData.register(nib, forCellReuseIdentifier: itemCell)
        tbvData.delegate = self
        tbvData.dataSource = self
        tbvData.separatorStyle = .none
        btnAddAnothDevice.setButtonView(StringDevices.addAnotherDevice)
    }

    
    @IBAction func tapAddAnotherDevice(_ sender: Any) {
        
    }
    
}
extension ManageDeviceVC : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCell, for: indexPath) as! ManageDeviceCell
        cell.selectionStyle = .none
        setCustomFontLabel(label: cell.lblDeviceName, type: .semiBold,fontSize: 17)
        setCustomFontLabel(label: cell.lblNCDCode, type: .regular,fontSize: 17)
        setCustomFontLabel(label: cell.lblUsageLabel, type: .regular,fontSize: 17)
        setCustomFontLabel(label: cell.lblUsage, type: .bold,fontSize: 17)
        setCustomFontLabel(label: cell.lblDose, type: .regular,fontSize: 17)
        setCustomFontLabel(label: cell.lblNoOfDose, type: .regular,fontSize: 17)
        cell.btnRemoveDevice.setButtonView(StringDevices.removeDevice , 17 ,AppFont.AppRegularFont)
        cell.btnEditDirection.setButtonView(StringDevices.editDirection , 17 , AppFont.AppRegularFont)
        cell.lblUsageLabel.text = StringDevices.usage
        if indexPath.row == 0 {
            cell.lblUsage.textColor = #colorLiteral(red: 0.137254902, green: 0.7568627451, blue: 0.3294117647, alpha: 1) //#23C154
            cell.lblDeviceName.text  = "Teva(ProAir Generic)"
            cell.lblNCDCode.text = "NDC Code: 0093-3174-31"
            cell.lblUsage.text = "Maintenance"
            cell.lblDose.text = "1 Dose = 2 Puffs"
            cell.lblNoOfDose.text = "1st Dose at 8:30 am\n2nd Dose at 6:30 pm"
            
            cell.ivInhaler.image = UIImage(named: "inhaler_red")
        } else {
            cell.lblUsage.textColor = #colorLiteral(red: 0.8784313725, green: 0.1254901961, blue: 0.1254901961, alpha: 1) //#E02020
            cell.lblDeviceName.text  = "Ventolin"
            cell.lblNCDCode.text = "NDC Code: 0173-0682-20"
           
            cell.lblUsage.text = "Rescue"
            cell.lblDose.text = "1 Dose = 2 Puffs"
            cell.lblNoOfDose.text = "Take as needed"
            cell.ivInhaler.image = UIImage(named: "inhaler_blue")
        }
        
        return cell
    }
    
    
    
}
