//
//  LSPushNotificationModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 04/12/24.
//

import Foundation
import Foundation

// MARK: - PushNotification
struct LSPushNotificationModel: Codable {
    let messageId: String?
    let aps: APS?
    let metadata: LSNotificationMetadata?

    // Coding keys to match the JSON keys
    enum CodingKeys: String, CodingKey {
        case messageId = "messageId"
        case aps
        case metadata
    }
}

// MARK: - APS (Apple Push Service)
struct APS: Codable {
    let alert: Alert?
    let badge: Int?
}

// MARK: - Alert
struct Alert: Codable {
    let actionLocKey: String?
    let body: String?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case actionLocKey = "action-loc-key"
        case body
        case title
    }
}

// MARK: - Metadata
struct LSNotificationMetadata: Codable {
    let userId: String?
}

