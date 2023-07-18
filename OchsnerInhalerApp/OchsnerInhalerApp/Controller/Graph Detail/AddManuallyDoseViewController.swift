//
//  AddManuallyDoseViewController.swift
//  OchsnerInhalerApp
//
//  Created by Hardi Patel on 22/05/23.
//
import UIKit

class AddManuallyDoseViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var puffStepper: UIStepper!
    @IBOutlet weak var lblPuffCount: UILabel!
    @IBOutlet weak var lblMedName: UILabel!
    var doseDetailData = MaintenanceModel()
    var navigationTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = navigationTitle
        btnSave.layer.cornerRadius = 5
        puffStepper.autorepeat = true
        puffStepper.isContinuous = true
        puffStepper.maximumValue = 20
        puffStepper.minimumValue = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lblMedName.text = doseDetailData.medName
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let value = Int(sender.value)
        lblPuffCount.text = value.description
    }
}
