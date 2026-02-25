//
//  LSLineChartTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 21/06/24.
//

import UIKit
import SwiftUI
import Combine

class LSLineChartTableViewCell: UITableViewCell {

    @IBOutlet weak var chartView: UIView!
        
    @IBOutlet weak var filterFrameContainer: UIView!
    static let identifier = "LSLineChartTableViewCell"
    var driverScoreLineChart: LSDashboardDriverScoreLineChartView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if let newFilterView = LSTimeFrameButtonsView.instantiate(frame: filterFrameContainer.bounds, chartType: .driverScore) {
            newFilterView.selectCurrentMonth()
            filterFrameContainer.addSubview(newFilterView)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(with scoreModel: LSDriverScoreModel, timeRange: TimeRange) {
        
        if driverScoreLineChart != nil {
            driverScoreLineChart?.viewModel.data = scoreModel.data ?? []
            driverScoreLineChart?.viewModel.selectedTimeRange = timeRange

        } else {
            // Create a ViewModel and initialize with data
            let viewModel = DriverScoreViewModel()
            viewModel.data = scoreModel.data ?? []
            viewModel.selectedTimeRange = timeRange

            driverScoreLineChart = LSDashboardDriverScoreLineChartView(viewModel: viewModel, height: 250)
            let hostingController = UIHostingController(rootView: driverScoreLineChart)
            hostingController.view.frame = chartView.bounds
            
            // Add the hosting controller's view as a child of the current view controller
            chartView.addSubview(hostingController.view)
            
            // Set constraints for the hosting controller's view
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: chartView.topAnchor, constant: 30),
                hostingController.view.bottomAnchor.constraint(equalTo: chartView.bottomAnchor, constant: -40),
                hostingController.view.leadingAnchor.constraint(equalTo: chartView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: chartView.trailingAnchor)
            ])
        }
    }


}
