//
//  NotificationVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 08/04/22.
//

import UIKit

class NotificationVC: BaseVC {
    
    @IBOutlet weak var tbvData: UITableView!
    let notification: NotificationVM = NotificationVM()
    @IBOutlet weak var lblNoNotificationFound: UILabel!
    let itemCell = CellIdentifier.NotificationCell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: itemCell, bundle: nil)
        tbvData.register(nib, forCellReuseIdentifier: itemCell)
        tbvData.delegate = self
        tbvData.dataSource = self
        self.setSwipeBack(false)
        let title = StringAddDevice.titleAddDevice
        let titleSize = title.size(withAttributes: [.font: Constants.titleFont])
        let frame = CGRect(x: 0, y: 0, width: titleSize.width, height: 20.0)
        let titleLabel = UILabel(frame: frame)
        titleLabel.font = Constants.titleFont
        titleLabel.textColor =  Constants.titleColor
        titleLabel.textAlignment = .center
        titleLabel.text = title
        navigationItem.titleView = titleLabel
        let backImg: UIImage = UIImage(imageLiteralResourceName: "ic_back_arrow_white")
        let newBackButton = UIBarButtonItem(image: backImg, style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonItemTapped(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        self.navigationController?.navigationBar.topItem?.title = StringAddDevice.titleAddDevice
        // Do any additional setup after loading the view.
        
        let notif = UIBarButtonItem(image: UIImage(systemName: "list.number"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(tapData(sender:)))
        
        let allData = UIBarButtonItem(image: UIImage(systemName: "keyboard"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(tapAllData(sender:)))
        
        self.navigationItem.rightBarButtonItems = [notif, allData]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        notification.getHistory() 
        tbvData.reloadData()
        if notification.arrNotificationMsg.count == 0 {
            tbvData.isHidden = true
            lblNoNotificationFound.text = StringLocalNotifiaction.noNotification
        } else {
            tbvData.isHidden = false
            lblNoNotificationFound.text = ""
        }
    }
    
    @objc func barButtonItemTapped(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapAllData(sender: UIBarButtonItem) {
        var msg = ""
        var deviceList: [String: String] = [:]
        
        let devices = DatabaseManager.share.getAddedDeviceList(email: UserDefaultManager.email)
        let actlogs = DatabaseManager.share.getAllActuationLog()
        let dict = Dictionary(grouping: actlogs, by: { $0.deviceidmac })
        dict.forEach { key, val in
            if let mac = key,
               let name = deviceList[mac] {
                msg += (msg.isEmpty ? "" : "\n\n ") + name
                
                msg += "\n" + ((val.map({ $0.usedatelocal }) as? [String])?.joined(separator: "\n") ?? "")
            }
        }
        
        let alert = UIAlertController(title: "All Data", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func tapData(sender: UIBarButtonItem) {
        let timeZone = Date().getString(format: "Z", isUTC: false)
        let timeInterVal = TimeInterval((30*60)) // #30 miniutes
        
        var msg = ""
        notification.arrMissNotification.forEach { notification in
            let dateHistory = notification.historyDate.getDate(format: DateFormate.notificationFormate).getString(format: DateFormate.useDateLocalyyyyMMddDash)
            
            msg += (msg.isEmpty ? "" : "\n") + notification.historyDate
            notification.history.forEach { history in
                history.dose.forEach { dose in
                    let time = dose.time.getDate(format: DateFormate.doseTime).getString(format: "HH:mm:ss")
                    let maxDate = (dateHistory + "T" + time + timeZone).getDate(format: DateFormate.useDateLocalAPI).addingTimeInterval(timeInterVal).getString(format: DateFormate.useDateLocalAPI)
                    
                    msg += "\n\n Dose: " + history.medName + " Status: " + dose.status + " Time: " + maxDate + "\n"
                    let arr = dose.acuation.map({ $0.usedatelocal }) as? [String]
                    msg += "Puffs: " + (arr?.joined(separator: "\n") ?? "No Puff")
                }
            }
        }
        
        let alert = UIAlertController(title: "All Notification", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension NotificationVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notification.arrNotificationMsg.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCell, for: indexPath) as! NotificationCell
        cell.selectionStyle = .none
        cell.msg = notification.arrNotificationMsg[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
