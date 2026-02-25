//
//  UNUserNotificationCenter_Extention.swift
//  DronaAIm
//
//  Extension for UNUserNotificationCenter to handle push notification permissions
//

import Foundation
import UserNotifications
import UIKit

extension UNUserNotificationCenter {
    
    /// Requests push notification permission from the user
    /// - Parameter completion: Optional completion handler called with the authorization result
    static func requestPushNotificationPermission(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    // Register for remote notifications if permission is granted
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    // Handle the case when permission is denied
                    if let error = error {
                        print("Failed to request authorization: \(error.localizedDescription)")
                    }
                }
                completion?(granted)
            }
        }
        
        // Set the delegate for handling notification-related events
        UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
    }
}

