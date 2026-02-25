//
//  LSVehiclesViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/11/24.
//

import UIKit
import Combine

struct RequestBodyForVehicleAssign: Encodable {
    let driverId: String
    let vehicleId: String
    let lonestarId: String
    let currentLoggedInUserId: String

}
class LSVehiclesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var vehicles: [LSVehicle]?
    @IBOutlet weak var assignButton: UIButton!
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignButton.isHidden = true
        tableView.register(NoDataCell.self, forCellReuseIdentifier: "cell")

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 230 // Estimate row height
        
    }
    
    func reloadTable() {
        self.vehicles = sortVehicles()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()
    }
    
    private func sortVehicles() -> [LSVehicle] {
        // Separate vehicles with and without driverID
        guard let vehicles = self.vehicles else { return [] }

        let vehiclesWithDriverID = vehicles.filter { $0.driverID != nil }
        let vehiclesWithoutDriverID = vehicles.filter { $0.driverID == nil }

        // Combine the lists: vehicles with driverID first
        return vehiclesWithoutDriverID + vehiclesWithDriverID
    }
    
     @objc func radiobuttonAction(index: Int) {
        
    }
    
    @IBAction func assignAction(_ sender: Any) {
        if let userDetails = UserDefaults.standard.userDetails {
            let vehicles = self.vehicles
            if let assignedVehicle = vehicles?.first(where: {$0.driverID == userDetails.userId}) {
                self.unAssignVehicle(assignedVehicle: assignedVehicle)
            }  else {
                self.assignVehicle()
            }
        }
    }
    
    private func assignVehicle() {
        LSProgress.show(in: self.view)
        let endpoint = LSAPIEndpoints.driverToVehicleAssign()
        guard let selectedOrganization = UserDefaults.standard.selectedOrganization, let lonestarId = selectedOrganization.lonestarId else { return }
        if let userDetails = UserDefaults.standard.userDetails, let selectedIndexPath = self.selectedIndexPath, let vehicle = self.vehicles?[selectedIndexPath.row], let vehicleId = vehicle.vehicleID {
            let requestbody = RequestBodyForVehicleAssign(driverId: userDetails.userId, vehicleId: vehicleId, lonestarId: lonestarId, currentLoggedInUserId: userDetails.userId)
            Task {
                do {
                    let response: LSVehicle = try await LSNetworkManager.shared.post(endpoint, body: requestbody)
                    LSCombineCommunicator.shared.send(.assignVehicle(.success(vehicle: response)))
                    print("Response Error: ", response)
                    LSProgress.hide(from: self.view)
                    if let details = response.message {
                        UIAlertController.showActionMessage(on: self, message: details) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                } catch {
                    UIAlertController.showError(on: self, message: String(error.localizedDescription))
                    LSProgress.hide(from: self.view)
                }
            }
        }
    }
    
    private func unAssignVehicle(assignedVehicle: LSVehicle) {
        LSProgress.show(in: self.view)
        let endpoint = LSAPIEndpoints.driverToVehicleUnAssign()
        guard let selectedOrganization = UserDefaults.standard.selectedOrganization, let lonestarId = selectedOrganization.lonestarId else { return }

        if let userDetails = UserDefaults.standard.userDetails, let vehicleId = assignedVehicle.vehicleID {
            let requestbody = RequestBodyForVehicleAssign(driverId: userDetails.userId, vehicleId: vehicleId, lonestarId: lonestarId, currentLoggedInUserId: userDetails.userId)
            Task {
                do {
                    let response: LSErrorDetails = try await LSNetworkManager.shared.post(endpoint, body: requestbody)
                    self.assignVehicle()
                    LSProgress.hide(from: self.view)
                } catch {
                }
            }
        }
    }
}
extension LSVehiclesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tripsCount = vehicles?.count ?? 0
        if tripsCount > 0 {
            return tripsCount
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tripsCount = vehicles?.count ?? 0
        if tripsCount > 0 {
            return self.tableView(tableView, tripsCellForRowAt: indexPath)
        }
        return self.tableView(tableView, noDataCellForRowAt: indexPath)

    }
    
    func tableView(_ tableView: UITableView, tripsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSVehiclesTableViewCell", for: indexPath) as? LSVehiclesTableViewCell else {
            return UITableViewCell()
        }
        let vehicle = self.vehicles?[indexPath.row]
        let isSelected = selectedIndexPath?.row == indexPath.row
        cell.delegate = self
        cell.config(with: vehicle, isSelected: isSelected, indexPath: indexPath)

        return cell
    }
    
    func tableView(_ tableView: UITableView, noDataCellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let noDataFound = UILabel.init(frame: tableView.bounds)
        noDataFound.backgroundColor = .appBackground
        noDataFound.text = "No vehicles available"
        noDataFound.textAlignment = .center
        noDataFound.textColor = .lightGray
        cell.addSubview(noDataFound)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vehicle = self.vehicles?[indexPath.row]
        if let isDriverAssigned = vehicle?.driverID {
            UIAlertController.showError(on: self, message: "Driver already assigned to this vehicle")

        } else {
            selectedIndexPath = indexPath
            self.tableView.reloadData()
            assignButton.isHidden = false
        }
    }
    
}

extension LSVehiclesViewController: LSVehiclesCellDelegate {
    func didPressRadioButton(indexPath: IndexPath) {
        selectedIndexPath = indexPath
        self.tableView.reloadData()
        assignButton.isHidden = false
    }
    
    
}
