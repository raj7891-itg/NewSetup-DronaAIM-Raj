//
//  LSPHPickerController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 29/06/24.
//

import Foundation
import PhotosUI

class LSPHPickerController: NSObject {
    var completion: ((URL?, UIImage?) -> Void)?
    var imagePickerCompletion: ((UIImage?) -> Void)?

    static let shared = LSPHPickerController()
    
    func openPhotoLibrary(
        from viewController: UIViewController,
        completion: @escaping (URL?, UIImage?) -> Void
    ) {
        self.completion = completion
        
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        viewController.present(picker, animated: true, completion: nil)
    }
    
    func openCamera(from viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
        self.imagePickerCompletion = completion
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        viewController.present(imagePickerController, animated: true, completion: nil)
    }

}

extension LSPHPickerController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let selectedImage = info[.originalImage] as? UIImage {
            self.imagePickerCompletion?(selectedImage)
        } else {
            self.imagePickerCompletion?(nil)
        }
    }
    
}

//MARK: PHPickerViewControllerDelegate
extension LSPHPickerController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        guard let provider = results.first?.itemProvider else {
            self.completion?(nil, nil)
            return
        }

        var pickedURL: URL?
        var pickedImage: UIImage?
        let dispatchGroup = DispatchGroup()

        // 1. Load file URL (if possible)
        if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            dispatchGroup.enter()
            provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] (url, error) in
                if let url = url {
                    // Optionally: move temp file to a location your app controls if you plan to reuse it
                    pickedURL = url
                }
                dispatchGroup.leave()
            }
        }

        // 2. Load UIImage
        if provider.canLoadObject(ofClass: UIImage.self) {
            dispatchGroup.enter()
            provider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    pickedImage = image
                }
                dispatchGroup.leave()
            }
        }

        // 3. Call completion after both are done (or after ~1 is done, if only 1 applies)
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.completion?(pickedURL, pickedImage)
        }
    }
}

