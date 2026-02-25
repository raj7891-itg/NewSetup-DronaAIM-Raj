//
//  LSPDFPreviewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 10/10/24.
//

import Foundation
import PDFKit

class LSPDFPreviewController: UIViewController {
    weak var previewDelegate: LSShowActivityDelegate?

    @IBOutlet weak var previewView: UIView!
    var pdfURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the PDF view
        let pdfView = PDFView(frame: previewView.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.contentMode = .scaleAspectFit
        pdfView.autoScales = true  // Ensures the PDF fits the view
        previewView.addSubview(pdfView)
        
        // Check if there's a URL and load the PDF
        if let pdfURL = pdfURL {
            if let document = PDFDocument(url: pdfURL) {
                pdfView.document = document
            }
        }
        
    }
    
    // Close the preview
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func downloadAction(_ sender: Any) {
        if let url = pdfURL {
            Task {
                LSProgress.show(in: self.view, message: "Downloading")
                let destinationUrl = try await LSNetworkManager.shared.downloadAndSaveFile(from: url)
                LSProgress.hide(from: self.view)
                self.dismiss(animated: true) {
                    self.previewDelegate?.showActivityController(url: destinationUrl)
                }
            }
        }
    }
    
    @IBAction func shareVideoAction(_ sender: Any) {
        if let url = pdfURL {
            Task {
                LSProgress.show(in: self.view)
                let requestbody = LSAliasRequest(url: url.absoluteString)
                let response: LSAliasModel = try await LSNetworkManager.shared.post("", body: requestbody, apiType: .alias)
                LSProgress.hide(from: self.view)
                if let aliasUrl = URL(string: response.aliasURL) {
                    self.dismiss(animated: true) {
                        self.previewDelegate?.showActivityController(url: aliasUrl)
                    }
                }
            }
        }
    }
}
