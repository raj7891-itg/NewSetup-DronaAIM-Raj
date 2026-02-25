//
//  LSEmailViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 10/29/24.
//

import UIKit
import Toast

struct RequestBodyForEmail: Encodable {
    let userId: String
    let subject: String
    let body: String
    var ccEmails: [String] = []
}

class LSEmailViewController: UIViewController {

    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var subjectTextfield: LSPaddingTextfield!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Support Request from Driver Name [Driver ID]
        if let userDetails = UserDefaults.standard.userDetails, let name = userDetails.fullName {
            subjectTextfield.text = "Support Request from \(name) [\(userDetails.userId)]"
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        self.view.endEditing(true)
        guard let subjectText = subjectTextfield.text, !subjectText.isEmpty else {
            self.view.makeToast("Subject cannot be empty.", position: .bottom)
            return
        }
        guard let bodyText = bodyTextView.text, !bodyText.isEmpty else {
            self.view.makeToast("Body cannot be empty.", position: .bottom)
            return
        }
        
        LSProgress.show(in: self.view)
        if let userDetails = UserDefaults.standard.userDetails {
            let requestBody = RequestBodyForEmail(userId: userDetails.userId, subject: subjectText, body: bodyText)
            let endpoint = LSAPIEndpoints.sendEmail()
            Task {
                do {
                    let response: LSSuccess = try await LSNetworkManager.shared.post(endpoint, body: requestBody, apiType: .analytics)
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
    
}
