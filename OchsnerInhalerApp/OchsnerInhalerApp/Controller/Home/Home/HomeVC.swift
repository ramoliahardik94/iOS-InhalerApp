//
//  HomeVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit
import DropDown

class HomeVC: BaseVC {

    
    @IBOutlet weak var tbvDeviceData: UITableView!
 
    private let itemCellDevice = "HomeDeviceCell"
    private let itemCellGraph = "HomeGraphCell"
    
    private var homeVM = HomeVM()
    
    var expandFalg = [true, true]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        initUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = StringAddDevice.titleAddDevice
        self.navigationController?.navigationBar.topItem?.rightBarButtonItems =  [UIBarButtonItem(image: UIImage(named: "notifications_white"), style: .plain, target: self, action: #selector(tapNotification))]
        
        
        doGetHomeData()
    }
    @objc func tapNotification() {
        
    }
    private func  initUI() {
        let nib = UINib(nibName: itemCellDevice, bundle: nil)
        tbvDeviceData.register(nib, forCellReuseIdentifier: itemCellDevice)
        tbvDeviceData.delegate = self
        tbvDeviceData.dataSource = self
        tbvDeviceData.separatorStyle = .none
        // doGetHomeData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
            //  print("")
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.topItem?.rightBarButtonItems?.remove(at: 0)
        }
    }
    
    
    private func doGetHomeData() {
        homeVM.doDashboardData {  isSuccess in
            switch isSuccess {
            case .success(let status):
                print("Response sucess :\(status)")
                // print("Response sucess :\(self.homeVM.dashboardData.count)")
                DispatchQueue.main.async {
                    self.tbvDeviceData.reloadData()
                }
            case .failure(let message):
                CommonFunctions.showMessage(message: message)
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
        cell.lblDeviceName.text = item.medName ?? ""
       
        
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
        
        if item.type == "1" {
            // for rescue
            cell.viewCollectionView.isHidden = true
            cell.viewNextDose.isHidden = true
            cell.viewAdherance.isHidden = true
            cell.lblDeviceType.text = "(Rescue Inhaler)"
            cell.viewToday.isHidden = false
            cell.lblTodayData.text = "\(item.today?.count ?? 0)"
            cell.lblThisWeekData.text = "\(item.thisWeek?.count ?? 0)"
            cell.lblThisMonthData.text = "\(item.thisMonth?.count ?? 0)"
        } else {
            // maintaince
            cell.lblDeviceType.text = "(Maintenance Inhaler)"
            cell.viewToday.isHidden = true
            cell.lblThisWeekData.text = "\(item.thisWeek?.adherence ?? 0)%"
            cell.lblThisMonthData.text = "\(item.thisMonth?.adherence ?? 0)%"
           
            cell.viewAdherance.isHidden = false
            if let nextDose = item.nextScheduledDose {
                cell.lblNextDose.text = nextDose
                cell.viewNextDose.isHidden = false
            } else {
                cell.viewNextDose.isHidden = true
            }
            cell.lblDeviceNameGraph.text = item.medName ?? ""
            cell.lblDeviceTypeGraph.text = "(Schedule)"
            if item.dailyAdherence.count != 0 {
            //    cell.dailyAdherence = item.dailyAdherence
                let  dailyAdherence = item.dailyAdherence.reversed()
                for (index, item) in dailyAdherence.enumerated() {
                    cell.lblArray[index].text = item.day ?? "NA"
                   
                    for  _ in 1...item.denominator! {
                        let view = UIView()
                        view.backgroundColor = .BlueText
                        view.heightAnchor.constraint(equalToConstant: 18).isActive = true
                        view.widthAnchor.constraint(equalToConstant: 18).isActive = true
                       // view.centerXAnchor
                        //    .constraint(equalTo: cell.lblArray[index].centerXAnchor).isActive = true
                      //  view.layer.cornerRadius = cell.lblArray[index].frame.size.width / 2
                        view.clipsToBounds = true
                     //   stackViewArray[index].
                        cell.stackViewArray[index].addArrangedSubview(view)
                    }
                  //  cell.stackViewArray[0].centerXAnchor
//                    let view = UIView()
//                    view.backgroundColor = .BlueText
//                    view.heightAnchor.constraint(equalToConstant: 30).isActive = true
//                   // view.widthAnchor.constraint(equalToConstant: 4).isActive = true
//                    cell.stackViewArray[index].addArrangedSubview(view)
             
                    
                }
             }
        }
      
      
        /*if
        } else {
          
             
           
           
            
            setCustomFontLabel(label: cell.lblDeviceName, type: .bold, fontSize: 17)
            setCustomFontLabel(label: cell.lblDeviceType, type: .regular, fontSize: 13)
            setCustomFontLabel(label: cell.lblMonday, type: .regular, fontSize: 16)
            setCustomFontLabel(label: cell.lblTuesday, type: .regular, fontSize: 16)
            setCustomFontLabel(label: cell.lblWednesday, type: .regular, fontSize: 16)
            setCustomFontLabel(label: cell.lblThursday, type: .regular, fontSize: 16)
            setCustomFontLabel(label: cell.lblFriday, type: .regular, fontSize: 16)
            setCustomFontLabel(label: cell.lblSaturday, type: .regular, fontSize: 16)
            setCustomFontLabel(label: cell.lblSunday, type: .regular, fontSize: 16)
            cell.lblMonday.textColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1) // #8E8E93
            cell.lblTuesday.textColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1) // #8E8E93
            cell.lblWednesday.textColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1) // #8E8E93
            cell.lblThursday.textColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1) // #8E8E93
            cell.lblFriday.textColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1) // #8E8E93
            cell.lblSaturday.textColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1) // #8E8E93
            cell.lblSunday.textColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1) // #8E8E93
            cell.lblMonday.text = "M"
            cell.lblTuesday.text = "T"
            cell.lblWednesday.text = "W"
            cell.lblThursday.text = "T"
            cell.lblFriday.text = "F"
            cell.lblSaturday.text = "S"
            cell.lblSunday.text = "S"
            
            cell.lblFriday.layer.borderWidth = 1
            cell.lblFriday.layer.borderColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1) // #8E8E93
           cell.svDays.isHidden = false
            cell.count = 14
            cell.conHeightCollectionView.constant = 56
            cell.viewCollectionView.isHidden = false
        }*/
        
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
