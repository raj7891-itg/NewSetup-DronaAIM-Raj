//
//  LSMetricsViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/30/24.
//

import UIKit
import Combine

enum EventsApiType {
    case eventsPie
    case eventsLine
    case eventsDencity
    case all
}

class LSMetricsEventsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var incidents: LSMetricsEventsModel?
    var allIncidents: LSMetricsEventsModel?
    
    var eventsResponse: LSDAllEventsModel?
    var scoreModel: LSDriverScoreModel?

    var cancellable: AnyCancellable?
    var timeRange: TimeRange = .week
    var dencityTimeRange: TimeRange = .week
    
    deinit {
        cancellable?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 230 // Estimate row height
        subscribeToCombine()
        apiCall(parms: ["page": "1", "limit": "2000"], chartType: .events)
    }
    
    private func apiCall(parms: [String: String], chartType: LSChartType) {
        LSProgress.show(in: self.view)
        guard let selectedOrganization = UserDefaults.standard.selectedOrganization, let lonestarId = selectedOrganization.lonestarId else { return }

        var parameters = parms
        parameters["lonestarId"] = lonestarId
        
        Task {
            do {
                if chartType == .density {
                    try await fetchEventsDencity(parms: parameters)
                } else {
                    try await fetchEventsMetaData(parms: parameters)
                }
                self.tableView.dataSource = self
                self.tableView.delegate = self
                self.tableView.reloadData()
                LSProgress.hide(from: self.view)
            } catch {
                UIAlertController.showError(on: self, message: String(error.localizedDescription))
                LSProgress.hide(from: self.view)
            }
        }
    }
    
    private func fetchEventsMetaData(parms: [String: String]) async throws {
        if let userDetails = UserDefaults.standard.userDetails {
            let driverId = userDetails.userId
            let endpoint = LSAPIEndpoints.eventsMetadataByDriverId(for: driverId)
            
            let response: LSMetricsEventsModel = try await LSNetworkManager.shared.get(endpoint, parameters: parms)
                self.allIncidents = response
                self.incidents = response
        }
    }
    
    private func fetchEventsDencity(parms: [String: String]) async throws {
        guard let userDetails = UserDefaults.standard.userDetails else { return }
        guard let selectedOrganization = UserDefaults.standard.selectedOrganization, let lonestarId = selectedOrganization.lonestarId else { return }

        let endpoint = LSAPIEndpoints.driverScoreData()
            let driverScoreModel: LSDriverScoreModel = try await LSNetworkManager.shared.get(endpoint, parameters: parms, apiType: .analytics)
            self.scoreModel = driverScoreModel
    }
    
    func subscribeToCombine() {
           cancellable = LSCombineCommunicator.shared.publisher
               .sink { actionType in
                   switch actionType {
                       case .chartFilterAction(let chartFilterAction):
                       switch chartFilterAction {
                       case .startAndEndDates(let start, let end, let timeRange, let chartType):
                           var parms = ["startTS": String(start), "endTS": String(end)]
                           if chartType == .density {
                               self.dencityTimeRange = timeRange
                            parms = ["fromDate": String(start), "toDate": String(end)]
                           } else {
                               self.timeRange = timeRange
                           }
                           self.apiCall(parms: parms, chartType: chartType)
                       }
                   default:
                       // ReceiverClass2 doesn't handle other action types
                       break
                   }
               }
       }
   
}

extension LSMetricsEventsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return self.tableView(tableView, pieChartCellForRowAt: indexPath)
        } else if indexPath.row == 1 {
            return self.tableView(tableView, MultilineChartCellForRowAt: indexPath)
        }
        return self.tableView(tableView, frequencyChartCellForRowAt: indexPath)

    }
    
    func tableView(_ tableView: UITableView, pieChartCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSMetricsEventPieCell", for: indexPath) as? LSMetricsEventPieCell else {
            return UITableViewCell()
        }
        let groupedEvents = self.allIncidents?.groupEventsForPieChart()
        cell.configure(groupedIncidents: groupedEvents)
        return cell
    }
    
    func tableView(_ tableView: UITableView, MultilineChartCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSMetricsEventMultilineCell", for: indexPath) as? LSMetricsEventMultilineCell else {
            return UITableViewCell()
        }
         let groupedEvents = self.incidents?.groupedMultilineChartModels()
        cell.configure(groupedData: groupedEvents, timeRange: self.timeRange)
        return cell
    }
    
    func tableView(_ tableView: UITableView, frequencyChartCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSMetricsEventFrequencyCell", for: indexPath) as? LSMetricsEventFrequencyCell else {
            return UITableViewCell()
        }
        cell.configure(with: scoreModel, timeRange: dencityTimeRange)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            let groupedEvents = self.allIncidents?.groupEventsForPieChart()
            return groupedEvents?.count ?? 0 > 0 ? 400 : 0
        }
        else if indexPath.row == 1 {
            let groupedEvents = self.incidents?.groupedMultilineChartModels()
            return groupedEvents?.count ?? 0 > 0 ? 700 : 300
        }
        return 350
    }
}
