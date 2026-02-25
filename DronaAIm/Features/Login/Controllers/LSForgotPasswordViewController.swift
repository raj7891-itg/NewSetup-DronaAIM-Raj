//
//  LSForgotPasswordViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 21/11/24.
//

import UIKit
import Amplify

class LSForgotPasswordViewController: UITableViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Forgot Password"
        
    }
    
    @IBAction func submitAction(_ sender: Any) {
        if let email = emailTextField.text, !email.isValidEmail() {
            UIAlertController.showActionMessage(on: self, message: "Please enter valid email")
            return
        }
        LSProgress.show(in: self.view)
        Task {
            do {
                if let email = emailTextField.text {
                    let result = try await LSNetworkManager.shared.forgotPassword(for: email)
                    switch result.nextStep {
                    case .confirmResetPasswordWithCode(_, _):
                        UIAlertController.showActionMessage(on: self, message: "Confirmation code sent to your email") {
                            // navigate to Confirmation Page
                            let verificationVC = LSVerificationCodeViewController.instantiate(fromStoryboard: .driver)
                            verificationVC.email = self.emailTextField.text
                            self.navigationController?.pushViewController(verificationVC, animated: true)
                            LSProgress.hide(from: self.view)
                        }
                    default:
                        print("")
                        LSProgress.hide(from: self.view)
                    }
                }
                LSProgress.hide(from: self.view)
            } catch let error {
                if let authError = error as? AuthError {
                    UIAlertController.showActionMessage(on: self, message: authError.errorDescription)
                } else {
                    UIAlertController.showActionMessage(on: self, message: error.localizedDescription)
                }
                LSProgress.hide(from: self.view)
            }
        }
    }
}
