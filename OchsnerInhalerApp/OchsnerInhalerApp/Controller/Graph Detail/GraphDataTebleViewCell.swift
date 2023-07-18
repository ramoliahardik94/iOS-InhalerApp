//
//  GraphDataTebleViewCell.swift
//  OchsnerInhalerApp
//
//  Created by Hardi Patel on 09/05/23.
//

import UIKit

class GraphDataTebleViewCell: UITableViewCell {

    @IBOutlet weak var bgCardView: UIView!
    @IBOutlet weak var lblDoseName: UILabel!
    @IBOutlet weak var lblDoseDate: UILabel!
    @IBOutlet weak var lblDoseTime: UILabel!
    @IBOutlet weak var lblPuffCount: UILabel!
    @IBOutlet weak var viewDoseCircle: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
