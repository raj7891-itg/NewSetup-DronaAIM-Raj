//
//  LSDriverScoreModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/11/24.
//

import Foundation
// MARK: - LSDriverScoreModel
struct LSDriverScoreModel: Codable {
    let userID: String?
    let cummulativeScore: Double?
    let data: [Datum]?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case cummulativeScore, data
    }
}

// MARK: - Datum
struct Datum: Codable {
    let medianScore, meanScore, eventDensity: Double?
    let driverScoreTs: Double?
}
