//
//  LSConstants.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/21/24.
//

import Foundation
import UIKit
import SwiftUI

struct LSEventInfo {
    var title: String
    var icon: UIImage
}

func getEventinfo(for eventType: LSDAllEventType?) -> LSEventInfo? {
    guard let iconName = eventType?.rawValue else { return nil }
    let icon = "event.\(iconName)"
    LSLogger.debug("Event icon name: \(icon)")
    if eventType == .accelerate {
        return LSEventInfo(title: "Harsh Acceleration", icon: UIImage(named: icon) ?? UIImage())
    } else if eventType == .brake {
        return LSEventInfo(title: "Harsh Braking", icon: UIImage(named: icon) ?? UIImage())
    } else if eventType == .turn {
        return LSEventInfo(title: "Harsh Cornering", icon: UIImage(named: icon) ?? UIImage())
    } else if eventType == .speed {
        return LSEventInfo(title: "Speeding", icon: UIImage(named: icon) ?? UIImage())
    } else if eventType == .shock {
        return LSEventInfo(title: "Impact", icon: UIImage(named: icon) ?? UIImage())
    } else if eventType == .severeShock {
        return LSEventInfo(title: "Severe Impact", icon: UIImage(named: icon) ?? UIImage())
    } else if eventType == .panicButton {
        return LSEventInfo(title: "SOS", icon: UIImage(named: icon) ?? UIImage())
    }

    return nil
}

func getIncidentType(eventType: LSDAllEventType?) -> String {
    if eventType == .accelerate {
        return "Harsh Acceleration"
    } else if eventType == .brake {
        return "Harsh Braking"
    } else if eventType == .turn {
        return "Harsh Cornering"
    } else if eventType == .speed {
        return "Speeding"
    } else if eventType == .shock {
        return "Impact"
    } else if eventType == .severeShock {
        return "Severe Impact"
    } else if eventType == .panicButton {
        return "SOS"
    }
    return ""
}

func getEventTypeString(eventType: String) -> String {
    if eventType == "Harsh Acceleration" {
        return LSDAllEventType.accelerate.rawValue
    } else if eventType == "Harsh Braking" {
        return LSDAllEventType.brake.rawValue
    } else if eventType == "Harsh Cornering" {
        return LSDAllEventType.turn.rawValue
    } else if eventType == "Speeding" {
        return LSDAllEventType.speed.rawValue
    } else if eventType == "Impact" {
        return LSDAllEventType.shock.rawValue
    } else if eventType == "Severe Impact" {
        return LSDAllEventType.severeShock.rawValue
    } else if eventType == "SOS" {
        return LSDAllEventType.panicButton.rawValue
    }
    return ""
}

func getIncidentTypeColor(eventType: LSDAllEventType?) -> Color {
    if eventType == .accelerate {
        return Color.appYellow
    } else if eventType == .brake {
        return Color.appHarsh
    } else if eventType == .turn {
        return Color.appRed
    } else if eventType == .speed {
        return Color.appGreen
    } else if eventType == .shock {
        return Color.appPurple
    } else if eventType == .severeShock {
        return Color.appShock
    } else if eventType == .panicButton {
        return Color.accent
    }
    return Color.gray
}

 func safetyTip(for eventType: LSDAllEventType) -> String {
    switch eventType {
    case .accelerate:
        return "To enhance safety and vehicle longevity, it is essential to avoid harsh acceleration. Smooth acceleration improves vehicle control and minimizes strain on the engine and tires. By anticipating traffic conditions and adjusting speed gradually, drivers can ensure safer and more efficient operation of their vehicles."
    case .brake:
        return "Maintain a safe following distance and anticipate stops to minimize the need for harsh braking. By keeping enough space between your vehicle and the one ahead, you have more time to react and decelerate smoothly. Pay attention to traffic signals, road signs, and the movement of other vehicles to anticipate stops and slow down gradually. This approach helps you avoid sudden, harsh braking, which improves vehicle control and passenger comfort."
    case .turn:
        return "Reduce your speed before entering a corner and maintain a steady, controlled speed throughout. Harsh cornering increases the risk of losing control, especially if you approach too quickly or make abrupt steering adjustments. By slowing down beforehand and taking the turn smoothly, you enhance your vehicle’s grip on the road and reduce the likelihood of skidding or losing control."
    case .speed:
        return "Always adhere to posted speed limits and adjust your speed according to road conditions. Speed limits are designed to keep everyone safe, taking into account factors like road layout, traffic density, and local regulations. If conditions are poor, such as during rain, fog, or heavy traffic, reduce your speed accordingly to maintain control and increase reaction time. Remember, driving safely means prioritizing caution over speed."
    case .shock:
        return "Regularly inspect and maintain your vehicle’s suspension system and tires. Ensuring that your suspension system and tires are in good condition can help absorb impacts more effectively and reduce the likelihood of experiencing a shock event. Check your tire pressure regularly, look for signs of wear, and have your suspension system inspected by a professional to ensure it’s functioning properly. Proper maintenance helps improve your vehicle’s stability and comfort, making it less susceptible to sudden jolts or impacts."
    case .severeShock:
        return "Drive cautiously and adjust your speed to road conditions. Avoid high speeds and be vigilant about road hazards such as potholes, uneven surfaces, or debris. By reducing your speed and approaching potentially hazardous areas with care, you minimize the impact of sudden jolts and protect your vehicle’s suspension system and tires. Additionally, stay alert and maintain a safe following distance to give yourself ample time to react to unexpected obstacles or changes in the road."
    case .panicButton:
        return ""
    }
}

// MARK: - Application Constants

/// Centralized constants for the application
struct LSConstants {
    // Base struct - all constants are in nested structs via extension
}

extension LSConstants {
    
    /// UI-related constants
    struct UI {
        static let alertTitle = "Alert"
        static let okButton = "OK"
        static let errorTitle = "Error"
        static let unauthorizedUserMessage = "Unauthorized user"
    }
    
    /// File handling constants
    struct File {
        static let maxFileSizeMB: Double = 5.0
        static let imageCompressionQuality: CGFloat = 0.8
    }
    
    /// UserDefaults key constants
    struct UserDefaultsKeys {
        static let username = "username"
        static let password = "password"
        static let lastDeviceToken = "lastDeviceToken"
    }
    
    /// Error domain constants
    struct ErrorDomain {
        static let httpError = "HTTPError"
        static let invalidResponse = "Invalid Response"
        static let networkError = "NetworkError"
    }
    
    /// Common user-facing strings
    struct Strings {
        struct Auth {
            static let unauthorizedUser = "Unauthorized user"
            static let loginFailed = "Login failed. Please try again."
        }
        
        struct Profile {
            static let deleteProfilePicture = "Delete Profile Picture"
            static let confirmDelete = "Are you sure you want to delete your profile picture?"
            static let cancel = "Cancel"
            static let delete = "Delete"
        }
        
        struct Common {
            static let ok = "OK"
            static let cancel = "Cancel"
            static let delete = "Delete"
            static let save = "Save"
            static let edit = "Edit"
            static let done = "Done"
        }
    }
    
    /// API Keys and external service configurations
    struct APIKeys {
        /// Loads SecureKeys.plist from Config folder
        /// Tries bundle first, then Documents directory (for flexibility)
        private static func loadSecureKeys() -> [String: Any]? {
            // Try loading from app bundle (if added to Xcode project)
            // Method 1: Try with directory parameter
            if let bundlePath = Bundle.main.path(forResource: "SecureKeys", ofType: "plist", inDirectory: "Config"),
               let plistData = NSDictionary(contentsOfFile: bundlePath) as? [String: Any] {
                LSLogger.debug("Loaded SecureKeys.plist from bundle (with directory)")
                return plistData
            }
            
            // Method 2: Try direct path in bundle
            if let bundlePath = Bundle.main.path(forResource: "SecureKeys", ofType: "plist"),
               let plistData = NSDictionary(contentsOfFile: bundlePath) as? [String: Any] {
                LSLogger.debug("Loaded SecureKeys.plist from bundle (direct)")
                return plistData
            }
            
            // Method 3: Try loading from Documents/Config directory (for external file management)
            let fileManager = FileManager.default
            if let documentsURL = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                let secureKeysPath = documentsURL.appendingPathComponent("Config/SecureKeys.plist")
                if fileManager.fileExists(atPath: secureKeysPath.path),
                   let plistData = NSDictionary(contentsOf: secureKeysPath) as? [String: Any] {
                    LSLogger.debug("Loaded SecureKeys.plist from Documents directory")
                    return plistData
                }
            }
            
            // Fallback: Try Info.plist for backward compatibility
            if let infoPlist = Bundle.main.infoDictionary {
                LSLogger.debug("Using Info.plist as fallback for SecureKeys")
                return infoPlist
            }
            
            return nil
        }
        
        /// Google Maps SDK API Key
        /// Reads from SecureKeys.plist in Config folder (secure, not committed to git)
        /// Falls back to Info.plist for backward compatibility
        /// Supports environment-specific keys via build configurations
        static var googleMapsAPIKey: String {
            guard let secureKeys = loadSecureKeys() else {
                LSLogger.error("SecureKeys.plist not found in Config folder or Info.plist")
                fatalError("GMSApiKey must be set in Config/SecureKeys.plist or Info.plist")
            }
            
            // Determine which key to use based on build configuration
            #if DEVELOPMENT
            let keyName = "GMSApiKey_Development"
            #elseif QA
            let keyName = "GMSApiKey_QA"
            #elseif PREPROD
            let keyName = "GMSApiKey_PreProd"
            #else
            let keyName = "GMSApiKey"
            #endif
            
            // Try environment-specific key first
            if let envKey = secureKeys[keyName] as? String, !envKey.isEmpty {
                return envKey
            }
            
            // Fallback to default key
            guard let key = secureKeys["GMSApiKey"] as? String, !key.isEmpty else {
                LSLogger.error("GMSApiKey not found in SecureKeys.plist or Info.plist")
                fatalError("GMSApiKey must be set in Config/SecureKeys.plist or Info.plist")
            }
            return key
        }
    }
}
