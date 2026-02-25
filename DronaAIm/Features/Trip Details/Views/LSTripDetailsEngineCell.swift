//
//  LSTripDetailsEngineCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 25/06/24.
//

import UIKit

class LSTripDetailsEngineCell: UITableViewCell {

    @IBOutlet weak var tripDistanceLabel: UILabel!
    @IBOutlet weak var tripDurationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func config(with indexPath: IndexPath, trip: LSDTrip) {
        if let tripDuration = trip.tripDuration {
            let time = LSCalculation.shared.duration(from: Int(tripDuration))
            let hours = time.hours
            let minutes = time.minutes
            tripDurationLabel.text = "\(hours) hrs \(minutes) mins"
        } else {
            tripDurationLabel.text = "NA"
        }
        
        if let tripDistance = trip.tripDistance {
            let tripDistance = LSCalculation.shared.distance(from: tripDistance)
            tripDistanceLabel.text = "\(tripDistance) miles"
        } else {
            tripDistanceLabel.text = "NA"
        }
    }

}
