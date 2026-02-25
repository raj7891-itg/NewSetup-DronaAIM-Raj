//
//  LSDEventTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 29/06/24.
//

import UIKit
import SDWebImage

class LSDEventTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tripIdLabel: UILabel!
    @IBOutlet weak var playIcon: UIButton!
    
    @IBOutlet weak var eventIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Set the minimum height constraint
              let minHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140)
              minHeightConstraint.priority = .required
              minHeightConstraint.isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(with event: LSDAllEvents, tableView: UITableView) {
        if let eventID = event.eventID {
            eventIdLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            eventIdLabel.text = "Event ID - \(eventID)"
        }
        titleLabel.text = event.uiEventType ?? "NA"
        tripIdLabel.text = event.tripID ?? "NA"
        if let address = event.address {
            self.addressLabel.text = address
        } else {
            self.addressLabel.text = "GPS Location Not Available"
        }
        
       let date = event.eventDateAndTimeZone(format: .MMMdHmma) 
            self.dateLabel.text = date
        let sansataBaseUrl = LSAPIEndpoints.sansataBaseUrl()
        
        if let media = event.media, let thumbnail = media.first(where: {$0.type == .jpg}) {
            if let url = thumbnail.url {
                let thumbnail = URL(string: sansataBaseUrl+url)
                self.thumbnail.sd_setImage(with: thumbnail, placeholderImage: UIImage(systemName: "photo.artframe"))
            }
        }
       // Show and hide play icon based on Mp4 availability
        if event.containsMp4() {
            playIcon.isHidden = false
        } else {
            playIcon.isHidden = true
        }

    }

}
