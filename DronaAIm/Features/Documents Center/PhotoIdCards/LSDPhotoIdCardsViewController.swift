//
//  LSDPhotoIdCardsViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 29/06/24.
//

import UIKit
import MobileCoreServices
import QuickLook

struct ActionSheetOption {
    let title: String
    let image: UIImage?
    let type: ActionType
}
enum ActionType {
    case icloud
    case takePhoto
    case phoneStorage
}

class LSDPhotoIdCardsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
//    var allFiles = [LSDPhotoIdCardModel]()
    var idCardType: IDCardType = .drivingLicence
    var userDocuments = [UserDocument]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50 // Estimate row height
        fetchDocumentsList()
    }
        
    private func updateTitle() {
        if idCardType == .photoId {
            self.title = "Photo ID Cards"
            titleLabel.text = "Upload your photo ID"
            subTitleLabel.text = "Please upload a clear image of your Photo ID."

        } else if idCardType == .drivingLicence {
            self.title = "Driving License"
            titleLabel.text = "Upload your Driving License."
            subTitleLabel.text = "Please upload a clear image of your Driving License."
        } else if idCardType == .signature {
            self.title = "Signature"
            titleLabel.text = "Upload your Signature."
            subTitleLabel.text = "Please upload a clear image of your Signature."
        } else if idCardType == .other {
            self.title = "Other"
            titleLabel.text = "Upload your other documents."
            subTitleLabel.text = "Please upload a clear image of your Other document."
        }
    }
    
    private func showIdPicActionSheet() {
        let options = [
            ActionSheetOption(title: "iCloud Drive", image: UIImage(systemName: "cloud.fill"), type: .icloud),
            ActionSheetOption(title: "Take Photo", image: UIImage(systemName: "camera.fill"), type: .takePhoto),
            ActionSheetOption(title: "Phone Storage", image: UIImage(systemName: "folder.fill"), type: .phoneStorage)
        ]
        
        let actionSheetController = UIAlertController(title: "Please select", message: "Option to select", preferredStyle: .actionSheet)
        actionSheetController.view.tintColor = UIColor.accent

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        for option in options {
            let action = UIAlertAction(title: option.title, style: .default) { [weak self] action in
                guard let self = self else { return }
                self.handleAction(option.type)
            }
            action.setValue(option.image, forKey: "image")
            actionSheetController.addAction(action)
        }
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    private func showSignatureVC() {
        let signatureVC = LSSignatureViewController.instantiate(fromStoryboard: .driver)
        signatureVC.delegate = self
        let navController = UINavigationController(rootViewController: signatureVC)
        self.navigationController?.present(navController, animated: true)
    }
    
    func previewImage(url: URL) {
        let previewVC = LSImagepreviewViewController.instantiate(fromStoryboard: .driver)
        previewVC.previewDelegate = self
        previewVC.url = url
        self.present(previewVC, animated: true)
    }
    
    func previewPDF(url: URL) {
        let previewVC = LSPDFPreviewController.instantiate(fromStoryboard: .driver)
        previewVC.previewDelegate = self
        previewVC.pdfURL = url
        self.present(previewVC, animated: true)
    }
    
    private func handleAction(_ type: ActionType) {
        switch type {
        case .icloud:
            openFiles()
        case .takePhoto:
            openCamera()
        case .phoneStorage:
            openPhotoLibrary()
        }
    }
        
    func fileSize(forURL url: URL) -> Double? {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resourceValues.fileSize {
                // Convert bytes to KB or MB
                let sizeInKB = Double(fileSize) / 1024.0
                let sizeInMB = sizeInKB / 1024.0
                return sizeInMB // or return sizeInKB for KB
            }
        } catch {
            print("Error retrieving file size: \(error)")
        }
        return nil
    }
    
    private func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func openFiles() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeItem as String], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    private func openCamera() {
        LSPHPickerController.shared.openCamera(from: self) {  image in
            guard let selectedImage = image else {
                print("No file selected or error occurred")
                return
            }
            // Save the selected image to the document directory
            LSDocumentFileProcessor.shared.saveImageToDocumentsDirectory(image: selectedImage, folderName: self.idCardType.rawValue) { [weak self] url, error in
                guard let self = self else { return }
                if let destinationUrl = url {
                    uploadFile(fileUrl: destinationUrl, documentType: self.idCardType.rawValue)
                }

                DispatchQueue.main.async {
                    self.reloadTableView()
                }
            }
        }
    }
    
    private func openPhotoLibrary() {
        LSPHPickerController.shared.openPhotoLibrary(from: self) {  url, image in
            // Prefer saving from the image (stable data) if available
            if let image = image {
                LSDocumentFileProcessor.shared.saveImageToDocumentsDirectory(image: image, folderName: self.idCardType.rawValue) { [weak self] savedURL, error in
                    guard let self = self else { return }
                    if let savedURL = savedURL {
                        self.uploadFile(fileUrl: savedURL, documentType: self.idCardType.rawValue)
                    } else if let error = error {
                        print("Failed to save image: \(error)")
                    }
                    DispatchQueue.main.async { self.reloadTableView() }
                }
                return
            }

            // Fallback: if URL exists, copy it immediately to a stable location
            guard let url = url else {
                print("No file selected or error occurred")
                return
            }
            LSDocumentFileProcessor.shared.saveFileToDocumentsDirectory(fileURL: url, folderName: self.idCardType.rawValue) { [weak self] destinationUrl, error in
                guard let self = self else { return }
                if let destinationUrl = destinationUrl {
                    self.uploadFile(fileUrl: destinationUrl, documentType: self.idCardType.rawValue)
                } else if let error = error {
                    print("Failed to save file: \(error)")
                }
                DispatchQueue.main.async { self.reloadTableView() }
            }
        }
    }
    
    private func fetchDocumentsList() {
        LSProgress.show(in: self.view)
        if let userDetails = UserDefaults.standard.userDetails, let lonestarId = UserDefaults.standard.selectedOrganization?.lonestarId {
            let endpoint = LSAPIEndpoints.userDocuments(
                for: lonestarId,
                driverId: userDetails.userId
            )
            Task {
                do {
                    let response: LSUserDocumentsModel = try await LSNetworkManager.shared.get(endpoint)
                    let filterDocuments = response.userDocuments.filter { $0.documentType == self.idCardType.rawValue }
                    self.userDocuments = filterDocuments
                    self.tableView.reloadData()
                    LSProgress.hide(from: self.view)
                } catch {
                    UIAlertController.showError(on: self, message: String(error.localizedDescription))
                    LSProgress.hide(from: self.view)
                }
            }
        }

    }
    
    private func deleteDocumentFor(fileName: String) {
        LSProgress.show(in: self.view, message: "Deleting...")
        if let userDetails = UserDefaults.standard.userDetails, let lonestarId = UserDefaults.standard.selectedOrganization?.lonestarId {
            let endpoint = LSAPIEndpoints.deleteDocument(
                for: lonestarId, driverId: userDetails.userId,
                fileName: fileName
            )
            Task {
                do {
                    let response: LSSuccess = try await LSNetworkManager.shared.delete(endpoint)
                    if let message = response.message {
                        UIAlertController.showError(on: self, message: message)
                    }
                    LSProgress.hide(from: self.view)
                    self.fetchDocumentsList()
                } catch {
                    UIAlertController.showError(on: self, message: String(error.localizedDescription))
                    LSProgress.hide(from: self.view)
                }
            }
        }

    }

        
    private func uploadFile(fileUrl: URL, documentType: String) {
        DispatchQueue.main.async {
            LSProgress.show(in: self.view, message: "uploading...")
        }
        Task {
            do {
                let response = try await LSNetworkManager.shared.uploadFileToS3(from: fileUrl, documentType: documentType)
                UIAlertController.showError(on: self, message: response?.message ?? "Uploaded Successfully")
                LSProgress.hide(from: self.view)
                self.fetchDocumentsList()
            } catch {
                UIAlertController.showError(on: self, message: String(error.localizedDescription))
                LSProgress.hide(from: self.view)
            }
        }
    }
    
}

struct RequestBodyForUploadDocument: Encodable {
    let fileName: String
    let contentType: String
    let type: String
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension LSDPhotoIdCardsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDocuments.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return self.tableView(tableView, addCellForRowAt: indexPath)
        } else {
            return self.tableView(tableView, listCellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, addCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSPhotoUploadTableViewCell", for: indexPath) as? LSPhotoUploadTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, listCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSDPhotosListTableViewCell", for: indexPath) as? LSDPhotosListTableViewCell else {
            return UITableViewCell()
        }
        
        let model = userDocuments[indexPath.row - 1]
        cell.config(with: model)
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    @objc func deleteAction(sender: UIButton) {
        let model = self.userDocuments[sender.tag - 1]
        if let fileName = model.fileName, let docRef = model.docRef {
            let alertController = UIAlertController(title: "Alert", message: "Are you sure you want to delete \(fileName) ?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                self.deleteDocumentFor(fileName: docRef)
            }))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            if idCardType == .signature {
                showSignatureVC()
            } else {
                showIdPicActionSheet()
            }
        }
        else {
            let model = userDocuments[indexPath.row - 1]
            if let signedUrl = model.signedURL, let url = URL(string: signedUrl) {
                if model.contentType == "application/pdf" {
                    self.previewPDF(url: url)
                } else {
                    self.previewImage(url: url)
                }
            }
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension LSDPhotoIdCardsViewController: UINavigationControllerDelegate, UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        print("Selected file URL: \(selectedFileURL)")

        let didStartAccess = selectedFileURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccess {
                selectedFileURL.stopAccessingSecurityScopedResource()
            }
        }

        LSDocumentFileProcessor.shared.saveFileToDocumentsDirectory(fileURL: selectedFileURL, folderName: self.idCardType.rawValue) { [weak self] destinationUrl, error in
            guard let self = self else { return }
            if let error = error {
                print("Save failed: \(error)")
            } else if let destinationUrl = destinationUrl {
                self.uploadFile(fileUrl: destinationUrl, documentType: self.idCardType.rawValue)
            }
            self.reloadTableView()
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - LSSignatureViewControllerDelegate
extension LSDPhotoIdCardsViewController: LSSignatureViewControllerDelegate {
    func didTapSaveButton(url: URL?) {
        if let url = url {
            uploadFile(fileUrl: url, documentType: self.idCardType.rawValue)
        }
        reloadTableView()
    }
}

extension LSDPhotoIdCardsViewController: LSShowActivityDelegate {
    func showActivityController(url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url as URL], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}

