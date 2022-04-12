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

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        notification.getHistory() 
        tbvData.reloadData()
    }
    

}

extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notification.arrNotification.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCell, for: indexPath) as! NotificationCell
        cell.selectionStyle = .none
        cell.date = notification.arrNotification[indexPath.row]
       
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
