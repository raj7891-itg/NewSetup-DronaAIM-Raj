//
//  LSNotificationDetailViewModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 16/07/24.
//

import Foundation
class LSNotificationDetailViewModel {
    private var tripDetails: LSNotificationDetailModel?
    
    func fetchTripDetails() {
        // Example data
        tripDetails = LSNotificationDetailModel(
            tripID: "TR12345",
            startLocation: "123 Main St, City, Country",
            endLocation: "XYZ Street, City, Country",
            pickupTime: "10:00 AM, July 12, 2024",
            estimatedDistance: "50 miles",
            estimatedDuration: "1 hour",
            loadType: "General Goods",
            specialInstructions: "Handle with care"
        )
    }
    
    func getTripDetails() -> LSNotificationDetailModel? {
        return tripDetails
    }
}
