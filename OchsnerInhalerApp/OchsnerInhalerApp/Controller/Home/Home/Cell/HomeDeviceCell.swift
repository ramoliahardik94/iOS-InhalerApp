//
//  HomeDeviceCell.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 19/01/22.
//

import UIKit
import CoreMedia
import CoreMIDI

class HomeDeviceCell: UITableViewCell {

    @IBOutlet weak var lblDeviceName: UILabel!
   // @IBOutlet weak var lblDeviceType: UILabel!
    @IBOutlet weak var lblToday: UILabel!
    @IBOutlet weak var lblTodayData: UILabel!
    @IBOutlet weak var lblThisWeekData: UILabel!
    @IBOutlet weak var lblThisWeek: UILabel!
    @IBOutlet weak var lblThisMonthData: UILabel!
    @IBOutlet weak var lblThisMonth: UILabel!
    @IBOutlet weak var viewToday: UIView!
    @IBOutlet weak var viewAdherance: UIView!
    @IBOutlet weak var lblAdherance: UILabel!
    @IBOutlet weak var viewNextDose: UIView!
    @IBOutlet weak var lblNextDose: UILabel!
    @IBOutlet weak var ivThisWeek: UIImageView!
    @IBOutlet weak var ivThisMonth: UIImageView!
    @IBOutlet weak var mainViewExpand: UIView!
    
    @IBOutlet weak var cntMantainancePriority: NSLayoutConstraint!
    @IBOutlet weak var cntRescueProprity: NSLayoutConstraint!
    @IBOutlet weak var heightStackView: NSLayoutConstraint!
    @IBOutlet weak var ivExpand: UIImageView!
    @IBOutlet weak var btnExpand: UIButton!
    // for graph
    @IBOutlet weak var lblDeviceNameGraph: UILabel!
    @IBOutlet weak var lblDeviceTypeGraph: UILabel!
   // @IBOutlet weak var cvGraphData: UICollectionView!
    @IBOutlet weak var viewCollectionView: UIView!
    var count  = 0
    private let itemCellGraph = "GraphCell"
   
    @IBOutlet var stackViewArray: [UIStackView]!
    
    @IBOutlet weak var stackViewMain: UIStackView!
    var dailyAdherence =  [DailyAdherenceModel]()
    
    var item = MaintenanceModel() {
        didSet {
            
            lblDeviceName.attributedText = getMedictioNamewithType(type: Int(item.type ?? "1") ?? 1)
            let month = getArrowWithColor(arowDirection: item.thisMonth?.change?.lowercased() ?? "", status: item.thisMonth?.status ?? 0)
            let week = getArrowWithColor(arowDirection: item.thisWeek?.change?.lowercased() ?? "", status: item.thisWeek?.status ?? 0)
            ivThisMonth.image = month.img
            ivThisMonth.setImageColor(month.color)
            ivThisWeek.image = week.img
            ivThisWeek.setImageColor(week.color)
            
            if (item.type == "1") {
                viewCollectionView.isHidden = true
                viewNextDose.isHidden = true
                viewAdherance.isHidden = true
                viewToday.isHidden = false
                lblTodayData.text = "\(item.today?.count ?? 0)"
                lblThisWeekData.text = "\(item.thisWeek?.count ?? 0)"
                lblThisMonthData.text = "\(item.thisMonth?.count ?? 0)"
                cntRescueProprity.constant = 0
                cntRescueProprity.priority = UILayoutPriority(1000.0)
                cntMantainancePriority.priority = UILayoutPriority(250.0)
            } else {
                cntRescueProprity.priority = UILayoutPriority(250.0)
                cntMantainancePriority.priority = UILayoutPriority(1000)
                viewToday.isHidden = true
                lblThisWeekData.text = "\(item.thisWeek?.adherence ?? 0)%"
                lblThisMonthData.text = "\(item.thisMonth?.adherence ?? 0)%"
                viewAdherance.isHidden = false
                lblNextDose.text = "\(StringHome.nextScheduled) \(item.nextScheduledDose ?? StringCommonMessages.notSet)"
                viewNextDose.isHidden = false
                lblDeviceNameGraph.text = ""
                lblDeviceTypeGraph.text = StringCommonMessages.schedule
                let arrSorted = item.dailyAdherence.sorted { item1, item2 in return item1.denominator ?? 0 > item2.denominator ?? 0 }
                let maxvalu = arrSorted.count > 0 ? arrSorted[0].denominator : 0
                
                heightStackView.constant = CGFloat((maxvalu ?? 0) * (20)) + 20
                debugPrint(heightStackView.constant)
                for (index, obj) in item.dailyAdherence.enumerated() { // For Every column
                    viewCollectionView.isHidden = false
                    stackViewArray[index].removeFullyAllArrangedSubviews()
                    stackViewArray[index].isHidden = false
                    stackViewArray[index].axis  = NSLayoutConstraint.Axis.vertical
                    stackViewArray[index].distribution  = UIStackView.Distribution.equalSpacing
                    stackViewArray[index].alignment = UIStackView.Alignment.center
                    stackViewArray[index].spacing   = 4
                    stackViewArray[index].isHidden = false
                    stackViewArray[index].addArrangedSubview(getLableOfDay(text: obj.day ?? StringCommonMessages.notSet))
                   
                    layoutSubviews()
                    for  indexSub in 1...maxvalu! {
                        if indexSub <= obj.numerator ?? 0 {
                            stackViewArray[index].addArrangedSubview(getViewDoseTaken())
                        } else if maxvalu!  > obj.denominator ?? 0 {
                            let view = UIView()
                            view.backgroundColor = .clear
                            stackViewArray[index].addArrangedSubview(view)
                        } else {
                            stackViewArray[index].addArrangedSubview(getImageDoseMiss())
                        }
                    }
                    let array =  stackViewArray[index].arrangedSubviews.reversed()
                    for (indexArr, item) in array.enumerated() {
                        stackViewArray[index].insertArrangedSubview(item, at: indexArr)
                    }
                }
                
                viewCollectionView.layoutSubviews()
            }
            
            
        }
    }
    func getImageDoseMiss() -> UIImageView {
        let image = UIImageView()
        image.heightAnchor.constraint(equalToConstant: 16).isActive = true
        image.widthAnchor.constraint(equalToConstant: 16).isActive = true
        image.image = #imageLiteral(resourceName: "cross_dot")
        return image
    }
    
    func getViewDoseTaken() -> UIView {
        let view = UIView()
       // view.backgroundColor = (indexSub <= item.numerator ?? 0) ? #colorLiteral(red: 0.1960784314, green: 0.7725490196, blue: 1, alpha: 1) : .white
        view.backgroundColor =  #colorLiteral(red: 0.1960784314, green: 0.7725490196, blue: 1, alpha: 1)
        view.layer.borderColor =  #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
        view.layer.borderWidth = 1
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        view.widthAnchor.constraint(equalToConstant: 16).isActive = true
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }
    
    func getLableOfDay(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1) // #8E8E93
        label.setFont(type: .regular, point: 14)
        return label
    }
    
    func getMedictioNamewithType(type: Int) -> NSMutableAttributedString {        
        
        let firstAttributes = [NSAttributedString.Key.font: UIFont(name: AppFont.AppBoldFont, size: 24)! ]
        let sendcotAttributes = [NSAttributedString.Key.font: UIFont(name: AppFont.AppLightItalicFont, size: 16)! ]
        
        let firstString = NSMutableAttributedString(string: "\(item.medName ?? StringCommonMessages.notSet)", attributes: firstAttributes)
        let seconfString =  NSMutableAttributedString(string: "\(type == 1 ? StringAddDevice.rescueInhaler : StringAddDevice.maintenanceInhaler)", attributes: sendcotAttributes)
        firstString.append(seconfString)
        return firstString
    }
    
    func getArrowWithColor(arowDirection: String, status: Int)-> (img: UIImage, color: UIColor) {
        var color: UIColor = .ColorHomeIconRed
        var image =  UIImage(named: "arrow_down_home") ?? UIImage()
        if status == 1 {
            color = .ColorHomeIconGreen
        } else if status == 2 {
            color = .ColorHomeIconOranage
        } else {
            color = .ColorHomeIconRed
        }
        if arowDirection.lowercased()  == "up" {
            image = UIImage(named: "arrow_up_home") ?? UIImage()
        } else {
            image = UIImage(named: "arrow_down_home") ?? UIImage()
        }
        return(image, color)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        lblDeviceName.setFont(type: .bold, point: 24)
        lblTodayData.setFont(type: .semiBold, point: 28)
        lblToday.setFont(type: .light, point: 17)
        lblThisWeekData.setFont(type: .semiBold, point: 28)
        lblThisWeek.setFont(type: .light, point: 17)
        lblThisMonthData.setFont(type: .semiBold, point: 28)
        lblThisMonth.setFont(type: .light, point: 17)
        lblAdherance.setFont(type: .semiBold, point: 17)
        lblNextDose.setFont(type: .semiBold, point: 17)
        lblDeviceTypeGraph.setFont(type: .semiBold, point: 17)
        lblTodayData.textColor = .ButtonColorBlue
        lblThisMonthData.textColor = .ButtonColorBlue
        lblThisWeekData.textColor = .ButtonColorBlue
        lblToday.text = StringHome.today
        lblThisWeek.text = StringHome.thisWeek
        lblThisMonth.text = StringHome.thisMonth
        lblAdherance.text = StringHome.adherance
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    
}
