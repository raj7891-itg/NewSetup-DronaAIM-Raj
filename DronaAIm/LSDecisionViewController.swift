//
//  LSDecisionViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/24/24.
//

import UIKit

class LSDecisionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            if let selectedOrganization = UserDefaults.standard.selectedOrganization {
                redirectToRelevantScreen()
            } else {
                redirectToLogin()
            }
        }
    }
    
    // MARK: - Navigation Methods
    
    /// Determines and redirects to the appropriate screen based on user state
    func redirectToRelevantScreen() {
            Task {
                do {
                    let currentUser = try await LSNetworkManager.shared.currentUser()
                        let userId = currentUser.userId
                        let endpoint = LSAPIEndpoints.userDetails(for: userId)
                        let userDetails: LSUserDetailsModel = try await LSNetworkManager.shared.get(endpoint, apiType: .analytics)
                        UserDefaults.standard.userDetails = userDetails

                    redirectToHome()
                    requestPushNotificationPermission()
                } catch {
                    redirectToLogin()
                }
            }
        }

    /// Redirects to the Login screen
    func redirectToLogin() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        let loginVC = LoginViewController.instantiate(fromStoryboard: .main)
        let navigationController = UINavigationController(rootViewController: loginVC)
        if let window = UIApplication.shared.keyWindow {
            window.rootViewController = navigationController
        }
    }

    /// Redirects to the Home screen (TabBar)
    func redirectToHome() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        let tabbarController = LSTabbarController.instantiate(fromStoryboard: .driver)
        let navigationController = UINavigationController(rootViewController: tabbarController)
        if let window = UIApplication.shared.keyWindow {
            window.rootViewController = navigationController
        }
    }
    
    // MARK: - Notification Permission
    
    /// Requests push notification permission from the user
    func requestPushNotificationPermission() {
        UNUserNotificationCenter.requestPushNotificationPermission()
    }
    
    
}
