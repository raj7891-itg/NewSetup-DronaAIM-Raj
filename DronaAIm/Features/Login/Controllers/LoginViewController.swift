//
//  LoginViewController.swift
//  DronaAIm
//
//  Handles user authentication and login flow.
//  Features:
//  - Username/password login with Amplify Cognito
//  - Remember Me functionality
//  - Forgot Password navigation
//  - Push notification permission request
//

import UIKit
import Amplify
import UserNotifications

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets for the UI components
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var rememberMeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        loginButton.layer.cornerRadius = 10
        // Set the delegate for the text fields
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Load the saved username and password if "Remember Me" is enabled
        if let savedUsername = UserDefaults.standard.string(forKey: "username"),
           let savedPassword = UserDefaults.standard.string(forKey: "password") {
            usernameTextField.text = savedUsername
            passwordTextField.text = savedPassword
            rememberMeButton.isSelected = true
            rememberMeButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        }
        
        // Add gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
       }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {

        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter both username and password.")
            return
        }
        Task {
            LSProgress.show(in: self.view)
            do {
                try await LSNetworkManager.shared.signoutUser()
                let result = try await LSNetworkManager.shared.signIn(username: username, password: password)
                switch result {
                case .changePassword:
                    passwordTextField.text = ""
                    LSProgress.hide(from: self.view)
                    let changePasswordVC = LSChangePasswordViewController.instantiate(fromStoryboard: .driver)
                    changePasswordVC.confirmSignIn = true
                    self.navigationController?.pushViewController(changePasswordVC, animated: true)
                case .signedIn:
                    try await self.continueWithSignedInFlow()
                    rememberMe()
                default:
                    print("")
                }
                requestPushNotificationPermission()
            } catch let error as AuthError {
                print("AESError: \(error.errorDescription)")
                DispatchQueue.main.async {
                    UIAlertController.showError(on: self, message: String(error.errorDescription))
                    LSProgress.hide(from: self.view)
                }
            } catch {
                DispatchQueue.main.async {
                    UIAlertController.showError(on: self, error: error)
                    LSProgress.hide(from: self.view)
                }
            }
        }
    }
    
    // MARK: - Notification Permission
    
    /// Requests push notification permission from the user
    func requestPushNotificationPermission() {
        UNUserNotificationCenter.requestPushNotificationPermission { [weak self] granted in
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
        }
    }
    
    private func continueWithSignedInFlow() async throws {
//        let currentUser = try await LSNetworkManager.shared.currentUser()
//        let userId = currentUser.userId
//
//        // Call Api to fetch User Information
//        let endpoint = LSAPIEndpoints.userDetails(for: userId)
//        let userDetails: LSUserDetailsModel = try await LSNetworkManager.shared.get(endpoint, apiType: .analytics)
//        UserDefaults.standard.userDetails = userDetails
//        LSLogger.debug("User Details: \(userDetails)")
//        UserDefaults.standard.selectedOrganization = nil
//          if userDetails.orgRoleAndScoreMapping.count == 1 {
//            if let org = userDetails.orgRoleAndScoreMapping.first, org.policyDetails.first?.isActive ?? false  {
//                if org.role == "driver" {
//                    UserDefaults.standard.selectedOrganization = org
//                    DispatchQueue.main.async {
//                        let tabbarController = LSTabbarController.instantiate(fromStoryboard: .driver)
//                        let navigationController = UINavigationController(rootViewController: tabbarController)
//                        if let window = UIApplication.shared.keyWindow {
//                            window.rootViewController = navigationController
//                        }
//                    }
//                } else {
//                    UIAlertController.showError(on: self, message: LSConstants.Strings.Auth.unauthorizedUser)
//                }
//                
//            } else if let org = userDetails.orgRoleAndScoreMapping.first, let message = org.policyDetails.first?.message {
//                UIAlertController.showError(on: self, message: message)
//            }
//        }
//        else {
//            let organizationsVC = LSOrganizationsListViewController.instantiate(fromStoryboard: .driver)
//            self.navigationController?.pushViewController(organizationsVC, animated: true)
//        }
//        LSProgress.hide(from: self.view)
        
        let tabbarController = LSTabbarController.instantiate(fromStoryboard: .driver)
        let navigationController = UINavigationController(rootViewController: tabbarController)
        if let window = UIApplication.shared.keyWindow {
            window.rootViewController = navigationController
        }
    }
    
    private func rememberMe() {
        if rememberMeButton.isSelected {
            rememberMeButton.setImage(UIImage(systemName: "square"), for: .normal)
            UserDefaults.standard.set(usernameTextField.text, forKey: "username")
            UserDefaults.standard.set(passwordTextField.text, forKey: "password")
        } else {
            rememberMeButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "password")

        }
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        let forgotPasswordVC = LSForgotPasswordViewController.instantiate(fromStoryboard: .driver)
        self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
    @IBAction func remembermeAction(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            rememberMeButton.setImage(UIImage(systemName: "square"), for: .normal)
        } else {
            sender.isSelected = true
            rememberMeButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        }
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}



// MARK: - UNUserNotificationCenterDelegate methods

extension LoginViewController: UNUserNotificationCenterDelegate {
    
    
    // Handle notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show alert, badge, sound if necessary
        completionHandler([.alert, .badge, .sound])
    }

    // Handle notifications when the user taps on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification response (e.g., navigate to a specific screen)
        let userInfo = response.notification.request.content.userInfo
        print("Notification Info = ", userInfo)
        completionHandler()
    }
}
