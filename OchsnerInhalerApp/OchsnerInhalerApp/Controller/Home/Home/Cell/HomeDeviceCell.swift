//
//  HomeDeviceCell.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 19/01/22.
//

import UIKit

class HomeDeviceCell: UITableViewCell {

    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblDeviceType: UILabel!
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
    
    @IBOutlet weak var ivExpand: UIImageView!
    @IBOutlet weak var btnExpand: UIButton!
    // for graph
    @IBOutlet weak var lblDeviceNameGraph: UILabel!
    @IBOutlet weak var lblDeviceTypeGraph: UILabel!
  //  @IBOutlet weak var cvGraphData: UICollectionView!
  //  @IBOutlet weak var conHeightCollectionView: NSLayoutConstraint!
    
    @IBOutlet weak var viewCollectionView: UIView!
    var count  = 0
    private let itemCellGraph = "GraphCell"
   
    @IBOutlet var stackViewArray: [UIStackView]!
    
    var dailyAdherence =  [DailyAdherenceModel]()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblDeviceName.setFont(type: .bold, point: 24)
        lblDeviceType.setFont(type: .lightItalic, point: 16)
        lblTodayData.setFont(type: .semiBold, point: 28)
        lblToday.setFont(type: .light, point: 17)
        lblThisWeekData.setFont(type: .semiBold, point: 28)
        lblThisWeek.setFont(type: .light, point: 17)
        lblThisMonthData.setFont(type: .semiBold, point: 28)
        lblThisMonth.setFont(type: .light, point: 17)
        lblAdherance.setFont(type: .semiBold, point: 17)
        lblNextDose.setFont(type: .semiBold, point: 17)
        lblDeviceTypeGraph.setFont(type: .semiBold, point: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension HomeDeviceCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellGraph, for: indexPath) as! GraphCell
        
          
        if count >= 21 {
            
            cell.viewMain.layer.cornerRadius =  8
           
            
            cell.viewMain.layer.borderWidth = 1
          
            if indexPath.row == 2 {
                cell.viewMain.backgroundColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2470588235, alpha: 1)
                cell.viewMain.layer.borderColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            } else if indexPath.row == 9 ||  indexPath.row == 11 {
                cell.viewMain.backgroundColor = #colorLiteral(red: 1, green: 0.6431372549, blue: 0.4039215686, alpha: 1)
                cell.viewMain.layer.borderColor =  #colorLiteral(red: 0.3254901961, green: 0.3254901961, blue: 0.3254901961, alpha: 1)
            
            } else if indexPath.row == 14 ||  indexPath.row == 16 ||  indexPath.row == 17 ||  indexPath.row == 18 {
                cell.viewMain.backgroundColor = #colorLiteral(red: 1, green: 0.9764705882, blue: 0.4, alpha: 1)
                cell.viewMain.layer.borderColor =   #colorLiteral(red: 0.4235294118, green: 0.4235294118, blue: 0.4235294118, alpha: 1)
            } else {
                cell.viewMain.backgroundColor = UIColor.clear
                cell.viewMain.layer.borderColor = UIColor.clear.cgColor
            }
            
        } else {
            cell.viewMain.layer.cornerRadius =  8
           
            cell.viewMain.layer.borderColor =  #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 1)
            cell.viewMain.layer.borderWidth = 1
          
            if indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6 || indexPath.row == 12 || indexPath.row == 13 {
                cell.viewMain.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                cell.viewMain.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.7725490196, blue: 1, alpha: 1)
            }
           
            
        }
        
        // cell.viewMain.layer.masksToBounds = true
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cvWidth = collectionView.frame.width
        return CGSize(width: cvWidth / 7, height: 26 )
    }
    
    
}
