//
//  LSDocumentFileProcessor.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 29/06/24.
//

import Foundation
import UIKit

class LSDocumentFileProcessor {
    
    static let shared = LSDocumentFileProcessor()
    private init() {}

    func saveFileToDocumentsDirectory(fileURL: URL, folderName: String, completion: @escaping(URL?, Error?) -> Void) {
        let fileManager = FileManager.default
        print("saveFileToDocumentsDirectory called with fileURL=\(fileURL), folderName=\(folderName)")

        let didStartAccess = fileURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let directoryURL = documentsURL.appendingPathComponent(folderName, isDirectory: true)
            print("Target directory: \(directoryURL.path)")

            if !fileManager.fileExists(atPath: directoryURL.path) {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                print("Created directory at \(directoryURL.path)")
            }

            let destinationURL = directoryURL.appendingPathComponent(fileURL.lastPathComponent)
            print("Destination URL: \(destinationURL.path)")

            if fileManager.fileExists(atPath: destinationURL.path) {
                do {
                    try fileManager.removeItem(at: destinationURL)
                    print("Removed existing file at destination to overwrite")
                } catch {
                    print("Failed to remove existing file before overwrite: \(error)")
                    completion(nil, error)
                    return
                }
            }

            try fileManager.copyItem(at: fileURL, to: destinationURL)
            print("File saved to: \(destinationURL.path)")
            completion(destinationURL, nil)
        } catch {
            print("Error saving file: \(error)")
            completion(nil, error)
        }
    }

    func listFilesInDocumentsDirectory(folderName: String, completion: @escaping([URL]?, Error?) -> Void) {
        let fileManager = FileManager.default
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let directoryURL = documentsURL.appendingPathComponent(folderName)
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            print("Listed files in \(directoryURL.path): \(fileURLs.map{ $0.lastPathComponent })")
            completion(fileURLs, nil)
        } catch {
            completion(nil, error)
        }
    }

    func readFileFromDocumentsDirectory(folderName: String, fileName: String, completion: @escaping(URL?, Error?) -> Void) {
        let fileManager = FileManager.default
        
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentsURL.appendingPathComponent(folderName).appendingPathComponent(fileName)
            print("Read file URL: \(fileURL.path)")
            completion(fileURL, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func saveImageToDocumentsDirectory(image: UIImage, folderName: String, completion: @escaping(URL?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to create JPEG data from image")
            completion(nil, NSError(domain: "ImageEncoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode image"]))
            return
        }

        let fileManager = FileManager.default
        do {
            let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let directoryURL = documentsURL.appendingPathComponent(folderName, isDirectory: true)

            if !fileManager.fileExists(atPath: directoryURL.path) {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                print("Created directory at \(directoryURL.path)")
            }

            let timestamp = Int(Date().timeIntervalSince1970)
            let fileURL = directoryURL.appendingPathComponent("image_\(timestamp).jpg")
            try imageData.write(to: fileURL, options: .atomic)
            print("Image saved to: \(fileURL.path)")
            completion(fileURL, nil)
        } catch {
            print("Error saving image: \(error)")
            completion(nil, error)
        }
    }
    
    func removeFileFromDocumentsDirectory(fileUrl: URL, completion: @escaping(Bool?, Error?) -> Void) {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: fileUrl)
            print("Removed file at: \(fileUrl.path)")
            completion(true, nil)
        } catch {
            print("Failed to remove file: \(error)")
            completion(false, error)
        }
    }

}
