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
    let totalRecords: Int
    let pageSize: Int
    let currentPage: Int
   // let totalPages: Int   // ✅ NEW
}

// MARK: - Trip
struct LSDTrip: Codable {
    
    let lonestarID: String?
    let tripID: String?
    let tripStatus: String?
    
    let deviceID: String?
    let imei: String?
    let vehicleID: String?
    let vin: String?
    
    // MARK: - Start Info
    let startDate: String?
    let startLatitude: String?
    let startLongitude: String?
    let startSpeed: String?
    let startHeading: String?
    let startElevation: String?
    
    // MARK: - End Info
    let endDate: String?
    let endLatitude: String?
    let endLongitude: String?
    let endSpeed: String?
    let endHeading: String?
    let endElevation: String?
    
    // MARK: - Counts
    let hardAccelerationCount: String?
    let harshBrakingCount: String?
    let harshCorneringCount: String?
    let incidentCount: String?
    let overSpeedingCount: String?
    let severeShockCount: String?
    let shockCount: String?
    let sosCount: String?                // ✅ NEW
    
    // MARK: - Distance & Duration
    let totalDistanceInKms: String?      // ✅ NEW
    let totalDistanceInMiles: String?    // ✅ NEW
    let tripDistance: String?
    let tripDuration: String?
    
    // MARK: - Scores
    let driverScore: String?
    let safetyScore: String?
    let tripScore: String?
    let vehicleScore: String?
    
    // MARK: - Driver
    let driverID: String?
    let driverFirstName: String?         // ✅ NEW
    let driverLastName: String?          // ✅ NEW
    
    // MARK: - Flags
    let qualifiedTrip: Bool?
    let isOrphaned: Bool?
    let estimatedStartAddress: Bool?
    let estimatedEndAddress: Bool?
    
    // MARK: - Address
    let startAddress: String?
    let endAddress: String?
    
    // MARK: - Timezone
    let startTzAbbreviation: String?
    let startTzName: String?
    let startLocalizedTsInMilliSeconds: String?
    
    let endTzAbbreviation: String?
    let endTzName: String?
    let endLocalizedTsInMilliSeconds: String?
    
    // MARK: - Extra Fields
    let lastScoreUpdateTs: String?       // ✅ NEW
    let orphanedDate: String?            // ✅ NEW
    let travelStats: String?             // ✅ NEW
    let correctionStatus: String?        // ✅ NEW
    let tripScoreCalculation: String?    // ✅ NEW
    let isliveTrackUpdated: Bool?      // ✅ NEW
    let mileageInfo: [String]?            // ✅ NEW
    
    let scoringWeightage: [[String: Int]]?   // ✅ NEW ARRAY
    
    enum CodingKeys: String, CodingKey {
        case lonestarID = "lonestarId"
        case tripID = "tripId"
        case tripStatus
        
        case deviceID = "deviceId"
        case imei
        case vehicleID = "vehicleId"
        case vin
        
        case startDate, startLatitude, startLongitude, startSpeed, startHeading, startElevation
        case endDate, endLatitude, endLongitude, endSpeed, endHeading, endElevation
        
        case hardAccelerationCount
        case harshBrakingCount
        case harshCorneringCount
        case incidentCount
        case overSpeedingCount
        case severeShockCount
        case shockCount
        case sosCount
        
        case totalDistanceInKms
        case totalDistanceInMiles
        case tripDistance
        case tripDuration
        
        case driverScore
        case safetyScore
        case tripScore
        case vehicleScore
        
        case driverID = "driverId"
        case driverFirstName
        case driverLastName
        
        case qualifiedTrip
        case isOrphaned
        case estimatedStartAddress
        case estimatedEndAddress
        
        case startAddress
        case endAddress
        
        case startTzAbbreviation
        case startTzName
        case startLocalizedTsInMilliSeconds
        
        case endTzAbbreviation
        case endTzName
        case endLocalizedTsInMilliSeconds
        
        case lastScoreUpdateTs
        case orphanedDate
        case travelStats
        case correctionStatus
        case tripScoreCalculation
        case isliveTrackUpdated
        case mileageInfo
        
        case scoringWeightage
    }
}

// MARK: - Adapter to LSDateTimezoneRepresentable
struct LSDTripDateTZAdapter: LSDateTimezoneRepresentable {
    private let trip: LSDTrip
    init(_ trip: LSDTrip) { self.trip = trip }
    
    var startLocalizedTsInMilliSeconds: Double? {
        guard let s = trip.startLocalizedTsInMilliSeconds else { return nil }
        return Double(s)
    }
    var endLocalizedTsInMilliSeconds: Double? {
        guard let s = trip.endLocalizedTsInMilliSeconds else { return nil }
        return Double(s)
    }
    var startDate: Double? {
        guard let s = trip.startDate else { return nil }
        return Double(s)
    }
    var endDate: Double? {
        guard let s = trip.endDate else { return nil }
        return Double(s)
    }
    var startTzAbbreviation: String? { trip.startTzAbbreviation }
    var endTzAbbreviation: String? { trip.endTzAbbreviation }
}

// Convenience accessor
extension LSDTrip {
    var dateTZ: LSDateTimezoneRepresentable { LSDTripDateTZAdapter(self) }
}
