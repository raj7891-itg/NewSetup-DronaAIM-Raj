//
//  LSVehicleStatsModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/23/24.
//

import Foundation
struct LSVehicleStatsModel: Codable {
    let totalTrips: Int?
    let totalDeviceMiles, totalDeviceHours: Double?
    let totalIncidents: Int?
    let deviceProvider: String?
}
