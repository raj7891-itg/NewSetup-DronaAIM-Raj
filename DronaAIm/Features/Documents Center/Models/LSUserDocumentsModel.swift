//
//  LSUserDocumentsModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 10/10/24.
//

import Foundation

// MARK: - LSUserDocumentsModel
struct LSUserDocumentsModel: Codable {
    let userDocuments: [UserDocument]
}

// MARK: - UserDocument
struct UserDocument: Codable {
    let userID, fileName, fileSizeInKB, contentType: String?
    let documentType, docRef, uploadedAtTs, status: String?
    let signedURL: String?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case fileName
        case fileSizeInKB = "fileSizeInKb"
        case contentType, documentType, docRef, uploadedAtTs, status
        case signedURL = "signedUrl"
    }
}
