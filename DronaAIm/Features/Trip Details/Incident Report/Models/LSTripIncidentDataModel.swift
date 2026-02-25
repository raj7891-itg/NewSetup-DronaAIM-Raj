//
//  LSTripIncidentDataModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 26/06/24.
//

import Foundation
import UIKit

struct Video {
    let title: String
    let thumbnail: UIImage
    let type: String
}

struct IncidentReport {
    let title: String
    let date: String
    let address: String
    let acknowledgedDate: String
    let videos: [Video]
}
