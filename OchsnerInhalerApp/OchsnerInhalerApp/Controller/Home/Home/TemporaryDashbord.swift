//
//  TemporaryDashbord.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 08/02/22.
//

import UIKit

class TemporaryDashbord: BaseVC {
    @IBOutlet weak var tbvData: UITableView!
    private let itemCell = "TemoDashboardCell"
   private var batteryLevel = "N/A"
    override func viewDidLoad() {
        super.viewDidLoad()
  
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.macDetail(notification:)), name: .BLEGetMac, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.macDetail(notification:)), name: .BLEDisconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifyBatteryLevel(notification:)), name: .BLEBatteryLevel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.accuationLog(notification:)), name: .BLEAcuationLog, object: nil)
        // Do any additional setup after loading the view.
        initUI()
    }
    
    @objc func inhalerConnected(notification: Notification) {
        BLEHelper.shared.getmacAddress()
        BLEHelper.shared.getBetteryLevel()
        BLEHelper.shared.getAccuationNumber()
        BLEHelper.shared.getAccuationLog()        
    }
    @objc func macDetail(notification: Notification) {
        tbvData.reloadData()
        print(notification)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        BLEHelper.shared.getmacAddress()
    }
    private func initUI() {
        let nib = UINib(nibName: itemCell, bundle: nil)
        tbvData.register(nib, forCellReuseIdentifier: itemCell)
        tbvData.delegate = self
        tbvData.dataSource = self
        tbvData.separatorStyle = .none
       
    }

    @objc func notifyBatteryLevel(notification: Notification) {
        
        if let batteryLevel = notification.userInfo?["batteryLevel"] as? String {
           // print("batteryLevel: \(batteryLevel)")
            self.batteryLevel = batteryLevel
            self.tbvData.reloadData()
        }
      
    }
    
    @objc func accuationLog(notification: Notification) {
      //  DatabaseManager.share.deleteAllAccuationLog()
        print(notification.userInfo!)
        LocationManager.shared.locationManager
        LocationManager.shared.checkLocationPermissionAndFetchLocation(completion: { [weak self] coordination in
            guard let `self` = self else { return }
            if notification.userInfo!["uselength"]! as? Decimal != 0 {
                let isoDate = notification.userInfo?["date"] as? String
                let length = notification.userInfo!["uselength"]!
                let mac = notification.userInfo?["mac"] as? String
                let udid = notification.userInfo?["udid"] as? String
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/dd/MM HH:mm:ss"
                if  let date = dateFormatter.date(from: isoDate!) {
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    let finalDate = dateFormatter.string(from: date)
                    let dic: [String: Any] = ["date": finalDate,
                                              "useLength": length,
                                              "lat": "\(coordination.latitude)",
                                              "long": "\(coordination.longitude)",
                                              "isSync": false, "mac": mac! as Any,
                                              "udid": udid as Any,
                                              "batterylevel": self.batteryLevel]
                    DatabaseManager.share.saveAccuation(object: dic)
                }
            }
           
        })
       
    }

}
extension TemporaryDashbord: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCell, for: indexPath) as! TemoDashboardCell
        cell.selectionStyle = .none
        let medication = MedicationModelElement(jSon: UserDefaultManager.selectedMedi)
        cell.lblName.text = medication.medName ?? "N/A"
        cell.lblMacAddressLabel.text = "MAC Address: "
        cell.lblMacAddress.text = BLEHelper.shared.addressMAC
        cell.lblNDCCode.text = "NDC Code: \(medication.ndc  ?? "N/A")"
        if BLEHelper.shared.discoveredPeripheral == nil {
            cell.lblStatus.text = StringCommonMessages.connecting
        } else if BLEHelper.shared.discoveredPeripheral?.state == .connected {
            cell.lblStatus.text = StringCommonMessages.connected
            cell.btnRemove.setTitle("Remove Device", for: .normal)
        } else if BLEHelper.shared.discoveredPeripheral?.state == .disconnected {
               cell.lblStatus.text = StringCommonMessages.disconnect
            cell.btnRemove.setTitle("Add Device", for: .normal)
        }
        
       // cell.lblBattery.text = StringCommonMessages.battery
        cell.lblBatteryPercentage.text = "\(batteryLevel)%"
        
        cell.btnRemove.tag = indexPath.row
        cell.btnRemove.addTarget(self, action: #selector(tapRemove(sender:)), for: .touchUpInside)
        
        cell.btnRemove.isEnabled =  (BLEHelper.shared.discoveredPeripheral != nil && BLEHelper.shared.discoveredPeripheral!.state == .connected)
        if cell.btnRemove.isEnabled {
            cell.btnRemove.backgroundColor = .ButtonColorBlue
        } else {
            cell.btnRemove.backgroundColor = .gray
        }
        return cell
    }
    
    @objc func tapRemove(sender: UIButton) {
        BLEHelper.shared.centralManager.cancelPeripheralConnection(BLEHelper.shared.discoveredPeripheral!)
        sender.setTitle("Add Device", for: .normal)
        if let addDeviceIntroVC = self.navigationController?.viewControllers.first(where: {$0 is AddDeviceIntroVC})  as? AddDeviceIntroVC {
            addDeviceIntroVC.step = .step1
            addDeviceIntroVC.isFromAddAnother  = false
            self.navigationController?.popToViewController(addDeviceIntroVC, animated: false)
        } else {
            let addDeviceIntroVC = AddDeviceIntroVC.instantiateFromAppStoryboard(appStoryboard: .addDevice)
            addDeviceIntroVC.step = .step1
            addDeviceIntroVC.isFromAddAnother  = false
            pushVC(controller: addDeviceIntroVC)

        }
//        DatabaseManager.share.deleteAllAccuationLog()
//        BLEHelper.shared.getAccuationLog()
    }
}