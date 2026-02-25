//
//  LSDTripLiveTrackModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/20/24.
//

import Foundation
import MapKit

struct LSDTripLiveTrackModel: LSTripProtocol, LSDateTimezoneRepresentable, Codable {
    let lonestarID, tripID, tripStatus, deviceID: String?
    let imei, vehicleID, vin: String?
    let startSpeed: Double?
    let startDate, endDate: Double?
    let startHeading, startElevation: Double?
    let startLatitude, startLongitude, endLatitude, endLongitude: Double?
    let endSpeed, endHeading, endElevation, hardAccelerationCount: Double?
    let harshBrakingCount, harshCorneringCount, overSpeedingCount: Double?
    let safetyScore: Double?
    let vehicleLiveTracks: [VehicleLiveTrack]?
    let driverScore, vehicleScore, tripScore, tripDistance: Double?
    let tripDuration, incidentCount: Int?
    let startAddress, endAddress: String?
    let startTzAbbreviation, endTzAbbreviation, startTzName, endTzName: String?
    let startLocalizedTsInMilliSeconds, endLocalizedTsInMilliSeconds: Double?
    let estimatedStartAddress, estimatedEndAddress: Bool?

    enum CodingKeys: String, CodingKey {
        case lonestarID = "lonestarId"
        case tripID = "tripId"
        case tripStatus
        case deviceID = "deviceId"
        case imei
        case vehicleID = "vehicleId"
        case vin, startDate, startLatitude, startLongitude, startSpeed, startHeading, startElevation, endDate, endLatitude, endLongitude, endSpeed, endHeading, endElevation, hardAccelerationCount, harshBrakingCount, harshCorneringCount, incidentCount, overSpeedingCount, safetyScore, vehicleLiveTracks, driverScore, vehicleScore, tripScore, tripDistance, tripDuration, startAddress, endAddress
        case  startTzAbbreviation, endTzAbbreviation, startTzName, endTzName
        case startLocalizedTsInMilliSeconds, endLocalizedTsInMilliSeconds
        case estimatedStartAddress, estimatedEndAddress
    }
}

// MARK: - VehicleLiveTrack
struct VehicleLiveTrack: Codable {
    let tsInMilliSeconds: Double?
    let latitude, longitude: Double?
    let elevation: Int?
    let speed: Double?
    let heading: Int?
}

enum LSCoordinateType {
    case start, end, event
}
struct LSCoordinate {
    var coordinate: CLLocationCoordinate2D
    var type: LSCoordinateType
    var marker: String
    var title: String
    var date: String
    var address: String?
}

extension LSDTripLiveTrackModel {
    func getRouteCoordinates() -> [LSCoordinate]  {
        var coordinates = [LSCoordinate]()
        let startCoordinate = CLLocationCoordinate2D(latitude: self.startLatitude ?? 0, longitude: self.startLongitude ?? 0)
        let endCoordinate = CLLocationCoordinate2D(latitude: self.endLatitude ?? 0, longitude: self.endLongitude ?? 0)
        var date = "NA"
        if let startDate = self.startDate {
            date = LSDateFormatter.shared.convertTimestampToDate(from: startDate, format: .MMMdYYYHmmaComma) ?? "NA"
        } else {
            date = "NA"
        }
        if let endDate = self.endDate {
             date = LSDateFormatter.shared.convertTimestampToDate(from: endDate, format: .MMMdYYYHmmaComma) ?? "NA"
        } else {
            date = "NA"
        }

        if !startCoordinate.latitude.isZero {
            coordinates.append(LSCoordinate(coordinate: startCoordinate, type: .start, marker: "startMarker", title: "Start Location", date: date))
        } else if let vehicleLiveTracks = self.vehicleLiveTracks, let first = vehicleLiveTracks.last {
            let coordinate = CLLocationCoordinate2D(latitude: first.latitude ?? 0, longitude: first.longitude ?? 0)
            coordinates.append(LSCoordinate(coordinate: coordinate, type: .start, marker: "startMarker", title: "Start Location", date: date))
        }

        if !endCoordinate.latitude.isZero {
            coordinates.append(LSCoordinate(coordinate: endCoordinate, type: .end, marker: "endMarker", title: "End Location", date: date))
        } else if let vehicleLiveTracks = self.vehicleLiveTracks, let last = vehicleLiveTracks.first {
            let coordinate = CLLocationCoordinate2D(latitude: last.latitude ?? 0, longitude: last.longitude ?? 0)
            if let tripStatus = self.tripStatus, tripStatus == "Started" {
                coordinates.append(LSCoordinate(coordinate: coordinate, type: .end, marker: "truckMarker", title: "End Location", date: date))
            } else {
                coordinates.append(LSCoordinate(coordinate: coordinate, type: .end, marker: "endMarker", title: "End Location", date: date))
            }
        }
        if coordinates.count == 0 {
            coordinates.append(LSCoordinate(coordinate: startCoordinate, type: .start, marker: "startMarker", title: "Start Location", date: date))
            coordinates.append(LSCoordinate(coordinate: endCoordinate, type: .end, marker: "endMarker", title: "End Location", date: date))
        }
        return coordinates
    }
    
    func getCoordinates() -> [LSCoordinate]  {
        var coordinates = [LSCoordinate]()
        let startCoordinate = CLLocationCoordinate2D(latitude: self.startLatitude ?? 0, longitude: self.startLongitude ?? 0)
        let endCoordinate = CLLocationCoordinate2D(latitude: self.endLatitude ?? 0, longitude: self.endLongitude ?? 0)
        var startDate = "NA"
        var endDate = "NA"


        startDate = self.startDateAndTimeZone(format: .MMMdYYYHmmaComma)
         endDate = self.endDateAndTimeZone(format: .MMMdYYYHmmaComma)

        if !startCoordinate.latitude.isZero {
            coordinates.append(LSCoordinate(coordinate: startCoordinate, type: .start, marker: "startMarker", title: "Start Location", date: startDate))
        } else if let vehicleLiveTracks = self.vehicleLiveTracks, let first = vehicleLiveTracks.last {
            if let tsdate = first.tsInMilliSeconds {
                if let abservation = self.startTzAbbreviation,
                   let tsStartDate = LSDateFormatter.shared.convertTimestampToDate(from: tsdate, format: .MMMdYYYHmmaComma, timezone: abservation) {
                        startDate = "\(tsStartDate) \(abservation)"
                } else if let tsStartDate = LSDateFormatter.shared.convertTimestampToDate(from: tsdate, format: .MMMdYYYHmmaComma) {
                    startDate = tsStartDate
                }
            }

            let coordinate = CLLocationCoordinate2D(latitude: first.latitude ?? 0, longitude: first.longitude ?? 0)
            coordinates.append(LSCoordinate(coordinate: coordinate, type: .start, marker: "startMarker", title: "Start Location", date: startDate))
        }

        if !endCoordinate.latitude.isZero {
            coordinates.append(LSCoordinate(coordinate: endCoordinate, type: .end, marker: "endMarker", title: "End Location", date: endDate))
        } else if let vehicleLiveTracks = self.vehicleLiveTracks, let last = vehicleLiveTracks.first {
            let coordinate = CLLocationCoordinate2D(latitude: last.latitude ?? 0, longitude: last.longitude ?? 0)
            if let tripStatus = self.tripStatus, tripStatus == "Started" {
                coordinates.append(LSCoordinate(coordinate: endCoordinate, type: .end, marker: "truckMarker", title: "End Location", date: endDate))
            } else if let tripStatus = self.tripStatus, tripStatus == "Completed" {
                if let tsdate = last.tsInMilliSeconds {
                    if let abservation = self.endTzAbbreviation,
                       let tzEndDate = LSDateFormatter.shared.convertTimestampToDate(from: tsdate, format: .MMMdYYYHmmaComma, timezone: abservation) {
                        endDate = "\(tzEndDate) \(abservation)"
                    } else if let tsEndDate = LSDateFormatter.shared.convertTimestampToDate(from: tsdate, format: .MMMdYYYHmmaComma) {
                        endDate = tsEndDate
                    }
                }
                coordinates.append(LSCoordinate(coordinate: coordinate, type: .end, marker: "endMarker", title: "End Location", date: endDate))
            }
        }
        if coordinates.count == 0 {
            coordinates.append(LSCoordinate(coordinate: startCoordinate, type: .start, marker: "startMarker", title: "Start Location", date: startDate))
            coordinates.append(LSCoordinate(coordinate: endCoordinate, type: .end, marker: "endMarker", title: "End Location", date: endDate))
        }
        return coordinates
    }

}
