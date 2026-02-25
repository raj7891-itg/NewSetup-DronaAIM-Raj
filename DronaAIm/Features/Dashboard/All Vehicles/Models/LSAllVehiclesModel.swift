//
//  LSAllVehiclesModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/11/24.
//

import Foundation
// MARK: - LSAllVehiclesModel
struct LSAllVehiclesModel: Codable {
    let pageDetails: PageDetails?
    let vehicles: [LSVehicle]?
}


// MARK: - Vehicle
struct LSVehicle: Codable {
    let vehicleID, vin, deviceID, lonestarID: String?
    let tripID, tripStatus: String?
    let meanScore: Double?
    let make, model, driverID, driverFirstName, driverLastName: String?
    let message: String?
    let lastLiveTrack: LastLiveTrack?
    let year: Int?
    let licencePlateNumber: String?
    let partnerName: String?
    let customVehicleId: String?
    let imeiByDevice: String?

    enum CodingKeys: String, CodingKey {
        case vehicleID = "vehicleId"
        case vin
        case deviceID = "deviceId"
        case lonestarID = "lonestarId"
        case tripID = "tripId"
        case tripStatus, meanScore, make, model
        case driverID = "driverId"
        case driverFirstName, driverLastName, message, lastLiveTrack
        case year
        case licencePlateNumber, partnerName, customVehicleId, imeiByDevice
    }
}

// MARK: - LastLiveTrack
struct LastLiveTrack: Codable {
    let tsInMilliSeconds: Double?
    let imei, eventType, vendorEventID: String?
    let gnssInfo: GnssInfo?

    enum CodingKeys: String, CodingKey {
        case tsInMilliSeconds, imei, eventType
        case vendorEventID = "vendorEventId"
        case gnssInfo
    }
}

// MARK: - GnssInfo
struct GnssInfo: Codable {
    let isValid: Bool?
    let speed, heading: Double?
    let longitude, latitude: Double?
    let elevation: Double?
}
