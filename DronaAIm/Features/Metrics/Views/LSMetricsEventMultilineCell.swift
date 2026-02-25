//
//  LSMetricsEventMultilineCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/10/24.
//

import UIKit
import SwiftUI
import Combine

class LSMetricsEventMultilineCell: UITableViewCell {
    @IBOutlet weak var multiLineChartView: UIView!
    var multiLineChart: LSMultilineChartView?
    @IBOutlet weak var filterFrameContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        if let newFilterView = LSTimeFrameButtonsView.instantiate(frame: filterFrameContainer.bounds, chartType: .events) {
            newFilterView.selectCurrentMonth()
            filterFrameContainer.addSubview(newFilterView)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(groupedData: [LSMultilineChartModel]?, timeRange: TimeRange) {
        guard let groupedData = groupedData else { return }
        if multiLineChart != nil {
            multiLineChart?.viewModel.data = groupedData
            multiLineChart?.viewModel.selectedTimeRange = timeRange

        } else {
            let viewModel = LSMultilibeViewModel()
            viewModel.data = groupedData
            viewModel.selectedTimeRange = timeRange

            multiLineChart = LSMultilineChartView(viewModel: viewModel, height: 250)
            let hostingController = UIHostingController(rootView: multiLineChart)
            hostingController.view.frame = multiLineChartView.bounds
            // Add the hosting controller's view as a child of the current view controller
            multiLineChartView.addSubview(hostingController.view)
                  
                  // Set constraints for the hosting controller's view
                  hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                  NSLayoutConstraint.activate([
                    hostingController.view.topAnchor.constraint(equalTo: multiLineChartView.topAnchor, constant: 0),
                      hostingController.view.leadingAnchor.constraint(equalTo: multiLineChartView.leadingAnchor),
                      hostingController.view.trailingAnchor.constraint(equalTo: multiLineChartView.trailingAnchor),
                      hostingController.view.bottomAnchor.constraint(equalTo: multiLineChartView.bottomAnchor)

                  ])
        }

    }

}
