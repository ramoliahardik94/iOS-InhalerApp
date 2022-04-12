//
//  NotificationCell.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 11/04/22.
//

import UIKit

class NotificationCell: UITableViewCell {
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    @IBOutlet weak var lblDoseDetails: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var date = NotificationModel() {
        didSet {
            lblDate.text = date.historyDate
            let attributedString = NSMutableAttributedString()
            for obj in date.history {
                attributedString
                 .bold(obj.medName)
                 .normal(" \(obj.mac) \n")
                for dose in obj.dose {
                  attributedString
                    .bold(dose.time)
                    .normal(": \( dose.status == "N" ? "Missed" : "Taken") \(dose.takenPuffCount) Puff \n")
                }
            }
            lblDoseDetails.numberOfLines = 0
            lblDoseDetails.attributedText = attributedString
        }
    }
}
