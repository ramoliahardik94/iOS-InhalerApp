//
//  NotificationVC.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 08/04/22.
//

import UIKit

class NotificationVC: UIViewController {
    
    @IBOutlet weak var tbvData: UITableView!
    let notification: NotificationVM = NotificationVM()
    let itemCell = CellIdentifier.NotificationCell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: itemCell, bundle: nil)
        tbvData.register(nib, forCellReuseIdentifier: itemCell)        
        tbvData.delegate = self
        tbvData.dataSource = self
          
           let title = StringAddDevice.titleAddDevice
        let titleSize = title.size(withAttributes: [.font: Constants.titleFont])
           let frame = CGRect(x: 0, y: 0, width: titleSize.width, height: 20.0)
           let titleLabel = UILabel(frame: frame)
           titleLabel.font = Constants.titleFont
        titleLabel.textColor =  Constants.titleColor
           titleLabel.textAlignment = .center
           titleLabel.text = title
           navigationItem.titleView = titleLabel
        
        self.navigationController?.navigationBar.topItem?.title = ""
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        notification.getHistory() 
        tbvData.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = StringAddDevice.titleAddDevice
    }

}

extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return notification.arrNotificationMsg.count
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return notification.arrMissNotification[section].historyOfMiss.count
        return notification.arrNotificationMsg.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCell, for: indexPath) as! NotificationCell
        cell.selectionStyle = .none
        cell.msg = notification.arrNotificationMsg[indexPath.row]
//        cell.date = notification.arrMissNotification[indexPath.section].history[indexPath.row]
        return cell
    }
  /*  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lable = UILabel(frame: CGRect(origin: CGPoint(x: 10, y: 0), size: CGSize(width: self.view.bounds.size.width - 20, height: 20)))
        lable.backgroundColor = .lightGray
        lable.textColor = .white
        lable.font = UIFont(name: AppFont.AppBoldFont, size: 20)
        lable.text = notification.arrMissNotification[section].historyDate
        return lable
    }*/
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
