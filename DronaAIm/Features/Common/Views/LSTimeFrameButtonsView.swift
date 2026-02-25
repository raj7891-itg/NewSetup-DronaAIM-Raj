//
//  LSTimeFrameButtonsView.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 12/02/25.
//

import UIKit

enum LSChartType: String {
    case driverScore = "driverScore", events = "events", density = "density"
}

class LSTimeFrameButtonsView: UIView {
    
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var yearBtn: UIButton!
    @IBOutlet weak var customBtn: UIButton!
    private var selectedYear: Int? = nil
    private var filterVC: LSDashboardFilterViewController?
    var chartType: LSChartType!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // 🔹 Static function to return the view
    static func instantiate(frame: CGRect, chartType: LSChartType) -> LSTimeFrameButtonsView? {
        guard let view = Bundle(for: LSTimeFrameButtonsView.self)
            .loadNibNamed(String(describing: LSTimeFrameButtonsView.self), owner: nil, options: nil)?
            .first as? LSTimeFrameButtonsView else {
            return nil
        }
        
        view.chartType = chartType  // ✅ Assign chart type
        view.frame = frame
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return view
    }

     func selectCurrentMonth() {
       filterVC = LSDashboardFilterViewController.instantiate(fromStoryboard: .driver)

        let calendar = Calendar.current
        let currentMonthIndex = calendar.component(.month, from: Date()) // Month index (1 to 12)
        let shortMonthSymbols = calendar.shortMonthSymbols[currentMonthIndex - 1]
        if self.monthBtn != nil {
            self.updatetitle(for: self.monthBtn, title: shortMonthSymbols)
            self.selectButton(selectButton: self.monthBtn)
            if let (startDate, endDate) = self.getMonthTimestamp(month: currentMonthIndex, year: self.selectedYear) {
                LSCombineCommunicator.shared.send(.chartFilterAction(.startAndEndDates(start: startDate, end: endDate, timeRange: .month(month: currentMonthIndex), chartType: self.chartType)))
            }
        }

    }
    
    @IBAction func weekAction(_ sender: Any) {
        self.selectButton(selectButton: self.weekBtn)
        if let (startDate, endDate) = self.getLast7DaysTimestamp() {
            print("StartDate: \(startDate), endDate: \(endDate)")
            LSCombineCommunicator.shared.send(.chartFilterAction(.startAndEndDates(start: startDate, end: endDate, timeRange: .week, chartType: self.chartType)))
        }
    }
   
    @IBAction func monthAction(_ sender: UIButton) {
        let months = Calendar.current.shortMonthSymbols.enumerated().map { ($0.element, $0.offset + 1) }

        let dropdown = DropdownMenu(
            items: months.map { $0.0 }, // Pass only month names to dropdown
            anchorButton: sender,
            filterType: .month
        ) { selectedMonth in
            if let monthIndex = months.first(where: { $0.0 == selectedMonth })?.1 {
                print("Selected Month: \(selectedMonth), Index: \(monthIndex)")
                self.updatetitle(for: sender, title: selectedMonth)
                if self.selectedYear != nil {
                    self.selectMonthAndYear()
                } else {
                    self.selectButton(selectButton: self.monthBtn)
                }
                if let (startDate, endDate) = self.getMonthTimestamp(month: monthIndex, year: self.selectedYear) {
                    print("StartDate: \(startDate), endDate: \(endDate)")
                    LSCombineCommunicator.shared.send(.chartFilterAction(.startAndEndDates(start: startDate, end: endDate, timeRange: .month(month: monthIndex), chartType: self.chartType)))
                }
            }
        }

        dropdown.show()
    }
    
    @IBAction func yearAction(_ sender: UIButton) {
        let currentYear = Calendar.current.component(.year, from: Date())
        var years = (currentYear-10...currentYear).map { String($0) } // Years from 10 years ago to current year
        years = Array(years).reversed()
        
        let dropdown = DropdownMenu(
            items: years,
            anchorButton: sender,
            filterType: .month
        ) { selectedYear in
            print("Selected Item: \(selectedYear)")
            self.selectedYear = Int(selectedYear)
            self.updatetitle(for: sender, title: selectedYear)
            self.selectButton(selectButton: self.yearBtn)
            if let (startDate, endDate) = self.getYearTimestamp(year: self.selectedYear ?? 0) {
                print("StartDate: \(startDate), endDate: \(endDate)")
                LSCombineCommunicator.shared.send(.chartFilterAction(.startAndEndDates(start: startDate, end: endDate, timeRange: .year(year: self.selectedYear ?? 0), chartType: self.chartType)))
            }
        }

        dropdown.show()
    }
    
    @IBAction func customAction(_ sender: UIButton) {
        presentFilterVC()
    }
    
    private func presentFilterVC() {
        if let sheet = filterVC?.sheetPresentationController {
            sheet.detents = [.medium()] // .medium() will present half the screen
            sheet.prefersGrabberVisible = true // Optional: Show a grabber at the top of the sheet
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
        if let filterVC = self.filterVC, let topController = UIApplication.shared.topViewController() {
            topController.present(filterVC, animated: true, completion: nil)
            filterVC.onDateSelected = { startDate, endDate in
                let start = LSDateFormatter.shared.convertTimestampDate(from: Double(startDate), format: .UsStandardDate)
                let end = LSDateFormatter.shared.convertTimestampDate(from: Double(endDate), format: .UsStandardDate)

                  print("Selected Start Date: \(startDate), End Date: \(endDate)")
                LSCombineCommunicator.shared.send(.chartFilterAction(.startAndEndDates(start: Int64(startDate), end: Int64(endDate), timeRange: .custom(start: start ?? Date(), end: end ?? Date()), chartType: self.chartType)))
                self.selectButton(selectButton: self.customBtn)

              }
        }
    }
    
    private func updatetitle(for button: UIButton, title: String) {
        // Create an attributed string with the desired font size
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12) // Adjust the font size here
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        // Set the attributed title to the button
        button.setAttributedTitle(attributedTitle, for: .normal)
    }

    private func selectButton(selectButton: UIButton) {
        let buttons = [weekBtn, monthBtn, yearBtn, customBtn]
        buttons.forEach { button in
            if (button == selectButton) {
                button?.isSelected = true
                button?.backgroundColor = .appTheme
                button?.tintColor = .white

            } else {
                button?.isSelected = false
                button?.backgroundColor = .white
                button?.tintColor = .black
            }
        }
    }
    
    private func selectMonthAndYear() {
        let buttons = [weekBtn, monthBtn, yearBtn, customBtn]
        buttons.forEach { button in
            if (button == monthBtn  || button == yearBtn) {
                button?.isSelected = true
                button?.backgroundColor = .appTheme
                button?.tintColor = .white

            } else {
                button?.isSelected = false
                button?.backgroundColor = .white
                button?.tintColor = .black
            }
        }
    }
    
    
    private func getMonthTimestamp(month: Int, year: Int?) -> (start: Int64, end: Int64)? {
        
        // Create a date for the first day of the selected month and year
        var components = DateComponents()
        let currentYear = Calendar.current.component(.year, from: Date())

        if year != nil {
            components.year = year
        } else {
            components.year = currentYear
        }
        components.month = month  // Calendar months are 1-indexed
        components.day = 1

        let calendar = Calendar.current
        
        guard let startDate = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startDate) else {
            return nil
        }
        
        // Get the end date of the month
        components.day = range.count
        guard let endDate = calendar.date(from: components) else {
            return nil
        }
        
        // Convert start and end dates to milliseconds since 1970
        let startMilliseconds = Int64(startDate.timeIntervalSince1970 * 1000)
        let endMilliseconds = Int64(endDate.timeIntervalSince1970 * 1000)
        
        return (startMilliseconds, endMilliseconds)
    }

    func getYearTimestamp(year: Int) -> (start: Int64, end: Int64)? {
        let calendar = Calendar.current
        var components = DateComponents()
        
        // Get the start date of the selected year
        components.year = year
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        guard let startDate = calendar.date(from: components) else {
            return nil
        }
        
        // Get the end date of the selected year
        components.month = 12
        components.day = 31
        guard let endDate = calendar.date(from: components)?.addingTimeInterval(86399) else {
            return nil
        }
        
        // Convert start and end dates to milliseconds since 1970
        let startMilliseconds = Int64(startDate.timeIntervalSince1970 * 1000)
        let endMilliseconds = Int64(endDate.timeIntervalSince1970 * 1000)
        
        return (startMilliseconds, endMilliseconds)
    }
    
    func getLast7DaysTimestamp() -> (start: Int64, end: Int64)? {
        let calendar = Calendar.current
        let now = Date()
        
        // Get the start date of the last 7 days
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: now) else {
            return nil
        }
        
        // Get the end date of the last 7 days (the current date)
        let endDate = now
        
        // Convert start and end dates to milliseconds since 1970
        let startMilliseconds = Int64(startDate.timeIntervalSince1970 * 1000)
        let endMilliseconds = Int64(endDate.timeIntervalSince1970 * 1000)
        
        return (startMilliseconds, endMilliseconds)
    }
    

    
    
}
