//
//  LSVerificationCodeViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 21/11/24.
//

import UIKit
import Amplify

class LSVerificationCodeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var passwordFields: [LSPasswordField] = []
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Change Password"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80 // Estimate row height
        let emailField = LSPasswordField(placeholder: "Email", key: .email ,value: email ?? "", isSecure: false)
        let verificationField = LSPasswordField(placeholder: "Verification code", key: .verification ,value: "", isSecure: false)
        let newField =  LSPasswordField(placeholder: "New Password", key: .new , value: "", isSecure: true)
        let confirmField = LSPasswordField(placeholder: "Confirm Password" , key: .confirm , value: "", isSecure: true)
            passwordFields = [emailField, verificationField, newField, confirmField]
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func confirmAction(_ sender: Any) {
        // Find the password fields based on their placeholder
        guard let emailField = passwordFields.first(where: { $0.key == .email }),
              let verificationField = passwordFields.first(where: { $0.key == .verification }),
              let newPW = passwordFields.first(where: { $0.key == .new }),
              let confirmPW = passwordFields.first(where: { $0.key == .confirm }) else {
            return
        }
        
        // If not in confirmSignIn state, check the current password
        guard emailField.value.isValidEmail() else {
            UIAlertController.showError(on: self, message: "Please enter valid emailId.")
                return
            }
        
        guard !verificationField.value.isEmpty else {
            UIAlertController.showError(on: self, message: "Verification field should not be empty.")
                return
            }
        
        // Check that new password and confirm password are not empty
        guard !newPW.value.isEmpty, newPW.value.count >= 8 else {
            UIAlertController.showError(on: self, message: "New password should be at least 8 characters.")
            return
        }
        
        guard !confirmPW.value.isEmpty, confirmPW.value.count >= 8 else {
            UIAlertController.showError(on: self, message: "Confirm password should be at least 8 characters.")
            return
        }
        
        // Validate new password
        if !newPW.value.isValidPassword {
            UIAlertController.showError(on: self, message: "Password must be at least 8 characters long, contain one uppercase letter, one lowercase letter, one number, and one special character.")
            return
        }
        
        // Ensure that the new password and confirm password match
        guard newPW.value == confirmPW.value else {
            UIAlertController.showError(on: self, message: "New and Confirm password should be the same.")
            return
        }
        changePassword(with: emailField.value, code: verificationField.value, newPassword: newPW.value)
        
    }
    
    // MARK: - Private Methods
    private func changePassword(with email: String, code: String, newPassword: String) {
        LSProgress.show(in: self.view)
        Task {
            do {
                try await LSNetworkManager.shared.confirmForgotPassword(
                    username: email,
                    newPassword: newPassword,
                    confirmationCode: code
                )
                UIAlertController.showActionMessage(on: self, message: "Your password has been successfully changed.", action: "Login") {
                    if let first = self.navigationController?.viewControllers.first as? LoginViewController {
                        self.navigationController?.viewControllers = [first]
                    }
                }
            } catch let error {
                if let authError = error as? AuthError {
                    UIAlertController.showError(on: self, message: authError.errorDescription)
                }
                UIAlertController.showError(on: self, message: error.localizedDescription)
                LSProgress.hide(from: self.view)
            }
        }
    }
    
}

// MARK: - TableView Datasource
extension LSVerificationCodeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwordFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let passwordField = passwordFields[indexPath.row]
        if passwordField.key == .new || passwordField.key == .confirm {
            return self.tableView(tableView, passwordCellForRowAt: indexPath)
        } else if passwordField.key == .email || passwordField.key == .verification{
            return self.tableView(tableView, emailCellForRowAt: indexPath)
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, emailCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LSEmailCell", for: indexPath) as! LSEmailCell
        let passwordField = passwordFields[indexPath.row]
        cell.titlelabel.text = passwordField.placeholder
        cell.textField.placeholder = passwordField.placeholder
        cell.textField.text = passwordField.value
        // Handle text changes
        cell.textChanged = { [weak self] text in
            self?.passwordFields[indexPath.row].value = text
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, passwordCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LSPasswordCell", for: indexPath) as! LSPasswordCell
        let passwordField = passwordFields[indexPath.row]
        cell.titlelabel.text = passwordField.placeholder
        cell.textField.placeholder = passwordField.placeholder
        cell.textField.text = passwordField.value
        cell.textField.isSecureTextEntry = passwordField.isSecure
        cell.eyeButton.tag = indexPath.row
        
        // Set the correct eye icon based on isSelected
        let eyeIcon = cell.eyeButton.isSelected ? UIImage(systemName: "eye.fill") : UIImage(systemName: "eye")
        cell.eyeButton.setImage(eyeIcon, for: .normal)
        
        // Handle text changes
        cell.textChanged = { [weak self] text in
            self?.passwordFields[indexPath.row].value = text
        }

        // Handle eye icon toggle
        cell.eyeButtonAction = { [weak self] tag in
            guard let self = self else { return }
            // Toggle the isSelected state of the eyeButton
            cell.eyeButton.isSelected.toggle()
            
            // Update the isSecureTextEntry based on the isSelected state
            self.passwordFields[tag].isSecure = !cell.eyeButton.isSelected
            
            // Set the eye icon according to the isSelected state
            let updatedIcon = cell.eyeButton.isSelected ? UIImage(systemName: "eye.fill") : UIImage(systemName: "eye")
            cell.eyeButton.setImage(updatedIcon, for: .normal)
            cell.textField.isSecureTextEntry = !cell.eyeButton.isSelected
        }
        return cell
    }

}
