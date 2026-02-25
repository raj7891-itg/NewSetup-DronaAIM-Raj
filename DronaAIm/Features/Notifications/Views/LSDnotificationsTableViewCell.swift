//
//  LSDnotificationsTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 12/07/24.
//

import UIKit

class LSDnotificationsTableViewCell: UITableViewCell {
    static let identifier = "NotificationCell"
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(with notification: LSNotification) {
        if let dateTimestamp = notification.createdTs, let date = LSDateFormatter.shared.convertTimestampDate(from: dateTimestamp, format: .UsStandardDate) {
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                let dateAndTime = LSDateFormatter.shared.convertTimestampToDate(from: dateTimestamp, format: .hmm)
                timeLabel.text = dateAndTime
            } else {
                let dateAndTime = LSDateFormatter.shared.convertTimestampToDate(from: dateTimestamp, format: .ddMMM)
                timeLabel.text = dateAndTime
            }
        }
        titleLabel.text = notification.getNotificationType()
        messageLabel.text = notification.message
        if notification.isRead ?? false {
            titleLabel.textColor = .darkGray
            messageLabel.textColor = .darkGray
            timeLabel.textColor = .darkGray
        } else {
            titleLabel.textColor = .black
            messageLabel.textColor = .black
            timeLabel.textColor = .black
        }
    }
    
}
