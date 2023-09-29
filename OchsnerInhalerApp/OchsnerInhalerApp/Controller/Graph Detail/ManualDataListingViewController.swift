//
//  ManualDataListingViewController.swift
//  OchsnerInhalerApp
//
//  Created by Hardi Patel on 03/07/23.
//

import UIKit

class ManualDataListingViewController: UIViewController {

    var arrGraphDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var selectedDay: Int = 0
    var doseDetailData = MaintenanceModel()
    var currentDate = ""
    var arrPuffTime = [String]()
    var arrPuffCount = [String]()
    var totalPuffTime = [Any]()
    var totalPuffCount = [String]()
    
    @IBOutlet weak var graphDetailTV: UITableView!
    @IBOutlet weak var btnAddDose: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAddDose.layer.cornerRadius = 5
        print(doseDetailData.today?.doseDetail.count ?? 0 )
        for doseData in doseDetailData.today?.doseDetail ?? [] {
            print("datetime", doseData.datetime)
            let date =  doseData.datetime?.components(separatedBy: "T")
            let time = date?[1].description.components(separatedBy: "+")
            currentDate = date?[0] ?? ""
            let time24 = timeFormatter(time: time?[0] ?? "12:00")
            arrPuffTime.append(time24)
            print("total puff", arrPuffTime)
        }
        let countedSet = NSCountedSet(array: arrPuffTime)
        for value in countedSet {
            print("Element:", value, "count:", countedSet.count(for: value))
            totalPuffTime.append(value)
            totalPuffCount.append("\(countedSet.count(for: value))")
        }
        
        print("total Puff --", totalPuffTime)
        print("total count --", totalPuffCount)
    }

    
    func timeFormatter(time: String) -> String {
        let dateAsString = time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let hourDate = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "h:mm a"
        let date12 = dateFormatter.string(from: hourDate!)
        return date12
    }
    
    @IBAction func addDoseAction(_ sender: UIButton) {
        
        let addManuallyDoseVC = AddManuallyDoseViewController.instantiateFromAppStoryboard(appStoryboard: .graphDetail)
        addManuallyDoseVC.navigationTitle = "Add Dose"
       // pushVC(controller: addManuallyDoseVC)
    }
}

extension ManualDataListingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrGraphDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GraphDetailCollectionViewCell
        
        cell.lblGraphDays.text = arrGraphDays[indexPath.row]
        cell.graphBgView.setBorder(1, color: .lightGray, radius: 9)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDay = indexPath.row
        if let cell = collectionView.cellForItem(at: indexPath) as? GraphDetailCollectionViewCell {
            cell.graphBgView.backgroundColor = UIColor(named: "graphDaysSelection")
            cell.graphBgView.setBorder(1, color: .white, radius: 9)
            cell.lblGraphDays.textColor = UIColor.white
        }
        graphDetailTV.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? GraphDetailCollectionViewCell {
            cell.graphBgView.backgroundColor = UIColor.white
            cell.graphBgView.setBorder(1, color: .lightGray, radius: 9)
            cell.lblGraphDays.textColor = UIColor.black
        }
    }
}

extension ManualDataListingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalPuffTime.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GraphData") as! GraphDataTebleViewCell
        let date =  doseDetailData.today?.doseDetail[indexPath.row].datetime?.components(separatedBy: "T")
        let time = date?[1].description.components(separatedBy: "+")
        let time24 = timeFormatter(time: time?[0] ?? "12:00")
        
//        if arrPuffTime.contains(time24) == false {
//            arrPuffTime.append(time24)
//        } else {
//            print("Already Exist!!!")
//        }
        
        cell.lblDoseTime.text = totalPuffTime[indexPath.row] as? String
        cell.lblDoseDate.text = currentDate
        cell.lblDoseName.text = doseDetailData.medName
        cell.lblPuffCount.text = totalPuffCount[indexPath.row] + " " + "Puff"
        cell.bgCardView.setBorder(0, color: .lightGray, radius: 9)
        cell.bgCardView.layer.shadowColor = UIColor.lightGray.cgColor
        cell.bgCardView.layer.shadowOpacity = 1
        cell.bgCardView.layer.shadowOffset = .zero
        cell.bgCardView.layer.shadowRadius = 3
        cell.viewDoseCircle.setCornerRadius(10.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let addManuallyDoseVC = AddManuallyDoseViewController.instantiateFromAppStoryboard(appStoryboard: .graphDetail)
        addManuallyDoseVC.navigationTitle = "Update Dose"
       // pushVC(controller: addManuallyDoseVC)
    }
}