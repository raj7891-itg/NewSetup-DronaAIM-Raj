//
//  LSTripDetailsContainerViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 24/06/24.
//

import UIKit

class LSTripDetailsContainerViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    private var tripDetailsVC: LSTripDetailsViewController!
    private var incidentReportVC: LSIncidentReportViewController!
    private var currentVC: UIViewController?
    var trip: LSDTrip?
    var events = [LSDAllEvents]()

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var safetyScoreLabel: UILabel!
    @IBOutlet weak var tripIdLabel: UILabel!

    @IBOutlet weak var tripScoreView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Trip Details"
        setupSegmentedControl()
        setupChildViewControllers()
        DispatchQueue.main.async {
            self.displayTripDetailsVC()
            self.tripIdLabel.text = self.trip?.tripID
        }
        fetchEventsForTrip()
        var scoreColor = UIColor.appRed
        if let tripScore = trip?.tripScore {
            if tripScore >= 90 {
                scoreColor = UIColor.appGreen
            } else if tripScore >= 80 && tripScore <= 89 {
                scoreColor = UIColor.appYellow
            }
        }
        safetyScoreLabel.textColor = scoreColor
        tripScoreView.backgroundColor = scoreColor.withAlphaComponent(0.1)
        tripScoreView.layer.borderColor = scoreColor.cgColor

        if let score = trip?.tripScore {
            let tripScore = (LSCalculation.shared.doubleFormat(score: score))
            safetyScoreLabel.text = "Trip Score \(tripScore)"
        } else {
            safetyScoreLabel.text = "Trip Score NA"
            safetyScoreLabel.textColor = UIColor.lightGray
            tripScoreView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
            tripScoreView.layer.borderColor = UIColor.lightGray.cgColor
        }
                
        if trip?.tripStatus == "Started" {
            statusIcon.image = UIImage(named: "progress")
            statusLabel.text = "In Progress"
        } else {
            statusIcon.image = UIImage(named: "completed")
            statusLabel.text = "Completed"
        }

        // Do any additional setup after loading the view.
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
    
    private func fetchEventsForTrip() {
        Task {
            do {
                if let tripID = trip?.tripID {
                    LSProgress.show(in: self.view)
                    let endpoint = LSAPIEndpoints.eventsBytripId(for: tripID)
                    let response: LSDAllEventsModel = try await LSNetworkManager.shared.get(endpoint, parameters: ["page": "1", "limit": "2000"])
                    DispatchQueue.main.async {
                        if let allEvents = response.allEvents {
                            self.events = allEvents
                            self.tripDetailsVC.events = self.events
                            self.incidentReportVC.events = self.events
                            self.tripDetailsVC.reloadTable()
                            LSProgress.hide(from: self.view)
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    LSProgress.hide(from: self.view)
                    UIAlertController.showError(on: self, message: String(error.localizedDescription))
                }
            }
        }
    }
    
    private func setupChildViewControllers() {
        // Instantiate the child view controllers from the storyboard
        tripDetailsVC = LSTripDetailsViewController.instantiate(fromStoryboard: .main)
        tripDetailsVC.trip = trip
        tripDetailsVC.events = self.events
        incidentReportVC = LSIncidentReportViewController.instantiate(fromStoryboard: .main)
        incidentReportVC.tripid = trip?.tripID
    }
    
    private func displayTripDetailsVC() {
        switchToViewController(tripDetailsVC)
        self.tripDetailsVC.events = self.events
        self.tripDetailsVC.reloadTable()
    }
    
    private func displayIncedentReportVC() {
        switchToViewController(incidentReportVC)
        self.incidentReportVC.events = self.events
        self.incidentReportVC.reloadTable()
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
