//
//  LSTrainingCertificateModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 7/19/24.
//

import Foundation
struct LSTrainingCertificateModel: Identifiable {
    let id = UUID()
    let title: String
    let size: String
    let issueDate: String
    let fileUrl: URL
}
