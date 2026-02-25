//
//  LSDPreviewViewController.swift
//  DronaAIm
//
//  Displays a preview of profile images/documents for review and editing.
//  Allows users to view, edit, or delete profile images.
//

import UIKit
protocol LSDPreviewViewDelegate: AnyObject {
    func didSelectImage(_ url: URL?) 
    func didDeleteProfileImage()
}

class LSDPreviewViewController: UIViewController {
    // MARK: - Properties
    var image: UIImage?
    weak var delegate: LSDPreviewViewDelegate?

    
    // MARK: - UI Elements
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupImageView()
        imageView.image = image
    }
    
    // MARK: - UI Setup
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.title = "Preview"
    }
    
    private func setupImageView() {
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func editButtonTapped() {
        // Perform edit action (to be implemented or delegated)
        showProfileImageEditor()
    }
    
    // MARK: - Profile Image Editor
    private func showProfileImageEditor() {
        let imagePickerVC = LSDProfileImagePickerViewController()
        imagePickerVC.delegate = self
        imagePickerVC.currentImage = image
        
        imagePickerVC.modalPresentationStyle = .overFullScreen
        present(imagePickerVC, animated: true)
    }

}

// MARK: - LSDProfileImagePickerDelegate
extension LSDPreviewViewController: LSDProfileImagePickerDelegate {
    func didSelectImage(_ url: URL?) {
        guard let url = url else { return }
        self.delegate?.didSelectImage(url)
        self.navigationController?.popViewController(animated: true)
    }
    
    func didDeleteProfileImage() {
        self.delegate?.didDeleteProfileImage()
        self.navigationController?.popViewController(animated: false)

    }
    
}

