//
//  LSPushNotificationProcess.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 04/12/24.
//

import Foundation
import UserNotifications
import UIKit

// Singleton class to handle push notifications
class LSPushNotificationProcess: NSObject {
    static let shared = LSPushNotificationProcess()
    private override init() {}
    
    // This will configure the notification delegate
    func config() {
        UNUserNotificationCenter.current().delegate = self
    }
}

// Conform to UNUserNotificationCenterDelegate
extension LSPushNotificationProcess: UNUserNotificationCenterDelegate {
    
    // Handle notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show alert, badge, sound if necessary
        completionHandler([.alert, .badge, .sound])
    }

    // Handle notifications when the user taps on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        do {
            // Convert userInfo to JSON data for easy decoding
            let jsonData = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
            let decoder = JSONDecoder()
            let notification = try decoder.decode(LSPushNotificationModel.self, from: jsonData)
            
            // Check the notification action to navigate
            let topViewController = topViewController()
            if let action = notification.aps?.alert?.actionLocKey, action == "DOCUMENT_SUBMISSION_NOTIFICATION" {
                navigateToDocumentCenter(from: topViewController)
            } else {
                navigateToNotifications(from: topViewController)
            }
            
        } catch {
            print("Error converting userInfo to JSON data: \(error)")
        }
        
        completionHandler()
    }
    
    private func topViewController() -> UIViewController? {
        if let topController = UIApplication.shared.topViewController() {
            // Check if the top view controller is a UINavigationController
            if let navigationController = topController as? UINavigationController {
                // Check if this navigation controller is inside the tab bar controller
                if let tabBarController = navigationController.viewControllers.first as? LSTabbarController {
                    // Access the navigation controller from the active tab
                    if let activeTabNavigationController = tabBarController.selectedViewController as? UINavigationController {
                        // Get the visible view controller from the currently active navigation stack
                        let visibleViewController = activeTabNavigationController.visibleViewController
                        print("Visible View Controller: \(String(describing: visibleViewController))")
                        return visibleViewController
                    }
                }
            }
        }
        return nil
    }
    // Function to navigate to a particular screen
    private func navigateToDocumentCenter(from viewController: UIViewController?) {
        if let topController = viewController {
            let documentCenter = LSDocumentsViewController.instantiate(fromStoryboard: .driver)
            topController.navigationController?.pushViewController(documentCenter, animated: true)
        }
    }
    private func navigateToNotifications(from viewController: UIViewController?) {
        if let topController = viewController {
            let notificationsVC = LSDNotificationsViewController.instantiate(fromStoryboard: .driver)
            notificationsVC.hidesBottomBarWhenPushed = true
            topController.navigationController?.pushViewController(notificationsVC, animated: true)
        }
    }

    
    
}

extension UIApplication {
    
    // Get the topmost view controller in the application
    func topViewController() -> UIViewController? {
        var topController = self.windows.first { $0.isKeyWindow }?.rootViewController
        
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
}
