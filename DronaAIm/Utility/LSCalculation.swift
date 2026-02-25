//
//  LSCalculation.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/23/24.
//

import Foundation

class LSCalculation {
    static let shared = LSCalculation()

    func distance(from kilometers: Double) -> String {
        let miles = kilometers * 0.621371
        let milesFormat = doubleFormatTwoChars(score: miles)
        return milesFormat
    }
    
    func duration(from milliseconds: Int) -> (hours: Int, minutes: Int) {
        let totalSeconds = milliseconds / 1000
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        return (hours, minutes)
    }
    
    func doubleFormatTwoChars(score: Double) -> String {
        if score == floor(score) {
            return String(format: "%.0f", score) // No decimal places for whole numbers
        } else {
            return String(format: "%.2f", score) // One decimal place for other numbers
        }

    }

    
    func doubleFormat(score: Double) -> String {
        if score == floor(score) {
            return String(format: "%.0f", score) // No decimal places for whole numbers
        } else {
            return String(format: "%.1f", score) // One decimal place for other numbers
        }

    }


}
