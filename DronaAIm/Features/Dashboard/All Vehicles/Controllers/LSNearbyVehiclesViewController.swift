//
//  LSNearbyVehiclesViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/13/24.
//

import UIKit

class LSNearbyVehiclesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var vehicles: [LSVehicle]?
    var nearbyVehicles: [LSVehicle]?

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
        Task {
            self.nearbyVehicles = try await getNearbyVehicles()
            print("Nearby Vehicles =", nearbyVehicles)
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.reloadData()
        }
    }
    
    private func getNearbyVehicles() async throws -> [LSVehicle] {
        let calculator = DistanceCalculator()
        guard let vehicles = vehicles else { return [] }
        var nearbyVehicles: [LSVehicle] = []
        for vehicle in vehicles {
            if let gnssInfo = vehicle.lastLiveTrack?.gnssInfo, let latitude = gnssInfo.latitude, let longitude = gnssInfo.longitude {
                let distance = await calculator.distanceBetweenCoordinates(lat2: latitude, lon2: longitude)
                print("Distance in meters: \(distance)")
                if let distanceInMeters = distance, distanceInMeters <= 500 {
                    nearbyVehicles.append(vehicle)
                }
            }
        }
        return nearbyVehicles
    }

    @IBAction func assignAction(_ sender: Any) {
        guard let userDetails = UserDefaults.standard.userDetails else { return }
        guard let selectedOrganization = UserDefaults.standard.selectedOrganization, let lonestarId = selectedOrganization.lonestarId else { return }

        LSProgress.show(in: self.view)
        let endpoint = LSAPIEndpoints.driverToVehicleAssign()
        if let selectedIndexPath = self.selectedIndexPath, let vehicle = self.nearbyVehicles?[selectedIndexPath.row], let vehicleId = vehicle.vehicleID {
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
}

extension LSNearbyVehiclesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tripsCount = nearbyVehicles?.count ?? 0
        if tripsCount > 0 {
            return tripsCount
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tripsCount = nearbyVehicles?.count ?? 0
        if tripsCount > 0 {
            return self.tableView(tableView, tripsCellForRowAt: indexPath)
        }
        return self.tableView(tableView, noDataCellForRowAt: indexPath)

    }
    
    func tableView(_ tableView: UITableView, tripsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSVehiclesTableViewCell", for: indexPath) as? LSVehiclesTableViewCell else {
            return UITableViewCell()
        }
        let vehicle = self.nearbyVehicles?[indexPath.row]
        let isSelected = selectedIndexPath?.row == indexPath.row
        cell.delegate = self
        cell.config(with: vehicle, isSelected: isSelected, indexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, noDataCellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let noDataFound = UILabel.init(frame: tableView.bounds)
        noDataFound.backgroundColor = .appBackground
        noDataFound.text = "No nearby vehicles"
        noDataFound.textAlignment = .center
        noDataFound.textColor = .lightGray
        cell.addSubview(noDataFound)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vehicle = self.nearbyVehicles?[indexPath.row]
        if let isDriverAssigned = vehicle?.driverID {
            UIAlertController.showError(on: self, message: "Driver already assigned to this vehicle")

        } else {
            selectedIndexPath = indexPath
            self.tableView.reloadData()
            assignButton.isHidden = false
        }
    }
    
}

extension LSNearbyVehiclesViewController: LSVehiclesCellDelegate {
    func didPressRadioButton(indexPath: IndexPath) {
        selectedIndexPath = indexPath
        self.tableView.reloadData()
        assignButton.isHidden = false
    }
    
}
