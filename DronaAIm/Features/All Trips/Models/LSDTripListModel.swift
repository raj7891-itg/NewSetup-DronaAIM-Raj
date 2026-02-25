//
//  LSDTripListModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 27/06/24.
//

import Foundation

enum TripStatus: String, Codable {
    case completed
    case accepted
    case pending
    case currentTrip
}

// MARK: - LSRequstTrips
struct LSRequstTrips: Encodable {
    init() {
        
    }
    var searchByTripIdAndVehicleId: String?
    var tripStatus: [String] = []
    var fromDate: String?
    var toDate: String?
}

// MARK: - LSDTripListModel
struct LSDTripListModel: Codable {
    let pageDetails: PageDetails
    let trips: [LSDTrip]
}

// MARK: - PageDetails
struct PageDetails: Codable {
    let totalRecords, pageSize, currentPage: Int
}

// MARK: - Trip
struct LSDTrip: LSTripProtocol, LSDateTimezoneRepresentable, Codable {
    let lonestarID: String
    let tripID: String
    let tripStatus: String
    let deviceID: String?
    let imei: String?
    let vehicleID: String?
    let vin: String?
    let startDate: Double?
    let startLatitude, startLongitude, startSpeed: Double?
    let startHeading, startElevation: Double?
    let hardAccelerationCount, harshBrakingCount, harshCorneringCount, severeShockCount, shockCount: Double?
    let overSpeedingCount: Double?
    let driverID, driverName: String?
    let endDate: Double?
    let endLatitude, endLongitude, endSpeed: Double?
    let endHeading, endElevation: Double?
    let safetyScore: Double?
    let isOrphaned: Bool?
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
        case vin, startDate, startLatitude, startLongitude, startSpeed, startHeading, startElevation, hardAccelerationCount, harshBrakingCount, harshCorneringCount, incidentCount, overSpeedingCount, severeShockCount, shockCount
        case driverID = "driverId"
        case driverName, endDate, endLatitude, endLongitude, endSpeed, endHeading, endElevation, safetyScore, isOrphaned, driverScore, vehicleScore, tripScore, tripDistance, tripDuration, startAddress, endAddress
        case  startTzAbbreviation, endTzAbbreviation, startTzName, endTzName
        case startLocalizedTsInMilliSeconds, endLocalizedTsInMilliSeconds
        case estimatedStartAddress, estimatedEndAddress
    }
    
}
