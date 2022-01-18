//
//  AddDeviceIntro.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 17/01/22.
//

import UIKit

class AddDeviceIntroVC: UIViewController {

    @IBOutlet weak var btnStartSetUp: UIButton!
    @IBOutlet weak var lblAddDevice: UILabel!
    @IBOutlet weak var lblGreat: UILabel!
    @IBOutlet weak var lbldeviceInfo: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setVC()
    }
    func setVC(){
        lblGreat.text = StringAddDevice.great
        lblAddDevice.text = StringAddDevice.addDevice
        lbldeviceInfo.attributedText = StringAddDevice.addDeviceInto.htmlToAttributedString
        lblGreat.font = UIFont(name: AppFont.AppSemiBoldFont, size: 34)
        lblAddDevice.font = UIFont(name: AppFont.AppSemiBoldFont, size: 34)
        
        btnStartSetUp.setButtonView(StringAddDevice.startSetup)
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
