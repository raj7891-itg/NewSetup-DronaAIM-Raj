//
//  LSNotificationDetailView.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 16/07/24.
//

import Foundation
import UIKit

class LSNotificationDetailView: UIView {
    private let senderLabel = UILabel()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let messageLabel = UILabel()
    private let tripIDLabel = UILabel()
    private let startLocationLabel = UILabel()
    private let endLocationLabel = UILabel()
    private let pickupTimeLabel = UILabel()
    private let estimatedDistanceLabel = UILabel()
    private let estimatedDurationLabel = UILabel()
    private let loadTypeLabel = UILabel()
    private let specialInstructionsLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        senderLabel.text = "Operations Team"
        senderLabel.font = UIFont.boldSystemFont(ofSize: 18)

        // Top Bar
        let topBar = UIView()
        topBar.backgroundColor = UIColor.appBackground
        addSubview(topBar)
        
        topBar.addSubview(senderLabel)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            topBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            topBar.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            topBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        senderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            senderLabel.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 10),
            senderLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
        ])
        
        
        // Close Button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
//        topBar.addSubview(closeButton)
        
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            closeButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -10),
//            closeButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
//        ])
        
        titleLabel.text = "New Trip Assigned"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor.appTheme

        timeLabel.text = "Today | 09:41:05 am"
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = UIColor.appTheme
        
        messageLabel.text = "Please review the new trip details"
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        messageLabel.numberOfLines = 0
        
        tripIDLabel.font = UIFont.systemFont(ofSize: 14)
        startLocationLabel.font = UIFont.systemFont(ofSize: 14)
        endLocationLabel.font = UIFont.systemFont(ofSize: 14)
        pickupTimeLabel.font = UIFont.systemFont(ofSize: 14)
        estimatedDistanceLabel.font = UIFont.systemFont(ofSize: 14)
        estimatedDurationLabel.font = UIFont.systemFont(ofSize: 14)
        loadTypeLabel.font = UIFont.systemFont(ofSize: 14)
        specialInstructionsLabel.font = UIFont.systemFont(ofSize: 14)
        
        let stackView = UIStackView(arrangedSubviews: [
             timeLabel, messageLabel
//            tripIDLabel, startLocationLabel, endLocationLabel,
//            pickupTimeLabel, estimatedDistanceLabel, estimatedDurationLabel,
//            loadTypeLabel, specialInstructionsLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        layer.cornerRadius = 8
//        layer.borderColor = UIColor.lightGray.cgColor
//        layer.borderWidth = 1
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with details: LSNotification) {
        senderLabel.text = details.getNotificationType()
        messageLabel.text = details.message
        if let dateTimestamp = details.createdTs {
            let dateAndTime = LSDateFormatter.shared.convertTimestampToDate(from: dateTimestamp, format: .MMMdYYYHmmaComma)
            timeLabel.text = dateAndTime
        } else {
            timeLabel.text = ""
        }

    }
    
    private func formatText(_ label: String, _ value: String, _ labelAttributes: [NSAttributedString.Key: Any], _ valueAttributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let formattedText = NSMutableAttributedString(string: label, attributes: labelAttributes)
        formattedText.append(NSAttributedString(string: value, attributes: valueAttributes))
        return formattedText
    }
}
