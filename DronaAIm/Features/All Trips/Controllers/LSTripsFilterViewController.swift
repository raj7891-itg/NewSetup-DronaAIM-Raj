//
//  LSTripsFilterViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/27/24.
//

import UIKit

protocol LSTripsFilterDelegate: AnyObject {
    func didtapOnSearch(requestModel: LSRequstTrips)
    func didtapOnClearFilter()

}

class LSTripsFilterViewController: UIViewController {
    weak var filterDelegate: LSTripsFilterDelegate?

    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    
    @IBOutlet var datepickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!

    @IBOutlet weak var eventTypeStackView: UIStackView!
    private var fromAction: Bool = true

    var fromDate: Date?
    var toDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func fromDateAction(_ sender: Any) {
        fromAction = true
        setupDatePicker()
        if let fromD = fromDate {
            datePicker.date = fromD
        }
    }
    
    @IBAction func toDateAction(_ sender: Any) {
        fromAction = false
        setupDatePicker()
        if let toD = toDate {
            datePicker.date = toD
        }

    }
    
    @IBAction func datePickerDoneAction(_ sender: Any) {
        datepickerView.removeFromSuperview()
    }
    
    @IBAction func closeFilterAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func searchAction(_ sender: Any) {
        var selectedIncidents = [String]()
        eventTypeStackView.subviews.forEach { stack in
            stack.subviews.forEach { button in
                if let button = button as? UIButton, button.isSelected, let title = button.titleLabel?.text {
                    if title == "Completed" {
                        selectedIncidents.append("Completed")
                    }
                    if title == "In progress" {
                        selectedIncidents.append("Started")
                    }
                    if title == "Truncated" {
                        selectedIncidents.append("Orphaned")
                    }
                }
            }
        }
        var requestModel = LSRequstTrips()
        requestModel.tripStatus = selectedIncidents

        if let fromDate = fromDate,  let toDate = toDate {
            let sTs = LSDateFormatter.shared.convertDateToTimeStamp(for: fromDate)
            requestModel.fromDate = sTs
            
            let eTs = LSDateFormatter.shared.convertDateToTimeStamp(for: toDate)
            requestModel.toDate = eTs
        }
        
        print("postParameters =", requestModel)
        self.filterDelegate?.didtapOnSearch(requestModel: requestModel)
        self.dismiss(animated: true)

    }
    
    @IBAction func statusAction(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
        sender.setImage(UIImage(systemName: "square"), for: .normal)
        sender.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
    }

    @IBAction func clearFilterAction(_ sender: Any) {
        eventTypeStackView.subviews.forEach { stack in
            stack.subviews.forEach { button in
                if let button = button as? UIButton {
                    button.isSelected = false
                }
            }
        }
        
        fromDate = nil
        fromDateLabel.text = "From"

        toDate = nil
        toDateLabel.text = "To"

        self.filterDelegate?.didtapOnClearFilter()
        self.dismiss(animated: true)
    }
    
    private func setupDatePicker() {
        // Set the date picker's mode
        datePicker.datePickerMode = .date
        datePicker.layer.cornerRadius = 10
        
        // Set the preferred style for the date picker
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .inline // .wheels for the classic style
        }
        datePicker.backgroundColor = .white
        // Add an action to handle the date selection
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        datepickerView.frame = self.view.bounds
        datepickerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(datepickerView)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let selectedDate = dateFormatter.string(from: sender.date)
        if fromAction {
            fromDate = sender.date
            fromDateLabel.text = LSDateFormatter.shared.convertDateToMMMMddYYYY(from: sender.date)
        } else {
            toDate = sender.date
            toDateLabel.text = LSDateFormatter.shared.convertDateToMMMMddYYYY(from: sender.date)
        }
        
        print("Selected date: \(selectedDate)")
    }


  
}
