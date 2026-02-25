//
//  LSnotifications.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 16/12/25.
//

struct LSRequstNotifications: Encodable {
    let userId: String
    let messageTypes: [String]?
    let isRead: Bool?
}

struct LSRequstReadUnread: Encodable {
    let messageIds: [String]
    let readByUserId: String
}

