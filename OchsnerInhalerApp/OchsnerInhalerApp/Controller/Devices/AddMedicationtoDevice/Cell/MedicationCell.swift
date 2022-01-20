//
//  MedicationCell.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 18/01/22.
//

import UIKit

class MedicationCell: UITableViewCell {

    @IBOutlet weak var lblNDCCode: UILabel!
    @IBOutlet weak var lblModicationName: UILabel!
    @IBOutlet weak var btnMedication: UIButton!
    @IBOutlet weak var viewCell: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewCell.backgroundColor = .Color_cell
        viewCell.isOchsnerView = true
        lblNDCCode.font = UIFont(name: AppFont.SFProText_Bold, size: 17)
        lblModicationName.isTitle = false
        
    }
    
    func setMedicationDetailes(index : Int){
        switch index {
        case 0:
            lblNDCCode.text = "NCD Code: 59310-579-22"
            lblModicationName.text = "ProAir"
        case 1:
            lblNDCCode.text = "NDC Code: 0093-3174-31"
            lblModicationName.text = "Teva (ProAir Generic) "
        case 2:
            lblNDCCode.text = "NCD Code: 0173-0682-20"
            lblModicationName.text = "Ventolin"
        default:
            lblNDCCode.text = "NDC Code: 66993-019-68"
            lblModicationName.text = "Prasco (Ventolin Generic)"
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
