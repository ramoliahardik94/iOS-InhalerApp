//
//  OTAUpgradeDetailsVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 19/05/22.
//

import UIKit

class OTAUpgradeDetailsVC: BaseVC {

    @IBOutlet weak var btnUpgradeAll: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var tblview: UITableView!
    @IBOutlet weak var lblDetail1: UILabel!
    @IBOutlet weak var lblDetail2: UILabel!
    @IBOutlet weak var lblDetail3: UILabel!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    var arrDevice = [Device]()
    private let itemCell = CellIdentifier.OTADeviceCell


    override func viewDidLoad() {
        
        super.viewDidLoad()
        headerTitle.setFont(type: .semiBold, point: 17)
        headerTitle.text = OTAMessages.titleList
        
        lblDetail1.text = OTAMessages.infoList1
        lblDetail1.setFont(type: .regular, point: 17)
        
        lblDetail2.text = OTAMessages.infoList2
        lblDetail2.setFont(type: .regular, point: 17)
        
        lblDetail3.text = OTAMessages.infoList3
        lblDetail3.setFont(type: .regular, point: 17)
        
        getViewDoseTaken(view: view1)
        getViewDoseTaken(view: view2)
        getViewDoseTaken(view: view3)
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.topItem?.title = StringAddDevice.titleAddDevice
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem =  UIBarButtonItem(image: UIImage(named: "ic_back_arrow_white"), style: .plain, target: self, action: #selector(tapBack))
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEDisconnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inhalerConnected(notification:)), name: .BLEChange, object: nil)
        
        let nib = UINib(nibName: itemCell, bundle: nil)
        tblview.register(nib, forCellReuseIdentifier: itemCell)
        tblview.separatorStyle = .none
        // Do any additional setup after loading the view.
        let device = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        arrDevice = device
        btnUpgradeAll.setButtonView(OTAMessages.upgradeAll)
        BLEHelper.shared.scanPeripheral()
    }
    override func viewWillAppear(_ animated: Bool) {
        let device = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        arrDevice = device
        tblview.reloadData()
    }

    func getViewDoseTaken(view: UIView) {
        // view.backgroundColor = (indexSub <= item.numerator ?? 0) ? #colorLiteral(red: 0.1960784314, green: 0.7725490196, blue: 1, alpha: 1) : .white
        view.backgroundColor =  #colorLiteral(red: 0.1960784314, green: 0.7725490196, blue: 1, alpha: 1)
        view.layer.borderColor =  #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        view.layer.borderWidth = 1
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        view.widthAnchor.constraint(equalToConstant: 16).isActive = true
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
    }
    
    deinit {
        BLEHelper.shared.stopScanPeriphral()
    }
    
    @objc func tapBack() {
       let storyBoard = UIStoryboard(name: "Main", bundle: nil)
       let homeTabBar  = storyBoard.instantiateViewController(withIdentifier: "HomeTabBar") as! UITabBarController
       homeTabBar.selectedIndex = 0
       BaseVC().rootVC(controller: homeTabBar)
    }
    
    @IBAction func btnUpgradeAllClick(_ sender: Any) {
        if  let peripheral = BLEHelper.shared.connectedPeripheral.first(where: {$0.discoveredPeripheral?.state == .connected && $0.version != Constants.AppContainsFirmwareVersion}) {
            peripheral.discoveredPeripheral!.delegate = nil
            peripheral.isOTAUpgrade = true
            let bleUpgrade = BLEOTAUpgrade.instantiateFromAppStoryboard(appStoryboard: .addDevice)
            bleUpgrade.selectedPeripheral = peripheral.discoveredPeripheral
            bleUpgrade.modalPresentationStyle = .overCurrentContext
            let medName = arrDevice.first(where: {$0.mac == peripheral.addressMAC})?.medname ?? ""
            bleUpgrade.medname = medName
            bleUpgrade.isUpdateAll = true
            self.presentVC(controller: bleUpgrade)
        }
        
    }
    
 
}

extension OTAUpgradeDetailsVC: UITableViewDelegate, UITableViewDataSource, OTAUpgradeDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDevice.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCell, for: indexPath) as! OTADeviceCell
        cell.selectionStyle = .none
        cell.device = arrDevice[indexPath.row]
        cell.delegate = self
        cell.viewbottom.isHidden = indexPath.row != (arrDevice.count - 1)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func upgradeDevice(peripheral: PeriperalType, medName: String) {
        peripheral.discoveredPeripheral!.delegate = nil
        peripheral.isOTAUpgrade = true
        let bleUpgrade = BLEOTAUpgrade.instantiateFromAppStoryboard(appStoryboard: .addDevice)
        bleUpgrade.selectedPeripheral = peripheral.discoveredPeripheral
        bleUpgrade.modalPresentationStyle = .overCurrentContext
        bleUpgrade.medname = medName
        self.presentVC(controller: bleUpgrade)
    }
}
extension OTAUpgradeDetailsVC {
    
    @objc func inhalerConnected(notification: Notification) {
        DispatchQueue.main.async { [self] in
            let device = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
            arrDevice = device
            tblview.reloadData()
        }
    }
}
