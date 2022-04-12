//
//  NotificationCell.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 11/04/22.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDoseDetails: UILabel!
    @IBOutlet weak var viewCard: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblDoseDetails.numberOfLines = 0
        var boldNotiFont: UIFont { return UIFont(name: AppFont.AppBoldFont, size: 15) ?? UIFont.boldSystemFont(ofSize: 15) }
        var normalNotiFont: UIFont { return UIFont(name: AppFont.AppRegularFont, size: 16) ?? UIFont.systemFont(ofSize: 16)}
        
        lblTime.textColor = UIColor.notiBold
        lblTime.font = boldNotiFont
        
        lblDoseDetails.textColor = UIColor.notiNormal
        lblDoseDetails.font = normalNotiFont
        
//        self.viewCard.setBorder(1, color: .black, radius: 16)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    var msg = MsgModel() {
        didSet {
            lblDoseDetails.text = msg.msg
            lblTime.text = msg.time
        }
    }
    var date = NotificationModel() {
        didSet {
//            lblDate.text = date.historyDate
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
