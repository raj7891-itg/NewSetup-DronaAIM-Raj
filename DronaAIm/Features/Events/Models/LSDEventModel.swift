//
//  LSDEventModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 29/06/24.
//

import Foundation
// MARK: - LSRequstEvents
struct LSRequstEvents: Encodable {
    init() {
        
    }
    var searchByTripIdEventIdEventType: String?
    var eventTypes: [String]?
    var fromDate: String?
    var toDate: String?
}


// MARK: - LSDAllEventsModel
struct LSDAllEventsModel: Codable {
    let pageDetails: PageDetails?
    let allEvents: [LSDAllEvents]?
}

// MARK: - AllEvent
struct LSDAllEvents: LSEventProtocol, Codable {
    
    let tsInMilliSeconds: Double?
    let imei: String?
    let eventType: LSDAllEventType?
    let vendorEventID: String?
    let gnssInfo: LSDEventGnssInfo?
    var media: [LSDAllEventsMedia]?
    let tripID, eventID: String?
    let deviceID: String?
    let vehicleID: String?
    let driverID, driverFirstName, driverLastName : String?
    let tzName, tzAbbreviation: String?
    let localizedTsInMilliSeconds: Double?
    let address: String?
    let uiEventType: String?
    
    enum CodingKeys: String, CodingKey {
        case tsInMilliSeconds, imei, eventType
        case vendorEventID = "vendorEventId"
        case gnssInfo, media
        case tripID = "tripId"
        case eventID = "eventId"
        case deviceID = "deviceId"
        case vehicleID = "vehicleId"
        case driverID = "driverId"
        case driverFirstName, driverLastName
        case tzName, tzAbbreviation, address
        case localizedTsInMilliSeconds
        case uiEventType
    }
  
}

// MARK: - LSDAllEventType
enum LSDAllEventType: String, Codable, CaseIterable {
    case accelerate = "Accelerate"
    case brake = "Brake"
    case turn = "Turn"
    case speed = "Speed"
    case shock = "Shock"
    case severeShock = "SevereShock"
    case panicButton = "PanicButton"
}

// MARK: - GnssInfo
struct LSDEventGnssInfo: Codable {
    let isValid: Bool?
    let speed: Double?
    let heading: Int?
    let longitude, latitude: Double?
    let elevation: Int?
}

// MARK: - Media
struct LSDAllEventsMedia: Codable {
    let type: LSDMediaType?
    let camera: Int?
    let startTsInMilliseconds, endTsInMilliseconds: Double?
    let url: String?
}

enum LSDMediaType: String, Codable {
    case jpg = "jpg"
    case mp4 = "mp4"
    case h264i = "h264i"
}

extension LSDAllEvents {    
    func eventDateAndTimeZone(format: LSDateFormat) -> String {
        if let startDate = tsInMilliSeconds {
            if let startTimeZone = tzAbbreviation,
               let startDateTime = LSDateFormatter.shared.convertTimestampToDate(from: startDate, format: format, timezone: startTimeZone) {
                return "\(startDateTime) \(startTimeZone)"
            } else if let startDateTime = LSDateFormatter.shared.convertTimestampToDate(from: startDate, format: format)  {
                return startDateTime
            }
        }
        return ""
    }
    
    func filterMediaByCamera() -> [String: [LSDAllEventsMedia]] {
        var result: [String: [LSDAllEventsMedia]] = [:]
        guard let mediaArray = self.media else { return [:] }
        for media in mediaArray {
            if let camera = media.camera {
                let cameraKey = "camera\(camera)"
                if result[cameraKey] == nil {
                    result[cameraKey] = []
                }
                result[cameraKey]?.append(media)
            } else {
                if let urlString = media.url, let url = URL(string: urlString) {
                    let lastPath = url.deletingPathExtension().lastPathComponent
                    if let lastCharacter = lastPath.last {
                        let cameraKey = "camera\(lastCharacter)"
                        if result[cameraKey] == nil {
                            result[cameraKey] = []
                        }
                        result[cameraKey]?.append(media)
                    }
                }
            }
        }
        return result
    }
    
    func containsMp4() -> Bool {
        let mediaDic = filterMediaByCamera()
        for (_, mediaArray) in mediaDic {
            if mediaArray.contains(where: { $0.type == .mp4 }) {
                return true // Return true if an "mp4" is found
            }
        }
        return false // Return false if no "mp4" is found after checking all media
    }

}
