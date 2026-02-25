//
//  LSActivity.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/23/24.
//

import Foundation
import UIKit
import Photos

// Custom UIActivity for Saving URL to Photos
class SaveToPhotosActivity: UIActivity {
    var urlToSave: URL?
    
    override var activityTitle: String? {
        return "Save to Photos"
    }
    
    override var activityImage: UIImage? {
        return UIImage(systemName: "photo")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if let url = item as? URL, url.isFileURL {
                return true
            }
        }
        return false
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        for item in activityItems {
            if let url = item as? URL, url.isFileURL {
                urlToSave = url
            }
        }
    }
    
    override func perform() {
        guard let url = urlToSave else {
            activityDidFinish(false)
            return
        }
        
        saveMediaToPhotos(from: url)
    }
    
    private func saveMediaToPhotos(from url: URL) {
        PHPhotoLibrary.shared().performChanges({
            if url.pathExtension.lowercased() == "mp4" || url.pathExtension.lowercased() == "mov" {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } else if let image = UIImage(contentsOfFile: url.path) {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }) { success, error in
            self.activityDidFinish(success)
        }
    }
}

// Custom UIActivity for Saving URL to Files
class SaveToFilesActivity: UIActivity {
    var urlToSave: URL?
    
    override var activityTitle: String? {
        return "Save to Files"
    }
    
    override var activityImage: UIImage? {
        return UIImage(systemName: "folder")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if let url = item as? URL {
                return url.isFileURL
            }
        }
        return false
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        for item in activityItems {
            if let url = item as? URL, url.isFileURL {
                urlToSave = url
            }
        }
    }
    
    override func perform() {
        guard let url = urlToSave else {
            activityDidFinish(false)
            return
        }
        
        let documentPicker = UIDocumentPickerViewController(forExporting: [url])
        documentPicker.delegate = self
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(documentPicker, animated: true, completion: nil)
        }
    }
}

extension SaveToFilesActivity: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        activityDidFinish(true)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        activityDidFinish(false)
    }
}
