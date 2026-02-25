//
//  UIAlertController_Extention.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/14/24.
//

import UIKit

extension UIAlertController {
    
    /// Shows an error alert with a user-friendly message
    /// - Parameters:
    ///   - viewController: The view controller to present the alert on
    ///   - message: The error message to display (will be converted to user-friendly if it's an Error)
    static func showError(on viewController: UIViewController, message: String) {
        let alert = UIAlertController(title: LSConstants.UI.alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LSConstants.UI.okButton, style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    /// Shows an error alert from an Error object with automatic user-friendly message conversion
    /// - Parameters:
    ///   - viewController: The view controller to present the alert on
    ///   - error: The error to display
    static func showError(on viewController: UIViewController, error: Error) {
        let userFriendlyMessage = error.userFriendlyMessage
        showError(on: viewController, message: userFriendlyMessage)
    }
    
    static func showActionMessage(on viewController: UIViewController, message: String, actionHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: LSConstants.UI.alertTitle, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: LSConstants.UI.okButton, style: .default) { _ in
            actionHandler?()  // Call the action handler if provided
        }
        
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func showActionMessage(on viewController: UIViewController, message: String, action: String, actionHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: LSConstants.UI.alertTitle, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: action, style: .default) { _ in
            actionHandler?()  // Call the action handler if provided
        }
        
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}
