//
//  LSNotificationDetailsViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 16/07/24.
//

import UIKit
protocol LSNotificationDetailsDelegate: AnyObject {
    func didTapuploadButton()
}

class LSNotificationDetailsViewController: UIViewController {
    weak var delegate: LSNotificationDetailsDelegate?
    private let tripDetailsView = LSNotificationDetailView()
    private let viewModel = LSNotificationDetailViewModel()
    private let notificationDetailIdsView = LSNotificationDetailsIdsView()
    var notificationModel: LSNotification!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        if notificationModel.messageType == .documentSubmissionNotification {
            drivingLicenceView()
        } else {
            newTripView()
        }

        // Do any additional setup after loading the view.
    }
    
    private func newTripView() {
        view.addSubview(tripDetailsView)
        
        tripDetailsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tripDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tripDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tripDetailsView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        viewModel.fetchTripDetails()
        tripDetailsView.configure(with: notificationModel)
    }
    
    private func drivingLicenceView() {
        notificationDetailIdsView.delegate = self
        view.addSubview(notificationDetailIdsView)
        
        notificationDetailIdsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notificationDetailIdsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            notificationDetailIdsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            notificationDetailIdsView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        notificationDetailIdsView.configure(with: notificationModel)
    }

    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: false)
    }

}
 
extension LSNotificationDetailsViewController: LSNotificationDetailsIdsDelegate {
    func didTapuploadButton() {
        self.dismiss(animated: false) {
            self.delegate?.didTapuploadButton()
        }
    }
}
