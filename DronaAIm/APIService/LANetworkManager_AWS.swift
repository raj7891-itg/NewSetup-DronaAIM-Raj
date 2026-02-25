//
//  LANetworkManager_AWS.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 10/9/24.
//

import Foundation
import UIKit

struct LSUploadedDocumentModel: Encodable {
    let lonestarId: String
    let docRef: String
    let fileName: String
    let contentType: String
    let fileSizeInKb: String
    let documentType: String
    let uploadedAtTs: String
}

struct LSSuccess: Codable {
    let message: String?
    let details: String?
}

enum LSDocumentSource: String {
    case documents
    case profile
}

extension LSNetworkManager {
    
    func uploadFileToS3(from fileURL: URL, documentType: String, documentSource: LSDocumentSource = .documents) async throws -> LSSuccess? {
        // Determine MIME type based on file extension
        let fileExtension = fileURL.pathExtension.lowercased()
        let mimeType: String
        switch fileExtension {
        case "jpeg":
            mimeType = "image/jpeg"
        case "jpg":
            mimeType = "image/jpg"
        case "png":
            mimeType = "image/png"
        case "pdf":
            mimeType = "application/pdf"
        default:
            throw NSError(domain: "UnsupportedFileType", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported file type"])
        }
        // Download the data from the image or PDF URL
        let fileData = try readCompressedImageData(from: fileURL, compressionQuality: 0.8)
        let sizeinMB = dataSizeInMB(data: fileData)
        if sizeinMB > 5 {
            throw NSError(domain: "UnsupportedFileType", code: -1, userInfo: [NSLocalizedDescriptionKey: "File size should not exceeds 5 MB"])
        }
        
        guard let presignedResponse = try await getPresignedUrlFor(fileUrl: fileURL, mimeType: mimeType, documentType: documentType, documentSource: documentSource) else {
            return nil
        }
        
        // Upload the data to S3 using the presigned URL
        if let putUrl = URL(string: presignedResponse.putUrl) {
            let size = String(dataSizeInKB(data: fileData))
            
            let success = try await uploadDataToS3(data: fileData, presignedURL: putUrl, mimeType: mimeType)
            let date = LSDateFormatter.shared.convertDateToTimeStamp(for: Date.now)
            
            if success {
                let lonestarId = UserDefaults.standard.selectedOrganization?.lonestarId ?? ""
                print("File uploaded successfully = ", success)
                let uploadedDataModel = LSUploadedDocumentModel(
                    lonestarId: lonestarId,
                    docRef: presignedResponse.docRef,
                    fileName: fileURL.lastPathComponent,
                    contentType: mimeType,
                    fileSizeInKb: size,
                    documentType: documentType,
                    uploadedAtTs: date
                )
                let response = try await updateDocumentDetails(uploadedDocument: uploadedDataModel, documentSource: documentSource)
                return response
            }
        } else {
            return nil
        }
        return nil
    }
    
    func getPresignedUrlFor(fileUrl: URL, mimeType: String, documentType: String, documentSource: LSDocumentSource = .documents) async throws -> LSDocumentPreSignedModel? {
        print("File Url = ", fileUrl)
        if let userDetails = UserDefaults.standard.userDetails {
            var endpoint = LSAPIEndpoints.uploadDocumentPresignedByDriverId(for: userDetails.userId)
            if documentSource == .profile {
                endpoint = LSAPIEndpoints
                    .uploadProfilePicture(for: userDetails.userId)
            }
            let requestbody = RequestBodyForUploadDocument(fileName: fileUrl.lastPathComponent, contentType: mimeType, type: documentType)
            print("Request Body = ", requestbody)
            let uploadDocumentPreSigned: LSDocumentPreSignedModel = try await LSNetworkManager.shared.post(
                endpoint,
                body: requestbody,
            )
            print("uploadDocumentPreSigned = ", uploadDocumentPreSigned)
            return uploadDocumentPreSigned
        } else {
            return nil
        }
    }
    
    private func updateDocumentDetails(uploadedDocument: LSUploadedDocumentModel, documentSource: LSDocumentSource = .documents) async throws -> LSSuccess  {
        if let userDetails = UserDefaults.standard.userDetails {
            var endpoint = LSAPIEndpoints.updateDocumentDetails(for: userDetails.userId)

            if documentSource == .profile {
                endpoint = LSAPIEndpoints
                    .uploadProfilePictureDetails(for: userDetails.userId)
            }
            let success: LSSuccess = try await LSNetworkManager.shared.post(
                endpoint,
                body: uploadedDocument,
            )
            return success
        } else {
            throw NSError(domain: "updateDetails", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
    }
    
    // Function to download the image or PDF data from the URL
func readCompressedImageData(from localURL: URL, compressionQuality: CGFloat) throws -> Data {
        // Get the file extension to check if it's an image
        let fileExtension = localURL.pathExtension.lowercased()

        // If it's a JPEG or PNG image, compress it
        if fileExtension == "jpg" || fileExtension == "jpeg" || fileExtension == "png" {
            // Load the image from the local URL
            guard let image = UIImage(contentsOfFile: localURL.path) else {
                throw NSError(domain: "ImageLoadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image from URL"])
            }
            
            // Compress the image to JPEG data (you can adjust the compression quality)
            guard let compressedData = image.jpegData(compressionQuality: compressionQuality) else {
                throw NSError(domain: "ImageCompressionError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
            }
            
            return compressedData
        } else {
            // For non-image files like PDFs, return the original data
            return try Data(contentsOf: localURL)
        }
    }


    // Function to upload data (image or PDF) to S3 using presigned PUT URL
   private func uploadDataToS3(data: Data, presignedURL: URL, mimeType: String, ) async throws -> Bool {
        // Create a URLRequest with the presigned URL and set the HTTP method to PUT
        var request = URLRequest(url: presignedURL)
        request.httpMethod = "PUT"
        
        // Set the Content-Type to match the file type (e.g., image/jpeg or application/pdf)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(mimeType, forHTTPHeaderField: "Content-Type")

        // Use URLSession to upload the data with async/await
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
        
        // Check the HTTP response status code
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            print("File uploaded successfully")
            return true
        } else {
            throw NSError(domain: "UploadError", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload file"])
        }
    }

   private func dataSizeInKB(data: Data) -> Double {
        let sizeInBytes = Double(data.count)
        let sizeInKB = sizeInBytes / 1024.0
        return sizeInKB
    }

    func dataSizeInMB(data: Data) -> Double {
        let sizeInBytes = Double(data.count)
        let sizeInMB = sizeInBytes / (1024.0 * 1024.0) // Convert bytes to MB
        return sizeInMB
    }

}
