//
//  DoseTimeCell.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 19/01/22.
//

import UIKit

class DoseTimeCell: UITableViewCell {

    @IBOutlet weak var dosetimeView: UIView!
    @IBOutlet weak var lblDoseTime: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var btnEditDose: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dosetimeView.layer.cornerRadius = 6
        dosetimeView.backgroundColor = .ColorDoseTime
        dosetimeView.isOchsnerView = true
        dosetimeView.clipsToBounds = true
        lblDoseTime.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        
        btnRemove.layer.cornerRadius = 6
        btnRemove.backgroundColor = .RedBG
        btnRemove.isOchsnerView = true
        btnRemove.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
