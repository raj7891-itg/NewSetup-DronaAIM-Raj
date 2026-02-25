//
//  LSDatePickerViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/5/24.
//

import UIKit

class LSDatePickerViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    var selectedDate = Date.now
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()
        // Do any additional setup after loading the view.
    }
    
    private func setupDatePicker() {
        // Set the date picker's mode
        datePicker.datePickerMode = .date
        datePicker.layer.cornerRadius = 10
        datePicker.date = selectedDate
        // Set the preferred style for the date picker
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .inline // .wheels for the classic style
        }
        datePicker.backgroundColor = .white
        // Add an action to handle the date selection
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    func updateSelectedDate(date: Date) {
        self.selectedDate = date
        datePicker.date = selectedDate
    }
    
    @IBAction func doneAction(_ sender: Any) {
        LSCombineCommunicator.shared.send(.datePicker(.done(date: selectedDate)))
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        print("Selected date: \(selectedDate)")
    }

}
