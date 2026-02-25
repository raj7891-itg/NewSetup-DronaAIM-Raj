//
//  LSDatePicker.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/21/24.
//

import UIKit

class LSDatePicker: UIView {
    @IBOutlet weak var datePicker: UIDatePicker!

    var onDateSelected: ((Date) -> Void)?
     private var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        bundle.loadNibNamed("LSDatePicker", owner: self, options: nil)
        addSubview(contentView)
        clipsToBounds = true
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.backgroundColor = .clear
        
        datePicker.datePickerMode = .date
        datePicker.layer.cornerRadius = 10
        datePicker.backgroundColor = .white
        
        // Set the preferred style for the date picker
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .inline // Use .wheels for the classic style
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        onDateSelected?(datePicker.date)
    }
    
    func configureDatePicker(mode: UIDatePicker.Mode = .date, selectedDate: Date? = nil) {
        datePicker.datePickerMode = mode
        if let date = selectedDate {
            datePicker.date = date
        }
    }
}

