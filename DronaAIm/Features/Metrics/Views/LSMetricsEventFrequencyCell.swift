//
//  LSMetricsEventFrequencyCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/10/24.
//

import UIKit
import SwiftUI
import Combine

class LSMetricsEventFrequencyCell: UITableViewCell {
    @IBOutlet weak var eventFrequencyChartView: UIView!
    var eventsDencityChartView: LSEventsDencityLineChartView?
    @IBOutlet weak var filterFrameContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let newFilterView = LSTimeFrameButtonsView.instantiate(frame: filterFrameContainer.bounds, chartType: .density) {
            newFilterView.selectCurrentMonth()
            filterFrameContainer.addSubview(newFilterView)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with scoreModel: LSDriverScoreModel?, timeRange: TimeRange) {
        guard let scoreModel = scoreModel else { return }
        if eventsDencityChartView != nil {
            eventsDencityChartView?.viewModel.data = scoreModel.data ?? []
            eventsDencityChartView?.viewModel.selectedTimeRange = timeRange
        } else {
            // Create a ViewModel and initialize with data
            let viewModel = LSEventsDencityViewModel()
            viewModel.data = scoreModel.data ?? []
            viewModel.selectedTimeRange = timeRange

            eventsDencityChartView = LSEventsDencityLineChartView(viewModel: viewModel, height: 250)
            let hostingController = UIHostingController(rootView: eventsDencityChartView)
            hostingController.view.frame = eventFrequencyChartView.bounds
            
            // Add the hosting controller's view as a child of the current view controller
            eventFrequencyChartView.addSubview(hostingController.view)
            
            // Set constraints for the hosting controller's view
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: eventFrequencyChartView.topAnchor, constant: 30),
                hostingController.view.bottomAnchor.constraint(equalTo: eventFrequencyChartView.bottomAnchor, constant: -40),
                hostingController.view.leadingAnchor.constraint(equalTo: eventFrequencyChartView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: eventFrequencyChartView.trailingAnchor)
            ])
        }
    }
    
    
}
