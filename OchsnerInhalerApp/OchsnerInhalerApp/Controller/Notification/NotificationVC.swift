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
    }
    override func viewWillAppear(_ animated: Bool) {
        notification.getHistory() 
        tbvData.reloadData()
    }
    
    @objc func barButtonItemTapped(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        self.navigationController?.popViewController(animated: true)
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
