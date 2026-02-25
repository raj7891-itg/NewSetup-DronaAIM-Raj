//
//  LSSignatureViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 7/22/24.
//

import UIKit
import SwiftSignatureView

protocol LSSignatureViewControllerDelegate: AnyObject {
    func didTapSaveButton(url: URL?)
}

class LSSignatureViewController: UIViewController {
    @IBOutlet weak var signatureView: SwiftSignatureView!
    var idCardType: IDCardType = .signature
    weak var delegate: LSSignatureViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Signature"
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        self.navigationItem.rightBarButtonItem = saveButton
        // Do any additional setup after loading the view.
    }
    
    @objc func saveButtonTapped() {
        // Handle the save action
        self.dismiss(animated: true) {
            guard let signature = self.signatureView.getCroppedSignature() else { return }
            LSDocumentFileProcessor.shared.saveImageToDocumentsDirectory(image: signature, folderName: self.idCardType.rawValue) { url, error in
                self.delegate?.didTapSaveButton(url: url)
            }
        }
    }
    
}
