//
//  LSMetricsEventPieCellTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/4/24.
//

import UIKit
import SwiftUI

class LSMetricsEventPieCell: UITableViewCell {

    @IBOutlet weak var pieChartView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(groupedIncidents: [LSPieChartModel]?) {
        guard let groupedIncidents = groupedIncidents else { return }

            let sortedData = groupedIncidents.sorted(by: { $0.title <  $1.title })
            
            let driverScorePieChart = LSMetricsPieChartView(data: sortedData, height: 300)
            let hostingController = UIHostingController(rootView: driverScorePieChart)
            hostingController.view.frame = pieChartView.bounds
            // Add the hosting controller's view as a child of the current view controller
            pieChartView.addSubview(hostingController.view)
            
            // Set constraints for the hosting controller's view
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: pieChartView.topAnchor, constant: 10),
                hostingController.view.bottomAnchor.constraint(equalTo: pieChartView.bottomAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: pieChartView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: pieChartView.trailingAnchor, constant: 5)
            ])
    }

}
