//
//  NMDatePicker.swift
//  OchsnerInhalerApp
//
//  Created by Nikita Bhatt on 19/01/22.
//

import Foundation
import UIKit

class NMDatePicker: UIView {
    var changeClosure: (Date) -> Void = {_ in }
    var dismissClosure: (Date) -> Void = {_ in }
   // var changeClosure: ((Date) -> ())?
   // var dismissClosure: ((Date)-> ())?

    var selectedDate = Date()
    let dPicker: UIDatePicker = {
        let obj = UIDatePicker()
        return obj
    }()
    var mode: UIDatePicker.Mode?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit() {
        let blurEffect = UIBlurEffect(style: .dark)
        
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        
        let pickerHolderView: UIView = {
            let obj = UIView()
            obj.backgroundColor = .white
            obj.layer.cornerRadius = 8
            return obj
        }()
        
        [blurredEffectView, pickerHolderView, dPicker].forEach { obj in
            obj.translatesAutoresizingMaskIntoConstraints = false
        }

        addSubview(blurredEffectView)
        pickerHolderView.addSubview(dPicker)
        addSubview(pickerHolderView)
        
        NSLayoutConstraint.activate([
            
            blurredEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurredEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurredEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurredEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

            pickerHolderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
            pickerHolderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),
            pickerHolderView.centerYAnchor.constraint(equalTo: centerYAnchor),

            dPicker.topAnchor.constraint(equalTo: pickerHolderView.topAnchor, constant: 20.0),
            dPicker.leadingAnchor.constraint(equalTo: pickerHolderView.leadingAnchor, constant: 20.0),
            dPicker.trailingAnchor.constraint(equalTo: pickerHolderView.trailingAnchor, constant: -20.0),
            dPicker.bottomAnchor.constraint(equalTo: pickerHolderView.bottomAnchor, constant: -20.0)])
       
        if #available(iOS 14.0, *) {
            dPicker.preferredDatePickerStyle = .wheels
        } else {
            // use default
        }
        dPicker.datePickerMode  = .time
        dPicker.addTarget(self, action: #selector(didChangeDate(_:)), for: .valueChanged)
        
        let obj = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        blurredEffectView.addGestureRecognizer(obj)
    }
    
    @objc func tapHandler(_ obj: UITapGestureRecognizer) {
        dismissClosure(selectedDate)
    }
    
    @objc func didChangeDate(_ sender: UIDatePicker) {
        selectedDate = sender.date
        changeClosure(sender.date)
    }
    
    
}
