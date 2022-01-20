//
//  HomeGraphCell.swift
//  OchsnerInhalerApp
//
//  Created by Deepak Panchal on 20/01/22.
//

import UIKit

class HomeGraphCell: UITableViewCell {
    @IBOutlet weak var svDays: UIStackView!
    @IBOutlet weak var lblMonday: UILabel!
    @IBOutlet weak var lblTuesday: UILabel!
    @IBOutlet weak var lblWednesday: UILabel!
    @IBOutlet weak var lblThursday: UILabel!
    @IBOutlet weak var lblFriday: UILabel!
    @IBOutlet weak var lblSaturday: UILabel!
    @IBOutlet weak var lblSunday: UILabel!
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblDeviceType: UILabel!
    @IBOutlet weak var cvGraphData: UICollectionView!
    @IBOutlet weak var conHeightCollectionView: NSLayoutConstraint!
    var count  = 0
    private let itemCellGraph = "GraphCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let nib = UINib(nibName: itemCellGraph, bundle: nil)
        cvGraphData.register(nib, forCellWithReuseIdentifier: itemCellGraph)
        cvGraphData.delegate = self
        cvGraphData.dataSource = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension HomeGraphCell : UICollectionViewDataSource , UICollectionViewDelegate , UICollectionViewDelegateFlowLayout  {
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
            
            }else if indexPath.row == 14 ||  indexPath.row == 16 ||  indexPath.row == 17 ||  indexPath.row == 18 {
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
            }  else {
                cell.viewMain.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.7725490196, blue: 1, alpha: 1)
            }
           
            
        }
        
        //cell.viewMain.layer.masksToBounds = true
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cvWidth = collectionView.frame.width
        return CGSize(width: cvWidth / 7, height: 26 )
    }
    
    
}
