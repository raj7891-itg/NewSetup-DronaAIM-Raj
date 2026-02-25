//
//  LSMailComposerViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 07/11/24.
//

import UIKit
import MobileCoreServices
import QuickLook

class LSMailComposerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var attachments: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "New Message"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendEmail))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelEmail))
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(LSToCCFieldCell.self, forCellReuseIdentifier: "LSToCCFieldCell")
        tableView.register(LSSubjectFieldCell.self, forCellReuseIdentifier: "LSSubjectFieldCell")
        tableView.register(LSBodyFieldCell.self, forCellReuseIdentifier: "LSBodyFieldCell")
        tableView.register(LSAttachmentCell.self, forCellReuseIdentifier: "LSAttachmentCell")

        // Enable dynamic row height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 55),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @IBAction private func sendEmail() {
        // Handle sending email logic here
        // You could validate the emails collected from To/CC fields here as well
        self.view.endEditing(true)
        guard let subjectCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? LSSubjectFieldCell else {
            return
        }
        
        let subject = subjectCell.getSubject()
        if subject.isEmpty {
            UIAlertController.showError(on: self, message: "Subject should not be nil ")
            return
        }
        
        guard let bodyCell = tableView.cellForRow(at: IndexPath(row: 0, section: 4)) as? LSBodyFieldCell else {
            return
        }
        
        let bodyString = bodyCell.getBodyString()
        if bodyString.isEmpty {
            UIAlertController.showError(on: self, message: "Body should not be nil ")
            return
        }
        
        LSProgress.show(in: self.view)
        if let userDetails = UserDefaults.standard.userDetails {
            var parms: [String: Any] = ["userId": userDetails.userId, "subject": subject, "body": bodyString]

            if let ccCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? LSToCCFieldCell {
                let ccEmails = ccCell.getAllEmails().filter {$0.isValidEmail()}
                if ccEmails.count > 0 {
                    let ccEmailsString = ccEmails.joined(separator: ", ")
                    parms["ccEmails"] = ccEmails
                }
            }
            for attachment in attachments {
                let fileNmae = UUID().uuidString
                parms[fileNmae] = attachment
            }
            let endpoint = LSAPIEndpoints.sendEmail()
            Task {
                do {
                    let response: LSSuccess = try await LSNetworkManager.shared.postMultipart(endpoint: endpoint, params: parms, apiType: .analytics)
                    if let message = response.message {
                        UIAlertController.showActionMessage(on: self, message: message) {
                            LSProgress.hide(from: self.view)
                            self.dismiss(animated: true)
                        }
                    }
                } catch {
                    UIAlertController.showError(on: self, message: String(error.localizedDescription))
                    LSProgress.hide(from: self.view)
                }
            }
        }

        
    }
    
    
    @IBAction func attachFileAction(_ sender: Any) {
        showIdPicActionSheet()
    }
    
    private func showIdPicActionSheet() {
        let options = [
            ActionSheetOption(title: "iCloud Drive", image: UIImage(systemName: "cloud.fill"), type: .icloud),
            ActionSheetOption(title: "Take Photo", image: UIImage(systemName: "camera.fill"), type: .takePhoto),
            ActionSheetOption(title: "Phone Storage", image: UIImage(systemName: "folder.fill"), type: .phoneStorage)
        ]
        
        let actionSheetController = UIAlertController(title: "Please select", message: "Multiple files can be attached and the total size of attachments should be lessthan 5Mb", preferredStyle: .actionSheet)
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
            LSDocumentFileProcessor.shared.saveImageToDocumentsDirectory(image: selectedImage, folderName: "Mail") { [weak self] url, error in
                guard let self = self else { return }
                if let destinationUrl = url {
                    attachments.append(destinationUrl)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
                }
            }
        }
    }
    
    private func openPhotoLibrary() {
        LSPHPickerController.shared.openPhotoLibrary(from: self) {  url, image in
            guard let url = url else {
                print("No file selected or error occurred")
                return
            }
            Task {
                let fileData = try LSNetworkManager.shared.readCompressedImageData(from: url, compressionQuality: 0.8)
                let sizeinMB = LSNetworkManager.shared.dataSizeInMB(data: fileData)
                print("Size in MB =", sizeinMB)
                if sizeinMB > 5 {
                    UIAlertController.showError(on: self, message: "File size should not exceeds 5 MB")
                }
            }

            LSDocumentFileProcessor.shared.saveFileToDocumentsDirectory(fileURL: url, folderName: "Mail") {[weak self] destinationUrl, error in
                guard let self = self else { return }
                if let destinationUrl = destinationUrl {
                    attachments.append(destinationUrl)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
                }
            }
        }
    }
    
    @IBAction private func cancelEmail() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        attachments.remove(at: index)
        self.tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5 // To, CC, Subject, attchments, Body
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return attachments.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSToCCFieldCell", for: indexPath) as! LSToCCFieldCell
            cell.delegate = self
            cell.configureTo(with: "To:", toEmail: "telematics@dronaaim.ai")
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSToCCFieldCell", for: indexPath) as! LSToCCFieldCell
            cell.delegate = self
            cell.configureCC(with: "Cc:")
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSSubjectFieldCell", for: indexPath) as! LSSubjectFieldCell
            var title = ""
            if let userDetails = UserDefaults.standard.userDetails, let name = userDetails.fullName {
                title = "Support Request from \(name) [\(userDetails.userId)]"
            }
            cell.configure(with: "Subject:", title: title)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSAttachmentCell", for: indexPath) as! LSAttachmentCell
            let attachment = attachments[indexPath.row]
            cell.textLabel?.text = attachment.lastPathComponent
            
            let closeButton = UIButton(type: .custom)
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            closeButton.tintColor = .black
            closeButton.addTarget(self, action: #selector(closeButtonTapped(_:)), for: .touchUpInside)
            closeButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24) // Explicit size to ensure visibility
            closeButton.tag = indexPath.row
            // Set the button as the accessory view
            cell.accessoryView = closeButton
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSBodyFieldCell", for: indexPath) as! LSBodyFieldCell
            if let userDetails = UserDefaults.standard.userDetails {
                cell.configure(with: userDetails, tableView: tableView)
            }
            return cell
        default:
            fatalError("Unexpected section")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


protocol TokenFieldCellDelegate: AnyObject {
    func heightUpdated()
}

extension LSMailComposerViewController: TokenFieldCellDelegate {
    func heightUpdated() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: - UIDocumentPickerDelegate
extension LSMailComposerViewController: UINavigationControllerDelegate, UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let selectedFileURL = urls.first {
            Task {
                let fileData = try LSNetworkManager.shared.readCompressedImageData(from: selectedFileURL, compressionQuality: 0.8)
                let sizeinMB = LSNetworkManager.shared.dataSizeInMB(data: fileData)
                if sizeinMB > 5 {
                    UIAlertController.showError(on: self, message: "File size should not exceeds 5 MB")
                }
            }
            LSDocumentFileProcessor.shared.saveFileToDocumentsDirectory(fileURL: selectedFileURL, folderName: "Mail") { success, error in
                self.attachments.append(selectedFileURL)
                DispatchQueue.main.async {
                    self.tableView.reloadSections(IndexSet(integer: 3), with: .automatic)
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
