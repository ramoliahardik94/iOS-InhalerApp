//
//  AddDeviceIntro.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 17/01/22.
//

import UIKit

class AddDeviceIntroVC: BaseVC {

    @IBOutlet weak var btnStartSetUp: UIButton!
    @IBOutlet weak var lblAddDevice: UILabel!
    @IBOutlet weak var lblGreat: UILabel!
    @IBOutlet weak var lbldeviceInfo: UILabel!
    @IBOutlet weak var imgAddDevice: UIImageView!
    var step : AddDeviceSteps = .Step1
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setVC()
    }
    func setVC(){
        lbldeviceInfo.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        lblGreat.font = UIFont(name: AppFont.AppBoldFont, size: 34)
        lblAddDevice.font = UIFont(name: AppFont.AppBoldFont, size: 34)
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
            
        case .Step3:
            lblGreat.text = StringAddDevice.connectDevice
            imgAddDevice.image = #imageLiteral(resourceName: "pairDevice")
         //   lblAddDevice.text = ""
            lblAddDevice.isHidden  = true
            lbldeviceInfo.text = StringAddDevice.connectDeviceInfo
            btnStartSetUp.setButtonView(StringAddDevice.pareDevice)
        case .Step4:
            lblGreat.text = StringAddDevice.mountDevice
            imgAddDevice.image = #imageLiteral(resourceName: "mount")
          //  lblAddDevice.text = ""
            lblAddDevice.isHidden  = true
            lbldeviceInfo.text = StringAddDevice.mountDeviceInfo
            btnStartSetUp.setButtonView(StringAddDevice.next)
        case .Step5:
            lblGreat.text = StringAddDevice.great
            imgAddDevice.image = #imageLiteral(resourceName: "medication")
            let attributedString = attributedText(withString: StringAddDevice.medicationInfo, boldString: StringAddDevice.Connected_Inhaler_Sensor, font: UIFont(name: AppFont.AppRegularFont, size: 17)!)
            lbldeviceInfo.attributedText = attributedString
            lblAddDevice.text = StringAddDevice.medication
            btnStartSetUp.setButtonView(StringAddDevice.selectMedication)
        }
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
            let vc = MedicationVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
             pushVC(vc: vc)
            return
        }
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

}
