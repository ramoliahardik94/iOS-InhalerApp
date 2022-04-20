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
    
    var viewSelected: UIView {
        let view = UIView()
       // view.backgroundColor = (indexSub <= item.numerator ?? 0) ? #colorLiteral(red: 0.1960784314, green: 0.7725490196, blue: 1, alpha: 1) : .white
        view.backgroundColor =  #colorLiteral(red: 0.1960784314, green: 0.7725490196, blue: 1, alpha: 1)
        view.layer.borderColor =  #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        view.layer.borderWidth = 1
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        view.widthAnchor.constraint(equalToConstant: 16).isActive = true
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        initUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.apiGetHomeData(notification:)), name: .DataSyncDone, object: nil)
        apiDashboard()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = StringAddDevice.titleAddDevice
        
        let deviceList = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        if BLEHelper.shared.connectedPeripheral.isEmpty {
            Logger.logInfo("deviceuse: HomeVC :: BLEHelper.shared.connectedPeripheral.isEmpty")
            BLEHelper.shared.scanPeripheral()
        } else {
             let disconnectedDevice = BLEHelper.shared.connectedPeripheral.filter({$0.discoveredPeripheral?.state != .connected})
                for obj in disconnectedDevice {
                    BLEHelper.shared.connectPeriPheral(peripheral: obj.discoveredPeripheral!)
                }
            CommonFunctions.getLogFromDeviceAndSync()
        }
    }
    
    private func  initUI() {
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems =  [UIBarButtonItem(image: UIImage(named: "notifications_white"), style: .plain, target: self, action: #selector(tapNotification))]
        initTableview()
        lblNoData.text = StringCommonMessages.noDataFount
        lblNoData.isHidden = true
        syncView.backgroundColor = .ButtonColorBlue
        syncView.isHidden = true
    }
    
    private func initTableview() {
        self.view.setNeedsLayout()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tbvDeviceData.addSubview(refreshControl)
        let nib = UINib(nibName: itemCellDevice, bundle: nil)
        tbvDeviceData.register(nib, forCellReuseIdentifier: itemCellDevice)
        tbvDeviceData.delegate = self
        tbvDeviceData.dataSource = self
        tbvDeviceData.separatorStyle = .none
       }
    
    @objc func refresh(_ sender: AnyObject) {
        let connectedDevice =  BLEHelper.shared.connectedPeripheral.filter({$0.discoveredPeripheral?.state == .connected})
            if connectedDevice.count > 0 {
                CommonFunctions.getLogFromDeviceAndSync()
                apiDashboard()
            } else {
                Logger.logInfo("Scan with HomeVC refresh")
                BLEHelper.shared.scanPeripheral()
            }
            self.refreshControl.endRefreshing()
    }
    
    @objc func  tapNotification () {
        let notificationVC  = NotificationVC.instantiateFromAppStoryboard(appStoryboard: .main)       
        self.pushVC(controller: notificationVC)
    }

    @objc func apiGetHomeData(notification: Notification) {
       // CommonFunctions.showGlobalProgressHUD(self)
        apiDashboard()
    }
    func apiDashboard(){
        homeVM.apiDashboardData {  [weak self] isSuccess in
            guard let`self` = self else { return }
         //   CommonFunctions.hideGlobalProgressHUD(self)
            switch isSuccess {
            case .success(let status):
                DispatchQueue.main.async {
                    print("Response sucess :\(status)")
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
