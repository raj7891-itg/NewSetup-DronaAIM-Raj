//
//  LSDProfileImagePickerViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/8/24.
//

import UIKit
import PhotosUI

protocol LSDProfileImagePickerDelegate: AnyObject {
    func didSelectImage(_ url: URL?)
    func didDeleteProfileImage()
}

class LSDProfileImagePickerViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: LSDProfileImagePickerDelegate?
    var currentImage: UIImage?
    private var actionSheet: UIAlertController?
    
    private var croppingImageSource: UIImage?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showImageSourceOptions()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
     
    // MARK: - Image Source Options
    private func showImageSourceOptions() {
        let alert = UIAlertController(title: "Profile Picture", message: "Choose an option", preferredStyle: .actionSheet)
        actionSheet = alert
        
        // Camera option
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.openCamera()
        }
        cameraAction.setValue(UIImage(systemName: "camera.fill"), forKey: "image")
        alert.addAction(cameraAction)
        
        // Photo Library option
        let photoLibraryAction = UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
                self?.openPhotoLibrary()
        }
        photoLibraryAction.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        alert.addAction(photoLibraryAction)
        
        // Delete option (only if there's a current image)
        if currentImage != nil {
            let deleteAction = UIAlertAction(title: "Delete Current Photo", style: .destructive) { [weak self] _ in
                self?.deleteProfileImage()
            }
            deleteAction.setValue(UIImage(systemName: "trash.fill"), forKey: "image")
            alert.addAction(deleteAction)
        }
        
        // Cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Image Handling
    private func openCamera() {
        actionSheet?.dismiss(animated: true)

        LSPHPickerController.shared.openCamera(from: self) {  image in
            guard let selectedImage = image else {
                print("No file selected or error occurred")
                return
            }
            // Present Cropper for image editing
//            self.presentQCropper(with: selectedImage)
        }
    }
    
    private func openPhotoLibrary() {
        actionSheet?.dismiss(animated: true)

        LSPHPickerController.shared.openPhotoLibrary(from: self) { url, image in
              guard let image = image else {
                  print("No file selected or error occurred")
                  self.delegate?.didSelectImage(nil)
                  self.dismiss(animated: true)
                  return
              }
              DispatchQueue.main.async {
                  self.presentQCropper(with: image)
              }
          }
    }
    
    private func deleteProfileImage() {
        actionSheet?.dismiss(animated: true)
        
        let alert = UIAlertController(
            title: LSConstants.Strings.Profile.deleteProfilePicture,
            message: LSConstants.Strings.Profile.confirmDelete,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: LSConstants.Strings.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: LSConstants.Strings.Common.delete, style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.delegate?.didDeleteProfileImage()
            }
        })
        
        present(alert, animated: true)
    }
    
    private func presentQCropper(with image: UIImage) {
        croppingImageSource = image
        DispatchQueue.main.async {
            // Create CropperViewController with circular crop enabled
            let cropperViewController = CropperViewController(originalImage: image, isCircular: true)
            
            // Set delegate
            cropperViewController.delegate = self
            
            // Present modally
            cropperViewController.modalPresentationStyle = .fullScreen
            self.present(cropperViewController, animated: true)
        }
    }
    
   
}
extension LSDProfileImagePickerViewController: CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        guard let state = state else {
            cropper.dismiss(animated: true) {
                self.dismiss(animated: true)
            }
            return
        }
        cropper.dismiss(animated: true) {
            if let sourceImage = self.croppingImageSource {
                // let croppedImage = sourceImage.cropped(withCropperState: state)
                // Save the cropped image to the document directory
                LSDocumentFileProcessor.shared.saveImageToDocumentsDirectory(image: sourceImage, folderName: "ProfilePicture") { [weak self] url, error in
                    guard let self = self else { return }
                    if let url = url {
                        self.delegate?.didSelectImage(url)
                        self.dismiss(animated: true)
                    }
                }
            } else {
                print("Failed to get cropped image")
            }
        }
    }

    func cropperDidCancel(_ cropper: CropperViewController) {
        cropper.dismiss(animated: true) {
            self.dismiss(animated: true)
        }
    }

}
