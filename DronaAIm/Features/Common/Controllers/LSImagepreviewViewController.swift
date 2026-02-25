//
//  LSImagepreviewViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/29/24.
//

import UIKit
import SDWebImage


protocol LSShowActivityDelegate: AnyObject {
    func showActivityController(url: URL)
}

class LSImagepreviewViewController: UIViewController {
    weak var previewDelegate: LSShowActivityDelegate?
    
    @IBOutlet weak var thumbnail: UIImageView!
    var url: URL!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.thumbnail.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.thumbnail.sd_setImage(with: url)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func downloadAction(_ sender: Any) {
        performAsyncTask(
            progressMessage: "Downloading",
            task: { [weak self] in
                guard let self = self, let url = self.url else {
                    throw NSError(domain: "LSImagepreviewViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL not available"])
                }
                return try await LSNetworkManager.shared.downloadAndSaveFile(from: url)
            },
            onSuccess: { [weak self] destinationUrl in
                self?.dismiss(animated: true) {
                    self?.previewDelegate?.showActivityController(url: destinationUrl)
                }
            }
        )
    }
    
    @IBAction func shareVideoAction(_ sender: Any) {
        performAsyncTask(
            task: { [weak self] in
                guard let self = self, let url = self.url else {
                    throw NSError(domain: "LSImagepreviewViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL not available"])
                }
                let requestbody = LSAliasRequest(url: url.absoluteString)
                let response: LSAliasModel = try await LSNetworkManager.shared.post("", body: requestbody, apiType: .alias)
                return response
            },
            onSuccess: { [weak self] response in
                if let aliasUrl = URL(string: response.aliasURL) {
                    self?.dismiss(animated: true) {
                        self?.previewDelegate?.showActivityController(url: aliasUrl)
                    }
                }
            }
        )
    }
}
