//
//  HomeVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit
import DropDown

class HomeVC: BaseVC {
    @IBOutlet weak var activitySync: UIActivityIndicatorView!
    @IBOutlet weak var lblSyncTitle: UILabel!
    @IBOutlet weak var heightSync: NSLayoutConstraint!
    @IBOutlet weak var syncView: UIView!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var viewMainTableview: UIView!
    @IBOutlet weak var tbvDeviceData: UITableView!
    private let itemCellDevice = "HomeDeviceCell"
    private var homeVM = HomeVM()
    var refreshControl = UIRefreshControl()
    var isPull = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.apiGetHomeData(notification:)), name: .DataSyncDone, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = StringAddDevice.titleAddDevice
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems =  [UIBarButtonItem(image: UIImage(named: "notifications_white"), style: .plain, target: self, action: #selector(tapNotification))]
        let deviceList = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        if BLEHelper.shared.connectedPeripheral.isEmpty  && deviceList.count != 0 {
            Logger.logInfo("deviceuse: HomeVC :: BLEHelper.shared.connectedPeripheral.isEmpty")
            BLEHelper.shared.scanPeripheral()
        } else if !BLEHelper.shared.connectedPeripheral.isEmpty {
             let disconnectedDevice = BLEHelper.shared.connectedPeripheral.filter({$0.discoveredPeripheral?.state != .connected})
                for obj in disconnectedDevice {
                    BLEHelper.shared.connectPeriPheral(peripheral: obj.discoveredPeripheral!)
                }
            CommonFunctions.getLogFromDeviceAndSync()
        }
        apiDashboard()
    }
    
    private func  initUI() {        
        initTableview()
        lblNoData.setFont()
        lblNoData.text = StringCommonMessages.noDataFount
        lblNoData.isHidden = true
        syncView.backgroundColor = .ButtonColorBlue
        syncView.isHidden = true
    }
    
    private func initTableview() {
        self.view.setNeedsLayout()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl.tag = 500
        if let view = tbvDeviceData.viewWithTag(500) {
            view.removeFromSuperview()
        }
        tbvDeviceData.addSubview(refreshControl)
        let nib = UINib(nibName: itemCellDevice, bundle: nil)
        tbvDeviceData.register(nib, forCellReuseIdentifier: itemCellDevice)
        tbvDeviceData.delegate = self
        tbvDeviceData.dataSource = self
        tbvDeviceData.separatorStyle = .none
       }
    
    @objc func refresh(_ sender: AnyObject) {
        let deviceList = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        let connectedDevice =  BLEHelper.shared.connectedPeripheral.filter({$0.discoveredPeripheral?.state == .connected})
        if connectedDevice.count > 0 {
            CommonFunctions.getLogFromDeviceAndSync()
        } else if BLEHelper.shared.connectedPeripheral.isEmpty  && deviceList.count != 0 {
            Logger.logInfo("Scan with HomeVC refresh")
            BLEHelper.shared.scanPeripheral()
        } else {
            self.refreshControl.endRefreshing()
        }
        
        self.refreshControl.endRefreshing()
    }
    


    @objc func apiGetHomeData(notification: Notification) {
       // CommonFunctions.showGlobalProgressHUD(self)
        apiDashboard()
    }
    func apiDashboard() {
        if isPull == false {
            isPull = true
            homeVM.apiDashboardData {  [weak self] isSuccess in
                guard let`self` = self else { return }
                self.isPull = false
                switch isSuccess {
                case .success (_):
                    DispatchQueue.main.async {
                        if  self.homeVM.dashboardData.count == 0 {
                            self.lblNoData.isHidden = false
                        } else {
                            self.lblNoData.isHidden = true
                        }
                        self.tbvDeviceData.reloadData()
                    }
                case .failure(let message):
                    DispatchQueue.main.async {
                        CommonFunctions.showMessage(message: message)
                    }
                }
            }
        }
    }

}
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeVM.dashboardData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCellDevice, for: indexPath) as! HomeDeviceCell
        let item = homeVM.dashboardData[indexPath.row]
        cell.item = item
        cell.layoutSubviews()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension UIStackView {
    
    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }
    
}
