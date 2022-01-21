//
//  AddDeviceIntro.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 17/01/22.
//

import UIKit

class AddDeviceIntroVC: BaseVC {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblScanList: UITableView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var viewDeviceList: UIView!
    @IBOutlet weak var btnStartSetUp: UIButton!
    @IBOutlet weak var lblAddDevice: UILabel!
    @IBOutlet weak var lblGreat: UILabel!
    @IBOutlet weak var lbldeviceInfo: UILabel!
    @IBOutlet weak var imgAddDevice: UIImageView!
    var step : AddDeviceSteps = .Step1
    var isFromAddAnother = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setVC()
    }
    func setVC(){
        btnBack.isHidden = !isFromAddAnother
        lbldeviceInfo.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        lblGreat.font = UIFont(name: AppFont.AppBoldFont, size: 34)
        lblAddDevice.font = UIFont(name: AppFont.AppBoldFont, size: 34)
        viewDeviceList.isHidden = true
        switch step {
        case .Step1:
            lblAddDevice.isHidden  = false
            lblGreat.text = StringAddDevice.great
            imgAddDevice.image = #imageLiteral(resourceName: "inhealer")
            lblAddDevice.text = StringAddDevice.addDevice
            let attributedString = attributedText(withString: StringAddDevice.addDeviceInto, boldString: StringAddDevice.Connected_Inhaler_Sensor, font: UIFont(name: AppFont.AppRegularFont, size: 17)!)
            lbldeviceInfo.attributedText = attributedString
            btnStartSetUp.setButtonView(StringAddDevice.startSetup)
            break
        case .Step2:
            lblGreat.text = StringAddDevice.removeIsolationTag
            imgAddDevice.image = #imageLiteral(resourceName: "removeTag")
            //lblAddDevice.text = ""
            lblAddDevice.isHidden  = true
            lbldeviceInfo.text = StringAddDevice.removeIsolationTaginfo
            btnStartSetUp.setButtonView(StringAddDevice.next)
        case .Step3 :
            
            viewDeviceList.isHidden = false
            viewHeader.backgroundColor = .white
            lblHeader.text = StringAddDevice.scanlist
            lblHeader.isTitle = true
            lblHeader.textColor = .black
            tblScanList.delegate = self
            tblScanList.dataSource = self
            
            break
        case .Step4:
            lblGreat.text = StringAddDevice.connectDevice
            imgAddDevice.image = #imageLiteral(resourceName: "pairDevice")
         //   lblAddDevice.text = ""
            lblAddDevice.isHidden  = true
            lbldeviceInfo.text = StringAddDevice.connectDeviceInfo
            btnStartSetUp.setButtonView(StringAddDevice.pareDevice)
        case .Step5:
            lblGreat.text = StringAddDevice.mountDevice
            imgAddDevice.image = #imageLiteral(resourceName: "mount")
          //  lblAddDevice.text = ""
            lblAddDevice.isHidden  = true
            lbldeviceInfo.text = StringAddDevice.mountDeviceInfo
            btnStartSetUp.setButtonView(StringAddDevice.next)
        case .Step6:
            lblGreat.text = StringAddDevice.great
            imgAddDevice.image = #imageLiteral(resourceName: "medication")
            let attributedString = attributedText(withString: StringAddDevice.medicationInfo, boldString: StringAddDevice.Connected_Inhaler_Sensor, font: UIFont(name: AppFont.AppRegularFont, size: 17)!)
            lbldeviceInfo.attributedText = attributedString
            lblAddDevice.text = StringAddDevice.medication
            btnStartSetUp.setButtonView(StringAddDevice.selectMedication)
        }
    }
    @IBAction func btnBackClick(_ sender: Any) {
        popVC()
    }
    
    @IBAction func btnNextClick(_ sender: UIButton) {
        let vc = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        switch step {
        case .Step1:
            vc.step = .Step2
        case .Step2:
            vc.step = .Step3
        case .Step3:
            vc.step = .Step4
        case .Step4:
            vc.step = .Step5
        case .Step5:
            vc.step = .Step6
        case .Step6:
            let vc = MedicationVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
            
             pushVC(vc: vc)
            return
        }
        vc.isFromAddAnother = isFromAddAnother
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
    @IBAction func btnConnectClick(_ sender: UIButton) {
        let vc = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        vc.step = .Step4
        vc.isFromAddAnother = isFromAddAnother
        pushVC(vc: vc)
    }
    
}
extension AddDeviceIntroVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : BLEDeviceCell = tableView.dequeueReusableCell(withIdentifier: "BLEDeviceCell") as! BLEDeviceCell
        cell.btnConnect.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        vc.step = .Step4
        vc.isFromAddAnother = isFromAddAnother
        pushVC(vc: vc)
    }
    
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
