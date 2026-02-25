//
//  LSDProfileEditViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/8/24.
//

import UIKit
import MobileCoreServices
import SDWebImage

class LSDProfileEditViewController: UITableViewController {
    
    // MARK: - Properties
    var imageUrl: URL?
    // MARK: - IBOutlets for header
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    
    // MARK: - IBOutlets for cells
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var countryCodeButton: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    private var croppingImageSource: UIImage?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 1
        }
        setupUI()
        loadUserData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Navigation bar setup
        navigationItem.title = "Edit Profile"
        
        
        // Profile image setup
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        // Add tap gesture to profileImageView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
        // Camera button setup
        cameraButton.layer.cornerRadius = cameraButton.frame.width / 2
        cameraButton.backgroundColor = .white
        cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        cameraButton.tintColor = .app
        
        // Text field setup
        setupTextFields()
        
        // Country code button setup
        countryCodeButton.setTitle("(+1)", for: .normal)
        countryCodeButton.setTitleColor(.black, for: .normal)
        countryCodeButton.layer.cornerRadius = 8
        countryCodeButton.layer.borderColor = UIColor.systemGray6.cgColor
        countryCodeButton.layer.borderWidth = 1
    }
    
    private func setupTextFields() {
        let textFields = [
            firstNameTextField,
            lastNameTextField,
            emailTextField,
            phoneNumberTextField
        ]
        
        for textField in textFields {
            textField?.paddingLeft(8)
            textField?.paddingRight(8)
        }
    }
    
    private func loadUserData() {
        let userDetails = UserDefaults.standard.userDetails
            // Load profile image - for now use placeholder
            if let signedUrl = userDetails?.signedUrl,
               !signedUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let url = URL(string: signedUrl) {
                cameraButton.isEnabled = false
                self.imageUrl = url
                profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                profileImageView
                    .sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle.fill")) { _, _, _, _ in
                        self.cameraButton.isEnabled = true
                    }
            } else {
                profileImageView.image = UIImage(systemName: "person.circle.fill")
            }
            
            // Load name
            let fullName = userDetails?.fullName ?? ""
            let nameComponents = fullName.components(separatedBy: " ")
            firstNameTextField.text = nameComponents.first ?? ""
            lastNameTextField.text = nameComponents.count > 1 ? nameComponents.dropFirst().joined(separator: " ") : ""
            
            // Load email
            emailTextField.text = userDetails?.emailId ?? ""
            
            // Load phone
            if let phoneExt = userDetails?.primaryPhoneCtryCd {
                countryCodeButton.setTitle("(\(phoneExt))", for: .normal)
            }
            phoneNumberTextField.text = userDetails?.primaryPhone ?? ""
        }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Validate and save profile data
        guard validateForm() else { return }
        guard let userId = UserDefaults.standard.userDetails?.userId else { return }
        let countryCode = countryCodeButton.titleLabel?.text?.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "") ?? ""
        guard !countryCode.isEmpty else { return }
        guard let phoneNumber = phoneNumberTextField.text else { return }
        
        let request = TMProfileDetailsRequest(
            primaryPhoneCtryCd: countryCode,
            primaryPhone: phoneNumber,
            userId: userId
        )

        Task {
            do {
                LSProgress.show(in: view, message: "Saving...")
                try await LSDProfileHandler.shared.updateProfileDetails(
                    request: request
                )
                try await LSDProfileHandler.shared.fetchUserDetails()
                LSProgress.hide(from: self.view)
            } catch {
                LSProgress.hide(from: self.view)
                UIAlertController.showError(on: self, message: String(error.localizedDescription))
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func profileImageTapped(_ sender: UITapGestureRecognizer) {
        guard let userDetails = UserDefaults.standard.userDetails else {
            showProfileImageEditor()
            return
        }

        if let signedUrl = userDetails.signedUrl, !signedUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let url = URL(string: signedUrl) {
            let previewVC = LSDPreviewViewController()
            previewVC.delegate = self
            previewVC.image = profileImageView.image
            navigationController?.pushViewController(previewVC, animated: true)
        } else {
            showProfileImageEditor()

        }
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        showProfileImageEditor()
    }
    
    @IBAction func countryCodeButtonTapped(_ sender: UIButton) {
        // Show country code picker
        showCountryCodePicker()
    }
    
    // MARK: - Validation
    private func validateForm() -> Bool {
        let phone = phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
     
        if phone.count < 10 {
            UIAlertController.showError(on: self, message: "Please enter a valid phone number")
            return false
        }
        
        return true
    }

   
    // MARK: - Country Code Picker
    private func showCountryCodePicker() {
        // Simple country code picker - you can enhance this with a proper picker
        let alert = UIAlertController(title: "Select Country Code", message: nil, preferredStyle: .actionSheet)
        
        let countryCodes = ["+1", "+44", "+91"]
        
        for code in countryCodes {
            let action = UIAlertAction(title: code, style: .default) { [weak self] _ in
                self?.countryCodeButton.setTitle("(\(code))", for: .normal)
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Profile Image Editor
    private func showProfileImageEditor() {
        let imagePickerVC = LSDProfileImagePickerViewController()
        imagePickerVC.delegate = self
        imagePickerVC.currentImage = profileImageView.image != UIImage(systemName: "person.circle.fill") ? profileImageView.image : nil
        imagePickerVC.modalPresentationStyle = .overFullScreen
        present(imagePickerVC, animated: true)
    }
    
    
}
// MARK: - LSDProfileImagePickerDelegate
extension LSDProfileEditViewController: LSDProfileImagePickerDelegate, LSDPreviewViewDelegate {
    func didSelectImage(_ url: URL?) {
        guard let url = url else { return }
            Task {
                do {
                    LSProgress.show(in: self.view, message: "uploading...")
                    try await LSDProfileHandler.shared.uploadProfileFile(fileUrl: url, documentType: "profilePic")
                    profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle.fill"))

                    try await LSDProfileHandler.shared.fetchUserDetails()
                    LSProgress.hide(from: self.view)
                } catch {
                    LSProgress.hide(from: self.view)
                    UIAlertController.showError(on: self, message: String(error.localizedDescription))
                }
            }
    }
    
    func didDeleteProfileImage() {
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        Task {
            do {
                LSProgress.show(in: view)
                try await LSDProfileHandler.shared.deleteProfileImage()
                try await LSDProfileHandler.shared.fetchUserDetails()
                LSProgress.hide(from: self.view)
            } catch {
                LSProgress.hide(from: self.view)
                UIAlertController.showError(on: self, message: String(error.localizedDescription))
            }
        }
    }
    
}

extension UITextField {
    func paddingLeft(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func paddingRight(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}


