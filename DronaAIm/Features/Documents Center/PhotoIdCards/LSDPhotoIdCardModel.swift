//
//  LSDPhotoIdCardModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 29/06/24.
//

import Foundation

struct LSDPhotoIdCardModel {
    let fileUrl: URL
    let fileName: String
    let size: String
    let fileType: DocumentFileType
}

enum DocumentFileType {
    case pdf
    case png
    case jpg
    case jpeg
}
