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
        if let tripDurationString = trip.tripDuration,
           let tripDurationMs = Int(tripDurationString) {
            let time = LSCalculation.shared.duration(from: tripDurationMs)
            let hours = time.hours
            let minutes = time.minutes
            tripDurationLabel.text = "\(hours) hrs \(minutes) mins"
        } else {
            tripDurationLabel.text = "NA"
        }
        
        if let tripDistanceString = trip.tripDistance,
           let tripDistanceKm = Double(tripDistanceString) {
            let tripDistanceMiles = LSCalculation.shared.distance(from: tripDistanceKm)
            tripDistanceLabel.text = "\(tripDistanceMiles) miles"
        } else {
            tripDistanceLabel.text = "NA"
        }
    }

}
