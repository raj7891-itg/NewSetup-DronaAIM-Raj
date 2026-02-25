//
//  LSDashboardViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/2/24.
//

import UIKit
import Combine

enum DashboardApi {
    case fetchScore
    case fetchVehicles
    case all
}

class LSDDashboardViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var filterVC: LSDashboardFilterViewController?

    var scoreModel: LSDriverScoreModel?
    var cancellable: AnyCancellable?
    var assignedVehicle: LSVehicle?
    var timeRange: TimeRange = .week
    
    deinit {
        cancellable?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = "Dashboard"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 230 // Estimate row height
        setupNavigationBarItems()
        initializeFilterVC()
        subscribeToCombine()
        apiCall(type: .fetchVehicles, parms: nil)
    }
    
    private func setupNavigationBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.logoBarButtonItem()
        let profileButton = UIBarButtonItem.profileBarButtonItem(target: self, action: #selector(showProfileVC))
        let notificationButton = UIBarButtonItem.notificationBarButtonItem(target: self, action: #selector(showNotificationsVC))
        navigationItem.rightBarButtonItems = [profileButton, notificationButton]
    }
    
    private func initializeFilterVC() {
         filterVC = LSDashboardFilterViewController.instantiate(fromStoryboard: .driver)
    }
    
    private func presentFilterVC() {
        if let sheet = filterVC?.sheetPresentationController {
            sheet.detents = [.medium()] // .medium() will present half the screen
            sheet.prefersGrabberVisible = true // Optional: Show a grabber at the top of the sheet
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
        if let filterVC = self.filterVC {
            self.present(filterVC, animated: true, completion: nil)
        }
    }
    
    private func apiCall(type: DashboardApi, parms: [String: String]?) {
        Task {
            do {
                if type == .all {
                    try await self.fetchVehicles()
                    if let parms = parms {
                        try await self.fetchDriverScore()
                    }
                } else if type == .fetchVehicles {
                    try await self.fetchVehicles()
                } else if type == .fetchScore, let parms = parms {
                    try await self.fetchDriverScore()
                }
            } catch {
                let errorMessage = error.localizedDescription
                if errorMessage.count > 0 {
                    UIAlertController.showError(on: self, message: errorMessage)
                }
                LSProgress.hide(from: self.view)
            }
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.reloadData()
        }
    }
    
//    private func fetchDriverScore(parms: [String: String]) async throws {
//        guard let userDetails = UserDefaults.standard.userDetails else { return }
//        guard let selectedOrganization = UserDefaults.standard.selectedOrganization, let lonestarId = selectedOrganization.lonestarId else { return }
//        LSProgress.show(in: self.view)
//        let endpoint = LSAPIEndpoints.driverScoreData(for: lonestarId,driverId: userDetails.userId)
//            do {
//                let driverScoreModel: LSDriverScoreModel = try await LSNetworkManager.shared.get(endpoint, parameters: parms, apiType: .analytics)
//                self.scoreModel = driverScoreModel
//            } catch let error {
//                print(error.localizedDescription)
//            }
//            LSProgress.hide(from: self.view)
//    }
    
    private func fetchDriverScore() async throws {
        guard let userDetails = UserDefaults.standard.userDetails else { return }
        guard let selectedOrganization = UserDefaults.standard.selectedOrganization,
              let lonestarId = selectedOrganization.lonestarId else { return }

        LSProgress.show(in: self.view)

        let endpoint = LSAPIEndpoints.driverScoreData()

        let params: [String: String] = [
            "userId": userDetails.userId,
            "lonestarId": lonestarId,
            "fromDate": "1767205800000",
            "toDate": "1769884199999"
        ]

        do {
            let driverScoreModel: LSDriverScoreModel =
                try await LSNetworkManager.shared.get(endpoint,
                                                      parameters: params,
                                                      apiType: .analytics)

            self.scoreModel = driverScoreModel
        } catch {
            print(error.localizedDescription)
        }

        LSProgress.hide(from: self.view)
    }
    
    
    
    
    
    @objc func refreshList() {
        apiCall(type: .fetchVehicles, parms: nil)
    }
    
    private func fetchVehicles() async throws {
        guard let userDetails = UserDefaults.standard.userDetails else { return }
        guard let selectedOrganization = UserDefaults.standard.selectedOrganization, let lonestarId = selectedOrganization.lonestarId else { return }

            LSProgress.show(in: self.view)
            let endpoint = LSAPIEndpoints.vehiclesByTenentId(for: lonestarId)
            let response: LSAllVehiclesModel = try await LSNetworkManager.shared.post(endpoint, body: LSRequstEmpty(empty: ""), parameters: ["page": "1", "limit":  "100"])
            let vehicles = response.vehicles
            let vehicle = vehicles?.first(where: {$0.driverID == userDetails.userId})
            self.assignedVehicle = vehicle
            self.tableView.reloadData()
            LSProgress.hide(from: self.view)
        
    }
    
    func subscribeToCombine() {
           cancellable = LSCombineCommunicator.shared.publisher
               .sink { actionType in
                   switch actionType {
                   case .chartFilterAction(let chartFilterAction):
                       switch chartFilterAction {
                       case .startAndEndDates(let start, let end, let timeRange, let _):
                        let parms = ["fromDate": String(start), "toDate": String(end)]
                        self.timeRange = timeRange
                       self.apiCall(type: .fetchScore, parms: parms)
                       }
                
                   case .assignVehicle(let assignAction):
                       switch assignAction {
                       case .success(let vehicle):
                           self.assignedVehicle = vehicle
                           self.tableView.reloadData()
                       }
                   case .updateProfileImage(let url):
//                       if let url = url {
//                           self.navigationItem.rightBarButtonItems?.first?.updateProfileImage(with: url)
//                       }
                           print("")
                   default:
                       // ReceiverClass2 doesn't handle other action types
                       break
                   }
               }
       }
    
    @objc func selectVehicle() {
        let vehiclesVC = LSVehiclesContainerViewController.instantiate(fromStoryboard: .driver)
        self.navigationController?.pushViewController(vehiclesVC, animated: true)
    }
    
    @objc func unAssignVehicle() {
        guard let userDetails = UserDefaults.standard.userDetails else { return }
        guard let selectedOrganization = UserDefaults.standard.selectedOrganization, let lonestarId = selectedOrganization.lonestarId else { return }
        LSProgress.show(in: self.view)

        let endpoint = LSAPIEndpoints.driverToVehicleUnAssign()
        if let vehicleId = assignedVehicle?.vehicleID {
            let requestbody = RequestBodyForVehicleAssign(driverId: userDetails.userId, vehicleId: vehicleId, lonestarId: lonestarId, currentLoggedInUserId: userDetails.userId)
            Task {
                do {
                    let response: LSErrorDetails = try await LSNetworkManager.shared.post(endpoint, body: requestbody)
                    if let details = response.message {
                        UIAlertController.showError(on: self, message: details)
                    } else if let details = response.details {
                        UIAlertController.showError(on: self, message: details)
                    }
                    assignedVehicle = nil
                    self.tableView.reloadData()
                    print("Response Error: ", response)
                    LSProgress.hide(from: self.view)
                } catch {
                    UIAlertController.showError(on: self, message: String(error.localizedDescription))
                    LSProgress.hide(from: self.view)
                }
            }
        }
    }

}

extension LSDDashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let assignedVehicle = assignedVehicle {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LSVehicleUnassignTableViewCell", for: indexPath) as! LSVehicleUnassignTableViewCell
                cell.config(with: assignedVehicle)
                cell.changeVehicleButton.addTarget(self, action: #selector(selectVehicle), for: .touchUpInside)
                cell.unassignVehicleButton.addTarget(self, action: #selector(unAssignVehicle), for: .touchUpInside)
                return cell

            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LSVehicleAssignTableViewCell", for: indexPath) as! LSVehicleAssignTableViewCell
                cell.selectVehicle.addTarget(self, action: #selector(selectVehicle), for: .touchUpInside)
                return cell
            }

        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSDDashboarDriverScoreCell", for: indexPath) as! LSDDashboarDriverScoreCell
            if let scoreModel = scoreModel {
                cell.configure(with: scoreModel)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSLineChartTableViewCell", for: indexPath) as! LSLineChartTableViewCell
            if let scoreModel = scoreModel {
                cell.configure(with: scoreModel, timeRange: self.timeRange)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            return 300
        } else if indexPath.row == 2 {
            return 420
        }
        return UITableView.automaticDimension
    }
        
}

