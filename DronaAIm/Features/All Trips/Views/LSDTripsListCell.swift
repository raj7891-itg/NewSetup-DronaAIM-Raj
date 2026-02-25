//
//  LSDTripsListCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 27/06/24.
//

import UIKit
import EasyTipView

class LSDTripsListCell: UITableViewCell {
    @IBOutlet weak var tripStatusIcon: UIImageView!
    @IBOutlet weak var tripIdLabel: UILabel!
    @IBOutlet weak var vehicleIdLabel: UILabel!
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startLocationLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endLocationLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var safetyScoreView: UIStackView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var startMarker: UIImageView!
    @IBOutlet weak var endMarker: UIImageView!
    
    @IBOutlet weak var startToolTipButton: UIButton!
    @IBOutlet weak var endToolTipButton: UIButton!

    var overlayView: UIView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func addOverLay() {
         overlayView = UIView(frame: cardView.bounds)
        overlayView?.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        overlayView?.isUserInteractionEnabled = false
        if let overLay = overlayView {
            self.cardView.addSubview(overLay)
        }
    }
    
    func configure(with trip: LSDTrip, at indexPath: IndexPath, in tableView: UITableView) {
        endLocationLabel.text = ""
        startLocationLabel.text = ""
        
        if let isOrphaned = trip.isOrphaned, isOrphaned {
            self.contentView.alpha = 0.5 // Fades the entire cell
        } else {
            self.contentView.alpha = 1 // Fades the entire cell
        }
         if trip.isOrphaned == true {
            tripStatusIcon.image = UIImage(named: "truncated")
        } else if trip.tripStatus == "Started" {
            tripStatusIcon.image = UIImage(named: "progress")
        } else {
            tripStatusIcon.image = UIImage(named: "completed")
        }

        var scoreColor = UIColor.appRed
        if let tripScore = trip.tripScore {
            if tripScore >= 90 {
                scoreColor = UIColor.appGreen
            } else if tripScore >= 80 && tripScore <= 89 {
                scoreColor = UIColor.appYellow
            }
        }
        statusLabel.textColor = scoreColor
        safetyScoreView.backgroundColor = scoreColor.withAlphaComponent(0.1)
        safetyScoreView.layer.borderColor = scoreColor.cgColor

        if let tripScore = trip.safetyScore {
            statusLabel.text = "Trip Score : \(LSCalculation.shared.doubleFormat(score: tripScore))"
        } else {
            statusLabel.text = "Trip Score NA"
            statusLabel.textColor = .lightGray
            safetyScoreView.backgroundColor = .lightGray.withAlphaComponent(0.1)
            safetyScoreView.layer.borderColor = UIColor.lightGray.cgColor
        }

        tripIdLabel.text = trip.tripID
        vehicleIdLabel.text = trip.vehicleID
        
        if let incidents = trip.incidentCount {
            if incidents == 0 || incidents == 1 {
                deviceIdLabel.text = "\(incidents) event"
            } else {
                deviceIdLabel.text = "\(incidents) events"
            }
        }
        if let tripDistance = trip.tripDistance {
            let distance = LSCalculation.shared.distance(from: tripDistance)
            distanceLabel.text = "\(distance) miles"
        } else {
            distanceLabel.text = "NA"
        }
        
        if trip.startAddress == "NA" || trip.startAddress == "" || trip.startAddress == nil {
            self.startLocationLabel.text = "GPS Location Not Available"
        } else {
            self.startLocationLabel.text = trip.startAddress ?? "GPS Location Not Available"
        }
        if trip.estimatedStartAddress ?? false {
            self.startMarker.image = UIImage(named: "startMarker.warning")
        }
        
        if trip.endAddress == "NA" || trip.endAddress == "" || trip.endAddress == nil {
            self.endLocationLabel.text = "GPS Location Not Available"
        } else {
            self.endLocationLabel.text = trip.endAddress ?? "GPS Location Not Available"
        }
        if trip.estimatedEndAddress ?? false {
            endToolTipButton.isHidden = false
        }
        if trip.estimatedStartAddress ?? false {
            startToolTipButton.isHidden = false
        }
        startDateLabel.text = "NA"
        endDateLabel.text = "NA"
        
        startDateLabel.text = trip.startDate(format: .UsStandardDate)
        endDateLabel.text = trip.endDate(format: .UsStandardDate)
    }
    
    @IBAction func tipIconAction(_ sender: UIButton) {
        var preferences = EasyTipView.Preferences()

        // Text settings
        preferences.drawing.font = UIFont.systemFont(ofSize: 13)
        preferences.drawing.foregroundColor = .black

        // Background & border
        preferences.drawing.backgroundColor = UIColor(white: 0.98, alpha: 1.0) // Light gray-white for better contrast
        preferences.drawing.borderColor = UIColor.gray
        preferences.drawing.borderWidth = 1

        // Shadow
        preferences.drawing.shadowColor = UIColor(hex: "#0C0C0D")
        preferences.drawing.shadowOpacity = 0.3
        preferences.drawing.shadowRadius = 4
        preferences.drawing.shadowOffset = CGSize(width: 0, height: 2)
        let tipView = EasyTipView(
            text: "Location is calculated based on GPS data",
            preferences: preferences,
            delegate: nil
        )
        tipView.show(forView: sender, withinSuperview: self)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            tipView.dismiss()
        }
    }
    
    
}
