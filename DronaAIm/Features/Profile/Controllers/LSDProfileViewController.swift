//
//  LSDProfileViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/8/24.
//

import UIKit
import MobileCoreServices
import SDWebImage

class LSDProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var options = [LSDProfileModel]()
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailIdLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    var userDocuments = [UserDocument]()
    private var croppingImageSource: UIImage?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
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


        setupNavigationBar()
        loadUserData()
        setupNotificationObserver()
        options = [
            LSDProfileModel(title: "Change Organization", thumbnail: UIImage(named: "org")!),
            LSDProfileModel(title: "Document Center", thumbnail: UIImage(named: "profile_documentCenter")!),
            LSDProfileModel(title: "Change Password", thumbnail: UIImage(named: "profile_documentCenter")!)]
        self.tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
    }
    
    private func loadUserData() {
        if let userDetails = UserDefaults.standard.userDetails {
            if let emailId = userDetails.emailId {
                emailIdLabel.text = "Email ID: \(emailId)"
            } else {
                emailIdLabel.text = "Email ID: NA"
            }
            nameLabel.text = userDetails.fullName
            if let phoneExt = userDetails.primaryPhoneCtryCd, let phone = userDetails.primaryPhone {
                phoneNumberLabel.text = "Phone No : \(phoneExt) \(phone)"
            } else {
                phoneNumberLabel.text = "Phone No : NA"
            }
            
            // Load profile image - for now use placeholder
            if let signedUrl = userDetails.signedUrl,
               !signedUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let url = URL(string: signedUrl) {
                print("Profile Image = ", url)
                cameraButton.isEnabled = false
                profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                profileImageView
                    .sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle.fill")) { _, _, _, _ in
                        self.cameraButton.isEnabled = true
                    }

            }
            else {
                profileImageView.image = UIImage(systemName: "person.circle.fill")
            }
            
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(profileUpdated),
            name: NSNotification.Name("ProfileUpdated"),
            object: nil
        )
    }
    
    @objc private func profileUpdated() {
        loadUserData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Profile"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editProfileTapped)
        )
    }
    
    @objc private func editProfileTapped() {
        let editProfileVC = LSDProfileEditViewController.instantiate(fromStoryboard: .driver)
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    func redirectToLogin() {
        let loginVC = LoginViewController.instantiate(fromStoryboard: .main)
        let navigationController = UINavigationController(rootViewController: loginVC)
        if let window = UIApplication.shared.keyWindow {
               window.rootViewController = navigationController
               UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
           }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        Task {
            do {
                try await LSNetworkManager.shared.signoutUser()
                redirectToLogin()
            } catch {
                UIAlertController.showError(on: self, message: String(error.localizedDescription))
            }
        }
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
    
    // MARK: - Profile Image Editor
    private func showProfileImageEditor() {
        let imagePickerVC = LSDProfileImagePickerViewController()
        imagePickerVC.delegate = self
        imagePickerVC.currentImage = profileImageView.image != UIImage(systemName: "person.circle.fill") ? profileImageView.image : nil
        imagePickerVC.modalPresentationStyle = .overFullScreen
        present(imagePickerVC, animated: true)
    }
    
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension LSDProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSDProfileTableViewCell", for: indexPath) as! LSDProfileTableViewCell
        let model = options[indexPath.row]
        cell.config(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 0 {
            let organizationsVC = LSOrganizationsListViewController.instantiate(fromStoryboard: .driver)
            self.navigationController?.pushViewController(organizationsVC, animated: true)
        } else if indexPath.row == 1 {
            let notificationsVC = LSDocumentsViewController.instantiate(fromStoryboard: .driver)
            self.navigationController?.pushViewController(notificationsVC, animated: true)
        } else if indexPath.row == 2 {
            let supportVC = LSChangePasswordViewController.instantiate(fromStoryboard: .driver)
            self.navigationController?.pushViewController(supportVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
        
}
// MARK: - LSDProfileImagePickerDelegate
extension LSDProfileViewController: LSDProfileImagePickerDelegate, LSDPreviewViewDelegate {
    func didSelectImage(_ url: URL?) {
        guard let url = url else { return }
//        self.presentQCropper(with: image)
            Task {
                do {
                    LSProgress.show(in: self.view, message: "uploading...")
                    try await LSDProfileHandler.shared.uploadProfileFile(fileUrl: url, documentType: "profilePic")
                    profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle.fill"))

                    try await LSDProfileHandler.shared.fetchUserDetails()
                    profileImageView.sd_setImage(with: url)
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
