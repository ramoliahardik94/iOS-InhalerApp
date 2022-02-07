//
//  HomeVC.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 12/01/22.
//

import UIKit

class HomeVC: BaseVC {

    
    @IBOutlet weak var tbvDeviceData: UITableView!
    @IBOutlet weak var tbvGraphData: UITableView!
    private let itemCellDevice = "HomeDeviceCell"
    private let itemCellGraph = "HomeGraphCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initUI()
    }
    
    private func  initUI() {
        let nib = UINib(nibName: itemCellDevice, bundle: nil)
        tbvDeviceData.register(nib, forCellReuseIdentifier: itemCellDevice)
        tbvDeviceData.delegate = self
        tbvDeviceData.dataSource = self
        tbvDeviceData.separatorStyle = .none
        
        let nibGraph = UINib(nibName: itemCellGraph, bundle: nil)
        tbvGraphData.register(nibGraph, forCellReuseIdentifier: itemCellGraph)
        tbvGraphData.delegate = self
        tbvGraphData.dataSource = self
        tbvGraphData.separatorStyle = .none
     
    }


}
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tbvGraphData {
            let cell = tableView.dequeueReusableCell(withIdentifier: itemCellGraph, for: indexPath) as! HomeGraphCell
            cell.selectionStyle = .none
       
            
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
           
            if indexPath.row == 0 {
                cell.lblDeviceName.text = "Ventolin"
                cell.lblDeviceType.text = "(Rescue)"
                cell.svDays.isHidden = true
                cell.count = 21
                cell.conHeightCollectionView.constant = 80
            } else {
                cell.lblDeviceName.text = "Teva"
                cell.lblDeviceType.text = "(Schedule)"
                cell.svDays.isHidden = false
                cell.count = 14
                cell.conHeightCollectionView.constant = 56
            }
            
            return cell
        }
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCellDevice, for: indexPath) as! HomeDeviceCell
        
        
        cell.selectionStyle = .none
        setCustomFontLabel(label: cell.lblDeviceName, type: .bold, fontSize: 24)
        setCustomFontLabel(label: cell.lblDeviceType, type: .lightItalic, fontSize: 16)
        setCustomFontLabel(label: cell.lblConnected, type: .regular, fontSize: 14)
        setCustomFontLabel(label: cell.lblBattery, type: .regular, fontSize: 14)
        setCustomFontLabel(label: cell.lblBatteryPercentage, type: .semiBold, fontSize: 14)
        setCustomFontLabel(label: cell.lblTodayData, type: .semiBold, fontSize: 28)
        setCustomFontLabel(label: cell.lblToday, type: .light, fontSize: 17)
        setCustomFontLabel(label: cell.lblThisWeekData, type: .semiBold, fontSize: 28)
        setCustomFontLabel(label: cell.lblThisWeek, type: .light, fontSize: 17)
        setCustomFontLabel(label: cell.lblThisMonthData, type: .semiBold, fontSize: 28)
        setCustomFontLabel(label: cell.lblThisMonth, type: .light, fontSize: 17)
        setCustomFontLabel(label: cell.lblAdherance, type: .semiBold, fontSize: 17)
        setCustomFontLabel(label: cell.lblNextDose, type: .semiBold, fontSize: 17)
        cell.lblTodayData.textColor = .ButtonColorBlue
        cell.lblThisMonthData.textColor = .ButtonColorBlue
        cell.lblThisWeekData.textColor = .ButtonColorBlue
        
        cell.lblConnected.text = StringCommonMessages.connected
        cell.lblBattery.text = StringCommonMessages.battery
        
        cell.lblToday.text = StringHome.today
        cell.lblThisWeek.text = StringHome.thisWeek
        cell.lblThisMonth.text = StringHome.thisMonth
        cell.lblAdherance.text = StringHome.adherance
        if indexPath.row == 0 {
            cell.lblDeviceName.text = "Teva"
            cell.lblDeviceType.text = "(Rescue Inhaler)"
            cell.lblBatteryPercentage.text = "87%"
            cell.viewToday.isHidden = false
            cell.lblTodayData.text = "2"
            cell.lblThisWeekData.text = "11"
            cell.lblThisMonthData.text = "26"
            cell.viewNextDose.isHidden = true
            cell.viewAdherance.isHidden = true
            cell.ivBattery.image = UIImage(named: "battery")
            cell.ivThisWeek.image = UIImage(named: "arrow_up_home")
            cell.ivThisWeek.setImageColor(.ColorHomeIconOranage)// #FFA52F
            cell.ivThisMonth.image = UIImage(named: "arrow_up_home")
            cell.ivThisMonth.setImageColor(.ColorHomeIconRed)// #FFA52F
            
        } else {
            cell.lblDeviceName.text = "Ventolin"
            cell.lblDeviceType.text = "(Maintenance Inhaler)"
            cell.lblBatteryPercentage.text = "32%"
            cell.viewToday.isHidden = true
            cell.lblThisWeekData.text = "88%"
            cell.lblThisMonthData.text = "76%"
            cell.viewNextDose.isHidden = false
            cell.viewAdherance.isHidden = false
            cell.lblNextDose.text = "Next Scheduled Dose: Today at 6:30 pm"
            cell.ivBattery.image = UIImage(named: "battery_orange")
            cell.ivThisWeek.image = UIImage(named: "arrow_up_home")
            cell.ivThisWeek.setImageColor(.ColorHomeIconGreen)// #FFA52F
            cell.ivThisMonth.image = UIImage(named: "arrow_down_home")
            cell.ivThisMonth.setImageColor(.ColorHomeIconRed)// #FFA52F
         
        }
        
        return cell
    }
    
    
}
