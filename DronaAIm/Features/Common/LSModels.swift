//
//  LSAliasModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 23/12/24.
//

import Foundation

struct LSAliasRequest: Encodable {
    let url: String
}

// MARK: - LSAliasModel
struct LSAliasModel: Codable {
    let originalURL, aliasURL: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case originalURL = "original_url"
        case aliasURL = "alias_url"
        case createdAt = "created_at"
    }
}
