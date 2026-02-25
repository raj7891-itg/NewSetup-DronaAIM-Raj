//
//  LSNotificationDetailsIdsView.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 17/07/24.
//

import Foundation
import UIKit
protocol LSNotificationDetailsIdsDelegate: AnyObject {
    func didTapuploadButton()
}

class LSNotificationDetailsIdsView: UIView {
    weak var delegate: LSNotificationDetailsIdsDelegate?
    
    private let senderLabel = UILabel()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let messageLabel = UILabel()
    private let uploadButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        senderLabel.text = "Fleet Manager"
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
            topBar.topAnchor.constraint(equalTo: topAnchor),
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
//        
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            closeButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -10),
//            closeButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
//        ])
        
        titleLabel.text = "Upload Driver License"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor.appTheme

        timeLabel.text = "Today | 09:41:05 am"
        timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        timeLabel.textColor = UIColor.appTheme
        
        messageLabel.text = "Christopher, please upload your driver license in Documents & Uploads section"
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        
        let stackView = UIStackView(arrangedSubviews: [timeLabel, messageLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 16)
        ])
        
        // Upload Button
        uploadButton.setImage(UIImage(systemName: "arrowshape.right.circle.fill"), for: .normal)
        uploadButton.addTarget(self, action: #selector(uploadAction), for: .touchUpInside)
        addSubview(uploadButton)
        
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            uploadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            uploadButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            uploadButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        layer.cornerRadius = 8
        backgroundColor = .white
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
    
    @objc func uploadAction(sender: UIButton) {
        self.delegate?.didTapuploadButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
