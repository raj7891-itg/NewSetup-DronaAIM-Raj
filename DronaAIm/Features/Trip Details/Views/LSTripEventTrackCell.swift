//
//  LSTripEventTrackCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 25/06/24.
//

import UIKit
import MapKit

protocol LSTripProtocol {
    var startDate: Double? { get }
    var endDate: Double? { get }
    var startLatitude: Double? { get }
    var startLongitude: Double? { get }
    var endLatitude: Double? { get }
    var endLongitude: Double? { get }
}

protocol LSEventProtocol {
    var tsInMilliSeconds: Double? { get }
    var eventType: LSDAllEventType? { get }
    var gnssInfo: LSDEventGnssInfo? { get }
    var tripID: String? { get }
    var eventID: String? { get }
}

class LSTripEventTrackCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var speedStack: UIStackView!
    @IBOutlet weak var lineView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config<T: LSEventProtocol>(with event: T, indexPath: IndexPath) {
        self.timeLabel.text = "NA"
        var eventTitle = ""
        if let eventInfo = getEventinfo(for: event.eventType) {
            eventTitle = eventInfo.title
            self.iconImageView.image = eventInfo.icon
        }
        if let eventId = event.eventID {
            eventTitle += "(\(String(describing: eventId)))"
        }
        if let lsEvent = event as? LSDAllEvents {
            if let address = lsEvent.address {
                self.addressLabel.text = address
            }
             let date = lsEvent.eventDateAndTimeZone(format: .MMMdYYYHmmaComma)
                self.timeLabel.text = date
            
        }
        self.eventTypeLabel.text = eventTitle
        
        speedStack.isHidden = false
        speedStack.isLayoutMarginsRelativeArrangement = true
        speedStack.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        if let speed = event.gnssInfo?.speed {
            speedLabel.text = String(format: "%.2f mph", speed * 2.23694)
        }
    }
    
    
    func displayLocation(liveTrack: LSDTripLiveTrackModel?, coordinateType: LSCoordinateType)
    {
        speedStack.isHidden = true

        self.addressLabel.text = "GPS Location Not Available"
        self.eventTypeLabel.text = ""

        if coordinateType == .start {
            self.eventTypeLabel.text = "Start Location"
            if liveTrack?.startAddress == "NA" || liveTrack?.startAddress == "" || liveTrack?.startAddress == nil {
                self.addressLabel.text = "GPS Location Not Available"
            } else {
                self.addressLabel.text = liveTrack?.startAddress ?? "GPS Location Not Available"
            }
//            if liveTrack?.estimatedStartAddress ?? false {
//                self.iconImageView.image = UIImage(named: "startMarker.warning")
//            } else {
                self.iconImageView.image = UIImage(named: "startMarker")
//            }
            
            timeLabel.text = "NA"
            timeLabel.text = liveTrack?.startDateAndTimeZone(format: .MMMdYYYHmmaComma)

        } else if coordinateType == .end {
            self.eventTypeLabel.text = "End Location"
            if liveTrack?.endAddress == "NA" || liveTrack?.endAddress == "" || liveTrack?.endAddress == nil {
                self.addressLabel.text = "GPS Location Not Available"
            } else {
                self.addressLabel.text = liveTrack?.endAddress ?? "GPS Location Not Available"
            }
//            if liveTrack?.estimatedEndAddress ?? false {
//                self.iconImageView.image = UIImage(named: "endMarker.warning")
//            } else {
                self.iconImageView.image = UIImage(named: "endMarker")
//            }
            
            timeLabel.text = "NA"
            timeLabel.text = liveTrack?.endDateAndTimeZone(format: .MMMdYYYHmmaComma)

        }

    }


}
