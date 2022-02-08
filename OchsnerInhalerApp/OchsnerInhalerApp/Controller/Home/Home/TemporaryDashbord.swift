//
//  TemporaryDashbord.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 08/02/22.
//

import UIKit

class TemporaryDashbord: BaseVC {
    @IBOutlet weak var tbvData: UITableView!
    private let itemCell = "TemoDashboardCell"
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }
    private func initUI() {
        let nib = UINib(nibName: itemCell, bundle: nil)
        tbvData.register(nib, forCellReuseIdentifier: itemCell)
        tbvData.delegate = self
        tbvData.dataSource = self
        tbvData.separatorStyle = .none
       
    }

 

}
extension TemporaryDashbord: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCell, for: indexPath) as! TemoDashboardCell
        cell.selectionStyle = .none
      
        cell.lblName.text = "Teva(ProAir Generic)"
        cell.lblMacAddressLabel.text = "MAC Address: "
        cell.lblMacAddress.text = "12:34:56:ab:cd"
        cell.lblNDCCode.text = "NDC Code: 0093-3174-31"
        cell.lblStatus.text = StringCommonMessages.connected
       // cell.lblBattery.text = StringCommonMessages.battery
        cell.lblBatteryPercentage.text = "100%"
        
        cell.btnRemove.tag = indexPath.row
        cell.btnRemove.addTarget(self, action: #selector(tapRemove(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func tapRemove(sender: UIButton) {
        
    }
    
}
