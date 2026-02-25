//
//  LSDocumentModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 29/06/24.
//

import Foundation

enum IDCardType: String {
    case photoId = "PhotoID"
    case drivingLicence = "DrivingLicense"
    case trainingCertificate
    case signature = "Signature"
    case other = "Other"
}

struct LSDocumentModel {
    let title: String
}

struct LSDocumentPreSignedModel: Decodable {
    let putUrl: String
    let docRef: String
}
