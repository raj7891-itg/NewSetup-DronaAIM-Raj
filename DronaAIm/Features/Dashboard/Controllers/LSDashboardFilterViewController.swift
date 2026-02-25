//
//  LSDashboardFilterViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/5/24.
//

import UIKit
import Combine

class LSDashboardFilterViewController: UIViewController {
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!

    private var fromAction: Bool = true
    private var datePickerVC: LSDatePickerViewController?
    
    var fromDate: Date?
    var toDate: Date?    
    var cancellable: AnyCancellable?
    deinit {
        cancellable?.cancel()
    }
    var onDateSelected: ((Int, Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initiLizeDatePickerView()
        subscribeToCombine()
    }
        
    private func initiLizeDatePickerView() {
        datePickerVC = LSDatePickerViewController.instantiate(fromStoryboard: .driver)
        if let datePickerVC = datePickerVC {
            datePickerVC.view.frame = self.view.bounds
        }
    }
    
    private func subscribeToCombine() {
           cancellable = LSCombineCommunicator.shared.publisher
               .sink { actionType in
                   switch actionType {
                   case .datePicker(let datePickerAction):
                       switch datePickerAction {
                       case .done(let date):
                           print("ReceiverClass2: Starting download")
                           self.updateDateOnFilter(date: date)
                           self.hideDatePicker()
                       }
                   default:
                       // ReceiverClass2 doesn't handle other action types
                       break
                   }
               }
       }
    
    private func updateDateOnFilter(date: Date) {
        if fromAction {
            fromDate = date
            fromDateLabel.text = LSDateFormatter.shared.convertDateToMMMMddYYYY(from: date)
        } else {
            toDate = date
            toDateLabel.text = LSDateFormatter.shared.convertDateToMMMMddYYYY(from: date)
        }
    }
    
    private func showDatePicker() {
        if let datePickerVC = datePickerVC {
            datePickerVC.view.frame = self.view.bounds
            self.view.addSubview(datePickerVC.view)
        }
    }
    
    private func hideDatePicker() {
        if let datePickerVC = datePickerVC {
            datePickerVC.view.removeFromSuperview()
        }
    }
    
    @IBAction func fromDateAction(_ sender: Any) {
        fromAction = true
        if let fromD = fromDate {
            datePickerVC?.updateSelectedDate(date: fromD)
        }
        showDatePicker()
    }
    
    @IBAction func toDateAction(_ sender: Any) {
        fromAction = false
        if let toD = toDate {
            datePickerVC?.updateSelectedDate(date: toD)
        }
        showDatePicker()

    }
    
    @IBAction func closeFilterAction(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func searchAction(_ sender: Any) {
        var postParameters = [String: String]()
        if let fromDate = fromDate,  let toDate = toDate {
            let sTs = LSDateFormatter.shared.convertDateToTimeStamp(for: fromDate)
            postParameters["fromDate"] = sTs
            
            let eTs = LSDateFormatter.shared.convertDateToTimeStamp(for: toDate)
            postParameters["toDate"] = eTs
            
            let startTs = LSDateFormatter.shared.convertDateToInt(for: fromDate)
            let endTs = LSDateFormatter.shared.convertDateToInt(for: toDate)

            onDateSelected?(startTs, endTs) // Call the completion handler
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func clearFilterAction(_ sender: Any) {
        fromDate = nil
        fromDateLabel.text = "From"

        toDate = nil
        toDateLabel.text = "To"

        self.dismiss(animated: true)
    }
    
}
