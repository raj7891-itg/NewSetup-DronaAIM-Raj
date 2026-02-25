//  LSDProfileHandler.swift
//  DronaAIm
//
//  Created by Assistant on 8/20/25.
//

import Foundation
import UIKit

struct TMProfileDetailsRequest: Codable {
    let primaryPhoneCtryCd: String
    let primaryPhone: String
    let userId: String
}

final class LSDProfileHandler {
    static let shared = LSDProfileHandler()
    private init() {}

    func updateProfileDetails(request: TMProfileDetailsRequest) async throws {
        let endpoint = LSAPIEndpoints.updateProfileDetails(for: request.userId)
        let _: LSSuccess = try await LSNetworkManager.shared.post(endpoint, body: request)
    }

    func uploadProfileFile(fileUrl: URL, documentType: String) async throws {
        let _ = try await LSNetworkManager.shared.uploadFileToS3(
            from: fileUrl,
            documentType: documentType,
            documentSource: .profile
        )
    }

    func deleteProfileImage() async throws {
        guard let userId = UserDefaults.standard.userDetails?.userId else { return }
        guard let docRef = UserDefaults.standard.userDetails?.profilePhoto?.docRef else {
            return
        }
        let endpoint = LSAPIEndpoints.deleteProfileImage(for: userId, docRef: docRef)
        let _: LSSuccess = try await LSNetworkManager.shared.delete(endpoint)
    }

    func fetchUserDetails() async throws -> LSUserDetailsModel {
        let currentUser = try await LSNetworkManager.shared.currentUser()
        let userId = currentUser.userId
        let endpoint = LSAPIEndpoints.userDetails(for: userId)
        let userDetails: LSUserDetailsModel = try await LSNetworkManager.shared.get(endpoint, apiType: .analytics)
        UserDefaults.standard.userDetails = userDetails
        return userDetails
    }
}
