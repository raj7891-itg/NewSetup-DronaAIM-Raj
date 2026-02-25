//
//  LSDNotificationsmodel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 12/07/24.
//

import Foundation

// MARK: - LSNotificationModel
struct LSNotificationModel: Codable {
    let pageDetails: PageDetails
    let notifications: [LSNotification]
}

// MARK: - Notification
struct LSNotification: Codable {
    let message, messageID: String?
    let messageType: MessageType?
    let metadata: Metadata?
    let lonestarID: String?
    let createdTs: Double?
    let isRead: Bool?
    let readByUserID: String?
    let readTs: Double?
    let isPushNote: Bool?

    enum CodingKeys: String, CodingKey {
        case message
        case messageID = "messageId"
        case messageType, metadata
        case lonestarID = "lonestarId"
        case createdTs, isRead
        case readByUserID = "readByUserId"
        case readTs, isPushNote
    }
}

enum MessageType: String, Codable {
    case documentApprovedNotification = "DOCUMENT_APPROVED_NOTIFICATION"
    case documentRejectedNotification = "DOCUMENT_REJECTED_NOTIFICATION"
    case documentSubmissionNotification = "DOCUMENT_SUBMISSION_NOTIFICATION"
    case driverOnboardingNotification = "DRIVER_ONBOARDING_NOTIFICATION"
    case driverVehicleAssociationNotification = "DRIVER_VEHICLE_ASSOCIATION_NOTIFICATION"
    case driverDisabled = "DRIVER_DISABLED"
    case driverReActivated = "DRIVER_REACTIVATED"
    
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = MessageType(rawValue: value) ?? .unknown
    }
}

// MARK: - Metadata
struct Metadata: Codable {
    let userID: String?
    let vehicleID: String?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case vehicleID = "vehicleId"
    }
}


extension LSNotification {
    
    func getNotificationType() -> String {
        guard let messageType = self.messageType else {
            return "Notification"
        }

        switch messageType {
        case .driverOnboardingNotification:
            return "Welcome Aboard"
        case .documentSubmissionNotification:
            return "Document Upload Reminder"
        case .driverVehicleAssociationNotification:
            return "Vehicle Assigned"
        case .documentApprovedNotification:
            return "Document Approved!"
        case .documentRejectedNotification:
            return "Document Rejected!"
        case .driverDisabled:
            return "Driver Disabled"
        case .driverReActivated:
            return "Driver ReActivated"
        @unknown default:
            return "Notification"
        }
    }
}

