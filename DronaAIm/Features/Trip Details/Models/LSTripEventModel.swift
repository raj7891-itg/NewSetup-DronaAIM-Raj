//
//  LSTripEventModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 25/06/24.
//

import Foundation
enum TripEventType: Codable {
    case startLocation
    case harshBrake
    case breakTime
    case overSpeed
    case endLocation
}

struct TripEvent: Codable {
    let type: TripEventType
    let description: String
    let time: String
    let address: String
}
