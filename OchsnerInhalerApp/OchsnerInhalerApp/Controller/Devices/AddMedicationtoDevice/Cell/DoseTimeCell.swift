//
//  DoseTimeCell.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 19/01/22.
//

import UIKit

class DoseTimeCell: UITableViewCell {

    @IBOutlet weak var DosetimeView: UIView!
    @IBOutlet weak var lblDoseTime: UILabel!
    @IBOutlet weak var btnRemove: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DosetimeView.layer.cornerRadius = 6
        DosetimeView.backgroundColor = .Color_DoseTime
        DosetimeView.layer.borderColor = UIColor.TextField_Border_Color.cgColor
        DosetimeView.layer.borderWidth = 1
        DosetimeView.clipsToBounds = true
        lblDoseTime.font = UIFont(name: AppFont.AppRegularFont, size: 17)
        
        btnRemove.layer.cornerRadius = 6
        btnRemove.backgroundColor = .RedBG
        btnRemove.layer.borderColor = UIColor.TextField_Border_Color.cgColor
        btnRemove.layer.borderWidth = 1
        btnRemove.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
