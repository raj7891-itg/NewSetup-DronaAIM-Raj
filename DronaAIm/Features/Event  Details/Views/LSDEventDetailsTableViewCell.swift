//
//  LSDEventDetailsTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 01/07/24.
//

import UIKit

class LSDEventDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tripIdLabel: UILabel!
    @IBOutlet weak var vehicleIdLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(with event: LSDAllEvents) {
        tripIdLabel.text = event.tripID ?? "NA"
        vehicleIdLabel.text = event.vehicleID ?? "NA"
        if let address = event.address {
            self.addressLabel.text = address
        } else {
            self.addressLabel.text = "GPS Location Not Available"
        }
        if let speed = event.gnssInfo?.speed {
            speedLabel.text = String(format: "%.2f mph", speed * 2.23694)
        }
        let date = event.eventDateAndTimeZone(format: .MMMdYYYHmmaComma)
            self.dateLabel.text = date
     }
}
