//
//  LSChangePasswordViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 21/11/24.
//

import UIKit
import Amplify

enum LSTextFieldType {
    case current, new, confirm, verification, email
}
struct LSPasswordField {
    var placeholder: String
    var key: LSTextFieldType
    var value: String
    var isSecure: Bool
    var description: String?
}

class LSChangePasswordViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var confirmSignIn = false
    
    private var passwordFields: [LSPasswordField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Change Password"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80 // Estimate row height
        let currentField = LSPasswordField(placeholder: "Current Password", key: .current ,value: "", isSecure: true)
        let newField =  LSPasswordField(placeholder: "New Password", key: .new , value: "", isSecure: true)
        let confirmField = LSPasswordField(placeholder: "Confirm Password" , key: .confirm , value: "", isSecure: true)
        if confirmSignIn {
            passwordFields = [newField, confirmField]
        } else {
            passwordFields = [currentField, newField, confirmField]
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func changePasswordAction(_ sender: Any) {
        // Find the password fields based on their placeholder
        let currentPW = passwordFields.first(where: { $0.key == .current })
        guard let newPW = passwordFields.first(where: { $0.key == .new }),
              let confirmPW = passwordFields.first(where: { $0.key == .confirm }) else {
            return
        }
        
        // If not in confirmSignIn state, check the current password
        if !confirmSignIn {
            guard !(currentPW?.value.isEmpty ?? true) else {
                UIAlertController.showError(on: self, message: "Current password should be at least 8 characters.")
                return
            }
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

        
        // Proceed with the appropriate action based on confirmSignIn state
        if confirmSignIn {
            confirmSignIn(with: newPW.value)
        } else {
            changePassword(with: currentPW?.value ?? "", newPassword: newPW.value)
        }
    }
    
    // MARK: - Private Methods
    private func confirmSignIn(with newPassword: String) {
        LSProgress.show(in: self.view)
        Task {
            do {
                try await LSNetworkManager.shared.signoutUser()
                if let _ = try await LSNetworkManager.shared.confirmSignIn(password: newPassword) {
                    LSProgress.hide(from: self.view)
                    try await LSNetworkManager.shared.signoutUser()
                    UIAlertController.showActionMessage(on: self, message: "Your password has been successfully changed.", action: "Login") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }  catch let error {
                if let authError = error as? AuthError {
                    UIAlertController.showError(on: self, message: authError.errorDescription)
                } else {
                    UIAlertController.showError(on: self, message: error.localizedDescription)
                }
                LSProgress.hide(from: self.view)
            }
        }
    }
    
    private func changePassword(with oldPassword: String, newPassword: String) {
        LSProgress.show(in: self.view)
        Task {
            do {
                try await LSNetworkManager.shared.changePassword(oldPassword: oldPassword, newPassword: newPassword)
                    LSProgress.hide(from: self.view)
                    UIAlertController.showActionMessage(on: self, message: "Your password has been successfully changed.") {
                        self.navigationController?.popViewController(animated: true)
                    }
            }  catch let error {
                if let authError = error as? AuthError {
                    UIAlertController.showError(on: self, message: authError.errorDescription)
                } else {
                    UIAlertController.showError(on: self, message: error.localizedDescription)
                }
                LSProgress.hide(from: self.view)
            }
        }
    }

}

// MARK: - TableView Datasource
extension LSChangePasswordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwordFields.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

            // Optionally, reload the row if you need to ensure the UI is updated
            // tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        return cell
    }

      
}

class LSPasswordCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var titlelabel: UILabel!

    var textChanged: ((String) -> Void)?
    var eyeButtonAction: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        textChanged?(textField.text ?? "")
    }
    
    @IBAction func toggleSecureEntry(_ sender: UIButton) {
        eyeButtonAction?(sender.tag)

    }
}


class LSEmailCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titlelabel: UILabel!

    var textChanged: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        textChanged?(textField.text ?? "")
    }
}
