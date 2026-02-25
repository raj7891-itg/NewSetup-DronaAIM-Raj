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
    let userId: String
    let cognitoId: String
    let emailId: String?
    let fullName: String?
    let firstName: String?
    let lastName: String?
    let primaryPhone: String?
    let primaryPhoneCtryCd: String?
    let deleted: Bool
    let signedUrl: String?
    let orgRoleAndScoreMapping: [LSOrgRoleAndScoreMapping]
    let profilePhoto: LSProfilePhoto?
}

struct LSOrgRoleAndScoreMapping: Codable {
    let lonestarId: String?
    let role: String?
    let name: String?
    let insurerId: String?
    let meanScore: Double?
    let dronaaimId: String?
    let policyDetails: [LSPolicyDetail]
}

struct LSProfilePhoto: Codable {
    let contentType: String?
    let docRef: String?
    let fileName: String?
}

struct LSPolicyDetail: Codable {
    let isActive: Bool
    let message: String
}

