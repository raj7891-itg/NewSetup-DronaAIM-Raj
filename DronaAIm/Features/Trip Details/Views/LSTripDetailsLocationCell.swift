//
//  LSTripDetailsLocationCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 25/06/24.
//

import UIKit

class LSTripDetailsLocationCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var locationtypeLabel: UILabel!
    @IBOutlet weak var timeTypeLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(with trip: LSDTrip, coordinateType: LSCoordinateType) {
//        let startEndCoordinates = liveTrack?.getCoordinates()
        self.locationLabel.text = "GPS Location Not Available"
        self.locationtypeLabel.text = ""
        timeTypeLabel.text = ""

//        var coordinate: LSCoordinate?
        if coordinateType == .start {
            timeTypeLabel.text = "Start Time:"
            self.locationtypeLabel.text = "Start Location"
            if trip.startAddress == "NA" || trip.startAddress == "" || trip.startAddress == nil {
                self.locationLabel.text = "GPS Location Not Available"
            } else {
                self.locationLabel.text = trip.startAddress ?? "GPS Location Not Available"
            }
//            if trip.estimatedStartAddress ?? false {
//                self.iconImageView.image = UIImage(named: "startMarker.warning")
//            } else {
                self.iconImageView.image = UIImage(named: "startMarker")
//            }
            
            timeLabel.text = "NA"
            timeLabel.text = trip.startDateAndTimeZone(format: .MMMdYYYHmmaComma)

        } else if coordinateType == .end {
            self.locationtypeLabel.text = "End Location"
//            coordinate = startEndCoordinates?.first(where: { $0.type == .end})
            timeTypeLabel.text = "End Time:"
            if trip.endAddress == "NA" || trip.endAddress == "" || trip.endAddress == nil {
                self.locationLabel.text = "GPS Location Not Available"
            } else {
                self.locationLabel.text = trip.endAddress ?? "GPS Location Not Available"
            }
//            if trip.estimatedEndAddress ?? false {
//                self.iconImageView.image = UIImage(named: "endMarker.warning")
//            } else {
                self.iconImageView.image = UIImage(named: "endMarker")
//            }
            
            timeLabel.text = "NA"
            timeLabel.text = trip.endDateAndTimeZone(format: .MMMdYYYHmmaComma)

        }
        
    }

}
