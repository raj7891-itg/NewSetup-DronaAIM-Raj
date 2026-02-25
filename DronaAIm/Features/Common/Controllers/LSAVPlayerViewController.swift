//
//  LSAVPlayerViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 7/29/24.
//

import UIKit
import AVKit

//protocol LSAVPlayerViewDelegate: AnyObject {
//    func didTaponDownload(url: URL)
//}

class LSAVPlayerViewController: AVPlayerViewController {
    weak var avPlayerDelegate: LSShowActivityDelegate?
    private var downloadButton: UIButton!
    private var downloadButtonTopConstraint: NSLayoutConstraint!
    private var downloadButtonTrailingConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Ensure the navigation bar is visible
        self.showsPlaybackControls = true
        setupDownloadButton()
    }

    private func setupDownloadButton() {
        guard let contentOverlayView = self.view else { return }

        // Create the download button
        downloadButton = UIButton(type: .system)
        downloadButton.setImage(UIImage(systemName: "arrow.down.to.line"), for: .normal)
        downloadButton.tintColor = .white
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)

        // Add the button to the contentOverlayView
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        contentOverlayView.addSubview(downloadButton)

        // Setup initial constraints
        downloadButtonTopConstraint = downloadButton.topAnchor.constraint(equalTo: contentOverlayView.topAnchor, constant: 60)
        downloadButtonTrailingConstraint = downloadButton.trailingAnchor.constraint(equalTo: contentOverlayView.trailingAnchor, constant: -20)

        NSLayoutConstraint.activate([
            downloadButtonTopConstraint,
            downloadButtonTrailingConstraint
        ])
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Update button constraints based on the current orientation
        updateButtonConstraints(for: view.bounds.size)
    }

    private func updateButtonConstraints(for size: CGSize) {
        // Adjust the button's top and trailing constraints based on orientation
        if size.width > size.height { // Landscape
            downloadButtonTopConstraint.constant = 40
            downloadButtonTrailingConstraint.constant = -30
        } else { // Portrait
            downloadButtonTopConstraint.constant = 60
            downloadButtonTrailingConstraint.constant = -20
        }
    }

    @objc func downloadButtonTapped() {
        // Handle download action
        if let mediaURL = getCurrentMediaURL() {
            print("Current media URL: \(mediaURL)")
            // Use the URL for your download functionality
                Task {
                    LSProgress.show(in: self.view, message: "Downloading")
                   let destinationUrl = try await LSNetworkManager.shared.downloadAndSaveFile(from: mediaURL)
                    LSProgress.hide(from: self.view)
                    self.dismiss(animated: true) {
                        self.avPlayerDelegate?.showActivityController(url: destinationUrl)
                    }
                }
        } else {
            print("No media URL found")
        }
    }
    
    func getCurrentMediaURL() -> URL? {
        // Access the current AVPlayerItem
        if let currentItem = self.player?.currentItem,
           let asset = currentItem.asset as? AVURLAsset {
            return asset.url
        }
        return nil
    }

}
