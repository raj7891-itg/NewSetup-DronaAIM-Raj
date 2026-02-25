//
//  LSVehiclesContainerViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/13/24.
//

import UIKit

class LSVehiclesContainerViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    private var eventsVC: LSVehiclesViewController!
    private var tripDetailsVC: LSNearbyVehiclesViewController!
    private var currentVC: UIViewController?
    var vehicles: [LSVehicle]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Vehicle"
        setupSegmentedControl()
        setupChildViewControllers()
        fetchVehicles()
    }
    
    private func setupSegmentedControl() {
        // Set selected title color
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        segmentControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        // Set normal title color
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black
        ]
        segmentControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
    }
    
    private func fetchVehicles() {
        guard let userDetails = UserDefaults.standard.userDetails else { return }
        guard let selectedOrganization = UserDefaults.standard.selectedOrganization, let lonestarId = selectedOrganization.lonestarId else { return }

            LSProgress.show(in: self.view)
        let endpoint = LSAPIEndpoints.vehiclesByTenentId(for: lonestarId)
            Task {
                do {
                    let response: LSAllVehiclesModel = try await LSNetworkManager.shared.post(endpoint, body: LSRequstEmpty(empty: ""), parameters: ["page": "1", "limit":  "100"])
                    self.vehicles = response.vehicles
                    self.eventsVC.vehicles = self.vehicles
                    self.tripDetailsVC.vehicles = self.vehicles
                    self.displayTripDetailsVC()
                    LSProgress.hide(from: self.view)
                } catch {
                    UIAlertController.showError(on: self, message: String(error.localizedDescription))
                    LSProgress.hide(from: self.view)
                }
            }
    }
    
    private func setupChildViewControllers() {
        // Instantiate the child view controllers from the storyboard
        eventsVC = LSVehiclesViewController.instantiate(fromStoryboard: .driver)
        tripDetailsVC = LSNearbyVehiclesViewController.instantiate(fromStoryboard: .driver)
    }
    
    private func displayTripDetailsVC() {
        switchToViewController(eventsVC)
        self.eventsVC.vehicles = self.vehicles
        self.eventsVC.reloadTable()
    }
    
    private func displayIncedentReportVC() {
        switchToViewController(tripDetailsVC)
        self.tripDetailsVC.vehicles = self.vehicles
        self.tripDetailsVC.reloadTable()
    }
        
    private func switchToViewController(_ toVC: UIViewController) {
        // Remove current view controller if any
        if let currentVC = currentVC {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        // Add the new view controller
        addChild(toVC)
        toVC.view.frame = containerView.bounds
        containerView.addSubview(toVC.view)
        toVC.didMove(toParent: self)
        
        currentVC = toVC
    }

    @IBAction func segmentAction(_ sender: UISegmentedControl) {
       if sender.selectedSegmentIndex == 0 {
            displayTripDetailsVC()
       } else if sender.selectedSegmentIndex == 1 {
           displayIncedentReportVC()
       }
    }

}
