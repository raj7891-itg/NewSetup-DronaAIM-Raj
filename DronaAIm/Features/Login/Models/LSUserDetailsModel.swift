//
//  UserDetailsModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 03/06/24.
//

import Foundation

enum LSUserRole: String, Codable {
    case driver, fleetManager
}

struct LSUserDetailsModel: Codable {
    let id: Int
    let userId: String
    let initials: String?
    let cognitoId: String
    let role: String?
    let emailId: String?
    let firstName: String?
    let lastName: String?
    let primaryPhoneCtryCd: String?
    let primaryPhone: String?
    let address: String?
    let deleted: Bool
    let userName: String?
    let activeStatus: String?
    let createdBy: String?
    let dronaaimId: String?
    let orgRoleAndScoreMapping: [LSOrgRoleAndScoreMapping]
    let lastLoginAt: String?
    let lastLoginAtDisplay: String?
    let updatedAt: String?
    let updatedBy: String?
    let lonestarId: String?
    let createdAt: String?
    let insurerId: String?
    let licenseId: String?
    let licenseType: String?
    let licenseIssuedState: String?
    let altPhoneCtryCd: String?
    let altPhone: String?
    let notificationTokens: [String]?
    let profilePhoto: LSProfilePhoto?
    let licenseExpiryDate: String?
    let empStartDate: String?
    let dob: String?
    let tenantId: String?
    let signedUrl: String?

    var fullName: String? {
        let parts = [firstName, lastName].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId               = "user_id"
        case initials
        case cognitoId            = "cognito_id"
        case role
        case emailId              = "email_id"
        case firstName            = "first_name"
        case lastName             = "last_name"
        case primaryPhoneCtryCd   = "primary_phone_ctry_cd"
        case primaryPhone         = "primary_phone"
        case address
        case deleted
        case userName             = "user_name"
        case activeStatus         = "active_status"
        case createdBy            = "created_by"
        case dronaaimId           = "dronaaim_id"
        case orgRoleAndScoreMapping = "org_role_and_score_mapping"
        case lastLoginAt          = "last_login_at"
        case lastLoginAtDisplay   = "last_login_at_display"
        case updatedAt            = "updated_at"
        case updatedBy            = "updated_by"
        case lonestarId           = "lonestar_id"
        case createdAt            = "created_at"
        case insurerId            = "insurer_id"
        case licenseId            = "license_id"
        case licenseType          = "license_type"
        case licenseIssuedState   = "license_issued_state"
        case altPhoneCtryCd       = "alt_phone_ctry_cd"
        case altPhone             = "alt_phone"
        case notificationTokens   = "notification_tokens"
        case profilePhoto         = "profile_photo"
        case licenseExpiryDate    = "license_expiry_date"
        case empStartDate         = "emp_start_date"
        case dob
        case tenantId             = "tenant_id"
        case signedUrl            = "signed_url"
    }
}

struct LSOrgRoleAndScoreMapping: Codable {
    let role: String?
    let orgName: String?
    let roleUid: String?
    let meanScore: Double?
    let tripCount: Int?
    let vehicleId: String?
    let lonestarId: String?
    let totalDistance: Double?
    let totalDuration: Int?
    let totalSosCount: Int?
    let totalShockCount: Int?
    let totalDistanceInKms: String?
    let totalIncidentCount: Int?
    let totalDistanceInMiles: String?
    let totalSevereShockCount: Int?
    let totalHarshBrakingCount: Int?
    let totalOverSpeedingCount: Int?
    let totalHarshCorneringCount: Int?
    let totalHardAccelerationCount: Int?
    let policyDetails: [LSPolicyDetail]?
    
}

struct LSPolicyDetail: Codable {
    var isActive = true
    let message: String?
}

struct LSProfilePhoto: Codable {
    let contentType: String?
    let docRef: String?
    let fileName: String?
}
