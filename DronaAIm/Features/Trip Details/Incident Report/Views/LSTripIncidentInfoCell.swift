//
//  LSTripIncidentInfoCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 25/06/24.
//

import UIKit
struct IncidentDetails {
    let incidentType: String
    let incidentEvent: String
    let eventType: LSDIncidentType
}

class LSTripIncidentInfoCell: UITableViewCell {

    @IBOutlet weak var incidentTypeLabel: UILabel!
    @IBOutlet weak var incidentCountLabel: UILabel!
    var incidents = [IncidentDetails]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(with details: IncidentDetails, events: [LSDAllEvents]) {
        self.incidentTypeLabel.text = details.incidentType
        let eventsCount = filterEvents(type: details.eventType, events: events)
        if eventsCount.count == 0 || eventsCount.count == 1 {
            incidentCountLabel.text = "\(eventsCount.count) event"
        } else {
            incidentCountLabel.text = "\(eventsCount.count) events"
        }
    }
    
    func filterEvents(type: LSDIncidentType, events: [LSDAllEvents]) -> [LSDAllEvents] {
        let filteredEvents = events.filter { event in
            guard let eventType = event.eventType else {
                return false
            }
            return type.rawValue == eventType.rawValue
            
        }
        return filteredEvents
    }


}
