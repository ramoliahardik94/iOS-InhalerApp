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
        viewCell.backgroundColor = .Colorcell
        viewCell.isOchsnerView = true
        lblModicationName.font = UIFont(name: AppFont.SFProTextBold, size: 17)
        lblNDCCode.isTitle = false
        
    }
    
    func setMedicationDetailes(medication: MedicationModelElement) {
        lblNDCCode.text = "NDC Code: \(medication.ndc!)"
            lblModicationName.text = medication.medName
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
