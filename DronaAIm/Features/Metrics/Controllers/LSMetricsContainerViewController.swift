//
//  LSMetricsContainerViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/4/24.
//

import UIKit

class LSMetricsContainerViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    private var eventsVC: LSMetricsEventsViewController!
    private var tripDetailsVC: LSMetricsTripDetailsViewController!
    private var currentVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        setupSegmentedControl()
        setupChildViewControllers()
    }
    
    private func setupNavigationBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.logoBarButtonItem()
        let profileButton = UIBarButtonItem.profileBarButtonItem(target: self, action: #selector(showProfileVC))
        let notificationButton = UIBarButtonItem.notificationBarButtonItem(target: self, action: #selector(showNotificationsVC))
        navigationItem.rightBarButtonItems = [profileButton, notificationButton]
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
    
    private func setupChildViewControllers() {
        // Instantiate the child view controllers from the storyboard
        eventsVC = LSMetricsEventsViewController.instantiate(fromStoryboard: .driver)
        tripDetailsVC = LSMetricsTripDetailsViewController.instantiate(fromStoryboard: .driver)
    }
    
    private func displayTripDetailsVC() {
        switchToViewController(eventsVC)
    }
    
    private func displayIncedentReportVC() {
        switchToViewController(tripDetailsVC)
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
