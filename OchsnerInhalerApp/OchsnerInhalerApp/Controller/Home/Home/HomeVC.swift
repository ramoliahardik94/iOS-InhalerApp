//
//  HomeVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit
import DropDown

class HomeVC: BaseVC {

    
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var tbvDeviceData: UITableView!
 
    private let itemCellDevice = "HomeDeviceCell"
    private let itemCellGraph = "HomeGraphCell"
    
    private var homeVM = HomeVM()
    
    var expandFalg = [true, true]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        if (BLEHelper.shared.discoveredPeripheral == nil) {
            debugPrint("Peripheral not found")
            BLEHelper.shared.scanPeripheral(withTimer: false)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.doGetHomeData(notification:)), name: .SYNCSUCCESSACUATION, object: nil)
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = StringAddDevice.titleAddDevice
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems =  [UIBarButtonItem(image: UIImage(named: "notifications_white"), style: .plain, target: self, action: #selector(tapNotification))]
        if BLEHelper.shared.discoveredPeripheral != nil && BLEHelper.shared.discoveredPeripheral?.state == .connected {
            
            BLEHelper.shared.getAccuationNumber()
        }
        // doGetHomeData(notification: Notification(name: .SYNCSUCCESSACUATION, object: nil, userInfo: [:]))
    }
    @objc func tapNotification() {
        
    }
    private func  initUI() {
        let nib = UINib(nibName: itemCellDevice, bundle: nil)
        tbvDeviceData.register(nib, forCellReuseIdentifier: itemCellDevice)
        tbvDeviceData.delegate = self
        tbvDeviceData.dataSource = self
        tbvDeviceData.separatorStyle = .none
         
     
        lblNoData.text = StringCommonMessages.noDataFount
        lblNoData.isHidden = true
        doGetHomeData(notification: Notification(name: .SYNCSUCCESSACUATION, object: nil, userInfo: [:]))
       //   doLoadJson()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
            //  print("")
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.topItem?.rightBarButtonItems?.remove(at: 0)
        }
    }
    
    
    @objc func doGetHomeData(notification: Notification) {
        homeVM.dashboardData.removeAll()
        self.tbvDeviceData.reloadData()
        CommonFunctions.showGlobalProgressHUD(self)
        homeVM.doDashboardData {  [weak self] isSuccess in
            guard let`self` = self else { return }
            CommonFunctions.hideGlobalProgressHUD(self)
            switch isSuccess {
            case .success(let status):
                print("Response sucess :\(status)")
                // print("Response sucess :\(self.homeVM.dashboardData.count)")
                if  self.homeVM.dashboardData.count == 0 {
                    self.lblNoData.isHidden = false
                } else {
                    self.lblNoData.isHidden = true
                }
                DispatchQueue.main.async {
                    self.tbvDeviceData.reloadData()
                }
            case .failure(let message):
                CommonFunctions.showMessage(message: message)
            }
        }
    }
    
    // This is for reference testing purpose
    private func doLoadJson() {
        if let path = Bundle.main.path(forResource: "dashboard_response", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                    
                    let dashbaord = DashboardModel(jSon: dict)
                    print(dashbaord.maintenanceData.count)
                    
                   
                    if dashbaord.rescueData.count != 0 {
                        homeVM.dashboardData.append(contentsOf: dashbaord.rescueData)
                    }
                    if  dashbaord.maintenanceData.count != 0 {
                        homeVM.dashboardData.append(contentsOf: dashbaord.maintenanceData)
                    }
                    if  self.homeVM.dashboardData.count == 0 {
                        self.lblNoData.isHidden = false
                    } else {
                        self.lblNoData.isHidden = true
                    }
                    self.tbvDeviceData.reloadData()
                   // self.graphModel = graphDatapoints
                  //  completion(true)
                }
            } catch {
               // DDLogError("GraphDatapointViewModel > fetchOldDataFromJson failed To load JSON file from Path")
               // completion(false)
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
        
        cell.selectionStyle = .none
        
        cell.lblTodayData.textColor = .ButtonColorBlue
        cell.lblThisMonthData.textColor = .ButtonColorBlue
        cell.lblThisWeekData.textColor = .ButtonColorBlue
        
        
        cell.lblToday.text = StringHome.today
        cell.lblThisWeek.text = StringHome.thisWeek
        cell.lblThisMonth.text = StringHome.thisMonth
        cell.lblAdherance.text = StringHome.adherance
      //  cell.btnExpand.tag = indexPath.row
       // cell.btnExpand.addTarget(self, action: #selector(tapExpand(sender:)), for: .touchUpInside)
      
        let item = homeVM.dashboardData[indexPath.row]
       // cell.lblDeviceName.text = item.medName ?? StringCommonMessages.notSet
       
        if item.thisMonth?.change?.lowercased() ?? ""  == "up" {
            cell.ivThisMonth.image = UIImage(named: "arrow_up_home")
        } else {
            cell.ivThisMonth.image = UIImage(named: "arrow_down_home")
        }
        
        if item.thisMonth?.status ?? 0 == 1 {
            cell.ivThisMonth.setImageColor(.ColorHomeIconGreen)// #34C759
        } else if item.thisMonth?.status ?? 0 == 2 {
            cell.ivThisMonth.setImageColor(.ColorHomeIconOranage)// #FFA52F
        } else {
            cell.ivThisMonth.setImageColor(.ColorHomeIconRed)// #FF5A5A
        }
        
        
        if item.thisWeek?.change?.lowercased() ?? ""  == "up" {
            cell.ivThisWeek.image = UIImage(named: "arrow_up_home")
        } else {
            cell.ivThisWeek.image = UIImage(named: "arrow_down_home")
        }
        
        if item.thisWeek?.status ?? 0 == 1 {
            cell.ivThisWeek.setImageColor(.ColorHomeIconGreen)// #34C759
        } else if item.thisWeek?.status ?? 0 == 2 {
            cell.ivThisWeek.setImageColor(.ColorHomeIconOranage)// #FFA52F
        } else {
            cell.ivThisWeek.setImageColor(.ColorHomeIconRed)// #FF5A5A
        }
        let firstAttributes = [NSAttributedString.Key.font: UIFont(name: AppFont.AppBoldFont, size: 24)! ]
        let sendcotAttributes = [NSAttributedString.Key.font: UIFont(name: AppFont.AppLightItalicFont, size: 16)! ]
        
        let firstString = NSMutableAttributedString(string: "\(item.medName ?? StringCommonMessages.notSet)", attributes: firstAttributes)
        if item.type == "1" {
            // for rescue
           
            let seconfString = NSMutableAttributedString(string: "\(StringAddDevice.rescueInhaler)", attributes: sendcotAttributes)
            firstString.append(seconfString)
            cell.lblDeviceName.attributedText = firstString
            cell.viewCollectionView.isHidden = true
            cell.viewNextDose.isHidden = true
            cell.viewAdherance.isHidden = true
         // cell.lblDeviceType.text = "(Rescue Inhaler)"
            cell.viewToday.isHidden = false
            cell.lblTodayData.text = "\(item.today?.count ?? 0)"
            cell.lblThisWeekData.text = "\(item.thisWeek?.count ?? 0)"
            cell.lblThisMonthData.text = "\(item.thisMonth?.count ?? 0)"
        } else {
            // maintaince
            
            let seconfString = NSMutableAttributedString(string: "\(StringAddDevice.maintenanceInhaler)", attributes: sendcotAttributes)
            firstString.append(seconfString)
            cell.lblDeviceName.attributedText = firstString
            
            // cell.lblDeviceType.text = "(Maintenance Inhaler)"
            cell.viewToday.isHidden = true
            cell.lblThisWeekData.text = "\(item.thisWeek?.adherence ?? 0)%"
            cell.lblThisMonthData.text = "\(item.thisMonth?.adherence ?? 0)%"
            cell.viewAdherance.isHidden = false
            cell.lblNextDose.text = "Next Scheduled Dose: \(item.nextScheduledDose ?? StringCommonMessages.notSet)"
            cell.viewNextDose.isHidden = false
            
            cell.lblDeviceNameGraph.text = ""
            cell.lblDeviceTypeGraph.text = "Schedule"
            if item.dailyAdherence.count != 0 {
            //    cell.dailyAdherence = item.dailyAdherence
                let dailyAdherence = item.dailyAdherence
                let maxvalu = item.dailyAdherence.sorted { item1, item2 in
                    return item1.denominator ?? 0 > item2.denominator ?? 0
                }
                 
                for (index, item) in dailyAdherence.enumerated() {
                    cell.stackViewArray[index].removeFullyAllArrangedSubviews()
                    let label = UILabel()
                    label.text = item.day ?? StringCommonMessages.notSet
                    label.textColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1) // #8E8E93
                 //   label.widthAnchor.constraint(equalToConstant: 18).isActive = true
                    label.setFont(type: .regular, point: 14)
                    let date = Date()
                    let day = date.getFormattedDate(format: "EE")
                    let lastC = day.dropLast()
                    // print(lastC)
                    if item.day?.lowercased()
                        ?? "" == lastC.lowercased() {
                        label.layer.borderWidth = 1
                        label.layer.borderColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1) // #8E8E93
                    } else {
                        label.layer.borderWidth = 0
                        label.layer.borderColor = UIColor.clear.cgColor // #8E8E93
                    }
                    cell.stackViewArray[index].axis  = NSLayoutConstraint.Axis.vertical
                    cell.stackViewArray[index].distribution  = UIStackView.Distribution.equalSpacing
                    cell.stackViewArray[index].alignment = UIStackView.Alignment.center
                    cell.stackViewArray[index].spacing   = 4
                   
                   // cell.stackViewArray[index].insertArrangedSubview(label, at: 0)
                    cell.stackViewArray[index].addArrangedSubview(label)
                    
                    for  indexSub in 1...item.denominator! {
                       // let mainview = UIView()
                        let view = UIView()
                        view.backgroundColor = (indexSub <= item.numerator ?? 0) ? #colorLiteral(red: 0.1960784314, green: 0.7725490196, blue: 1, alpha: 1) : .white
                        view.layer.borderColor =  #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
                        view.layer.borderWidth = 1
                        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
                        view.widthAnchor.constraint(equalToConstant: 16).isActive = true
                        view.layer.cornerRadius = 8
                        view.clipsToBounds = true
                        
                        let image = UIImageView()
                        image.heightAnchor.constraint(equalToConstant: 16).isActive = true
                        image.widthAnchor.constraint(equalToConstant: 16).isActive = true
                        image.image = #imageLiteral(resourceName: "cross_dot")
                        
                        if item.day?.lowercased()
                            ?? "" == lastC.lowercased() {
                            cell.stackViewArray[index].addArrangedSubview(view)
                        } else {
                            if indexSub <= item.numerator ?? 0 {
                                cell.stackViewArray[index].addArrangedSubview(view)
                            } else {
                                cell.stackViewArray[index].addArrangedSubview(image)
                            }
                        }
                    }
                    if maxvalu[0].denominator ?? 0 > item.denominator ?? 0 {
                        let valueOne = maxvalu[0].denominator ?? 0
                        let valueTwo =  item.denominator ?? 0
                        let remainItem =  valueOne - valueTwo
                        for _ in 1...remainItem {
                            let view = UIView()
                            view.backgroundColor = .clear
                            cell.stackViewArray[index].addArrangedSubview(view)
                        }
                    }
                    let array =  cell.stackViewArray[index].arrangedSubviews.reversed()
                    for (indexArr, item) in array.enumerated() {
                        cell.stackViewArray[index].insertArrangedSubview(item, at: indexArr)
                    }
                }
             }
        }
      
        return cell
    }
    
    
    @objc func tapExpand(sender: UIButton) {
        if expandFalg[sender.tag] {
            expandFalg[sender.tag] = false
        } else {
            expandFalg[sender.tag] = true
        }
        tbvDeviceData.reloadData()
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
