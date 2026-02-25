//
//  LSTripVehicleDetailsTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/2/24.
//

import UIKit

class LSTripVehicleDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var vehicleMilesLabel: UILabel!
    @IBOutlet weak var totalTrips: UILabel!
    @IBOutlet weak var vehicleScoreLabel: UILabel!
    @IBOutlet weak var eldProviderLabel: UILabel!
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var vehicleIdLabel: UILabel!
    @IBOutlet weak var vinLabel: UILabel!
    
    @IBOutlet weak var vehicleScoreView: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(with trip: LSDTrip, vehicleStats: LSVehicleStatsModel?) {
        if let totalTrips = vehicleStats?.totalTrips {
            self.totalTrips.text = "\(String(totalTrips)) Trips"
        } else {
            self.totalTrips.text = "NA"
        }
        
        if let vehicleMiles = vehicleStats?.totalDeviceMiles {
            let miles = LSCalculation.shared.distance(from: vehicleMiles)
            vehicleMilesLabel.text = "\(miles) miles"
        } else {
            vehicleMilesLabel.text = "NA"
        }
        self.vinLabel.text = trip.vin
        self.vehicleIdLabel.text = trip.vehicleID
        self.deviceIdLabel.text = trip.deviceID
        self.eldProviderLabel.text = vehicleStats?.deviceProvider ?? "NA"
        
        var scoreColor = UIColor.appRed
        if let tripScore = trip.vehicleScore {
            if tripScore >= 90 {
                scoreColor = UIColor.appGreen
            } else if tripScore >= 80 && tripScore <= 89 {
                scoreColor = UIColor.appYellow
            }
        }
        vehicleScoreLabel.textColor = scoreColor
        vehicleScoreView.backgroundColor = scoreColor.withAlphaComponent(0.1)
        vehicleScoreView.layer.borderColor = scoreColor.cgColor

        if let vehicleScore = trip.vehicleScore {
            let vehicleScore = LSCalculation.shared.doubleFormat(score: vehicleScore)
            self.vehicleScoreLabel.text = "Vehicle Score \(vehicleScore)"
        } else {
            self.vehicleScoreLabel.text = "Vehicle Score NA"
            vehicleScoreLabel.textColor = UIColor.lightGray
            vehicleScoreView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
            vehicleScoreView.layer.borderColor = UIColor.lightGray.cgColor
        }

    }

}
