//
//  LSNetworkService.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 7/25/24.
//

import Foundation
import UIKit
import AVFoundation

struct LSErrorDetails: Codable {
    let details: String?
    let message: String?
}

struct LSAPIEndpoints {
        
    static func sansataBaseUrl() -> String {
#if DEVELOPMENT
       return "https://is.smartwitness.co"
#elseif QA
        return "https://is.smartwitness.co"
#elseif PREPROD
        return "https://sv.smartwitness.co"
#else
        return "https://sv.smartwitness.co"
#endif

    }

    static func userDetails(for userId: String) -> String {
        return "users/userinfo/\(userId)"
    }
        
    static func tripsByDriverId(for driverId: String) -> String {
        return "lonestar/driver/\(driverId)/trips"
    }
    
    static func eventsBytripId(for tripId: String) -> String {
        return "lonestar/trip/\(tripId)/incidents"
    }
    
    static func allEventsByUserId(for driverId: String) -> String {
        return "lonestar/driver/\(driverId)/incidents"
    }
    
    static func liveTrackByTripId(for tripId: String) -> String {
        return "lonestar/vehicles/trip/\(tripId)/livetrack"
    }
    
    static func vehicleStats(for vehicleId: String) -> String {
        return "lonestar/vehicles/\(vehicleId)/stats"
    }
    
//    static func driverScoreData(for lonestarId: String, driverId: String) -> String {
//        return "analytics/v1/scores/driver/\(lonestarId)/\(driverId)"
//    }
    
    
    static func driverScoreData() -> String {
        return "drivers/driver-score"
    }
    
//    static func vehiclesByTenentId(for tenantId: String) -> String {
//        return "lonestar/\(tenantId)/vehicles"
//    }
    
    static func driverToVehicleAssign() -> String {
        return "lonestar/assignVechile/driver"
    }
    
    static func driverToVehicleUnAssign() -> String {
        return "lonestar/unassignVechile/driver"
    }
    
    static func eventsMetadataByDriverId(for driverId: String) -> String {
        return "lonestar/driver/\(driverId)/incidents/metadata"
    }
    
    static func uploadDocumentPresignedByDriverId(for driverId: String) -> String {
        return "lonestar/driver/\(driverId)/document-upload-url"
    }
    
    static func updateDocumentDetails(for driverId: String) -> String {
        return "lonestar/driver/\(driverId)/document-details"
    }
    
    static func userDocuments(for lonestarId: String, driverId: String) -> String {
        return "lonestar/driver/\(lonestarId)/\(driverId)/documents"
    }
    
    static func deleteDocument(for lonestarId: String, driverId: String, fileName: String) -> String {
        return "lonestar/driver/\(lonestarId)/\(driverId)/document/\(fileName)"
    }
    
    static func sendEmail() -> String {
        return "email/sendEmail"
    }
    
    static func registerDeviceToken(for driverId: String) -> String {
        return "lonestar/user/\(driverId)/map-notification-token"
    }
    
    static func notifications() -> String {
        return "lonestar/fleet/notification/user"
    }
    
    static func readNotificationStatu() -> String {
        return "lonestar/fleet/notification/read"
    }
    
    static func unReadNotificationStatu() -> String {
        return "lonestar/fleet/notification/unread"
    }
    
    static func uploadProfilePicture(for driverId: String) -> String {
        return "lonestar/user/\(driverId)/profile-pic-upload-url"
    }
    
    static func uploadProfilePictureDetails(for driverId: String) -> String {
        return "lonestar/user/\(driverId)/profile-pic-details"
    }
    
    static func updateProfileDetails(for driverId: String) -> String {
        return "lonestar/user/\(driverId)/profileDetails"
    }
    
    static func deleteProfileImage(for driverId: String, docRef: String) -> String {
        return "lonestar/user/\(driverId)/profilePicture/\(docRef)"
    }
    
}

class LSNetworkManager {
    static let shared = LSNetworkManager()

    private var environment: LSNetworkEnvironment

    // Initialize with a default environment or allow setting it during initialization
    private init(environment: LSNetworkEnvironment = .development(api: .lonestar)) {
        self.environment = environment
        
#if DEVELOPMENT
        self.environment = .development(api: .lonestar)
#elseif QA
        self.environment = .staging(api: .lonestar)
#elseif PREPROD
        self.environment = .preProd(api: .lonestar)
#else
        self.environment = .production(api: .lonestar)
#endif
    }

    private func createRequest(endpoint: String, method: String, parameters: [String: String]? = nil, apiType: LSNetworkEnvironment.API = .lonestar) async throws -> URLRequest {
        let baseURL = environment.baseURL(for: apiType)

        guard var url = URL(string: baseURL) else {
            LSLogger.error("Invalid base URL: \(baseURL)")
            throw NSError(
                domain: LSConstants.ErrorDomain.networkError,
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid server configuration. Please contact support."]
            )
        }

        if !endpoint.isEmpty {
            url = url.appendingPathComponent(endpoint)
        }

        LSLogger.debug("Request URL: \(url)")
        print("Prameter", parameters)
        // Add query parameters if any
        if let queryParams = parameters {
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
            // If method is GET and parameters are provided, add them as query items
            if method == "GET" {
                urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            }
            url = urlComponents.url!
        }

            
            // Option 2: Print absolute string
            print("Final URL String: \(url.absoluteString)")
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let cognitoUser = try await LSNetworkManager.shared.fetchAuthSession()

        if let accessToken = cognitoUser?.accessToken {
            let token = accessToken
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if method != "GET", let parameters = parameters {
            print("Request Parameters (\(method)): \(parameters)")
                   
                   // Or use your logger
                   LSLogger.debug("Request Parameters (\(method)): \(parameters)")
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        return request
    }
    
    // MARK: - Error Handling
    
    /// Handles HTTP error responses by extracting error messages from JSON
    /// - Parameters:
    ///   - httpResponse: The HTTP response with error status code
    ///   - data: The response data containing error information
    /// - Returns: An NSError with appropriate error message
    /// - Throws: NSError if error message cannot be extracted
    private func handleHTTPError(_ httpResponse: HTTPURLResponse, data: Data) throws -> NSError {
        // Try to extract error message from JSON response
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> {
            LSLogger.warning("HTTP Error \(httpResponse.statusCode): \(json)")
            
            // Try to get error message from various possible keys
            let errorMessage = json["message"] as? String
                ?? json["details"] as? String
                ?? json["detail"] as? String
            
            if let message = errorMessage, !message.isEmpty {
                return NSError(
                    domain: "HTTPError",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: message]
                )
            } else {
                return NSError(
                    domain: "HTTPError",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"]
                )
            }
        }
        
        // If JSON parsing fails, return generic HTTP error
        return NSError(
            domain: "HTTPError",
            code: httpResponse.statusCode,
            userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode)"]
        )
    }

    // MARK: - GET Request with Parameters
    func get<T: Decodable>(_ endpoint: String, parameters: [String: String]? = nil, apiType: LSNetworkEnvironment.API? = .lonestar) async throws -> T {
        let request = try await createRequest(endpoint: endpoint, method: "GET", parameters: parameters, apiType: apiType ?? .lonestar)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check if the response is an HTTP response and get the status code
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? Dictionary<String, Any> {
                    LSLogger.debug("User Details response: \(json)")
                }
                // Success: Proceed to decode the data
                return try JSONDecoder().decode(T.self, from: data)
            default:
                // Handle other status codes
                throw try handleHTTPError(httpResponse, data: data)
            }
        } else {
            // Handle unexpected response types
            throw NSError(domain: "Invalid Response", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected response type"])
        }

    }

    // MARK: - POST Request with Parameters
    func post<T: Encodable, U: Decodable>(_ endpoint: String, body: T? = nil, parameters: [String: String]? = nil, apiType: LSNetworkEnvironment.API? = .lonestar) async throws -> U {
        let bodyData = try JSONEncoder().encode(body)
        var request = try await createRequest(endpoint: endpoint, method: "POST", parameters: parameters, apiType: apiType ?? .lonestar)
        // Set the request's httpBody to the encoded body data
          request.httpBody = bodyData
        let bodyString = String(data: bodyData, encoding: .utf8)
        print("ParamBody", bodyString ?? "")
          // Optionally set the content type if your API requires it
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                // Success: Proceed to decode the data
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> {
                    LSLogger.debug("POST response: \(json)")
                }
                return try JSONDecoder().decode(U.self, from: data)
            default:
                // Handle other status codes
                throw try handleHTTPError(httpResponse, data: data)
            }
        } else {
            // Handle unexpected response types
            throw NSError(domain: "Invalid Response", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected response type"])
        }
    }
    
    func postMultipart<U: Decodable>(endpoint: String, params: [String: Any], apiType: LSNetworkEnvironment.API? = .lonestar) async throws -> U  {
        let baseURLString = environment.baseURL(for: apiType ?? .lonestar)
        
        guard let baseURL = URL(string: baseURLString) else {
            LSLogger.error("Invalid base URL for multipart request: \(baseURLString)")
            throw NSError(
                domain: LSConstants.ErrorDomain.networkError,
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid server configuration. Please contact support."]
            )
        }
        
        let url = baseURL.appendingPathComponent(endpoint)
        print("My send email url:", url.absoluteString)
        LSLogger.debug("Multipart request URL: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let cognitoUser = try await LSNetworkManager.shared.fetchAuthSession()

        if let accessToken = cognitoUser?.accessToken {
            let token = accessToken
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Boundary string for multipart form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create multipart form-data body
        var bodyData = Data()
        
        for (key, value) in params {
            if key == "ccEmails", let emails = value as? [String] {
                // Append each email as a separate field
                for email in emails {
                    bodyData.append("--\(boundary)\r\n")
                    bodyData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    bodyData.append("\(email)\r\n")
                }
            } else if let stringValue = value as? String {
                // Append single string parameters
                bodyData.append("--\(boundary)\r\n")
                bodyData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                bodyData.append("\(stringValue)\r\n")
            }
        }
        
        // Append attachments
        for (key, value) in params {
            if let attachmentURL = value as? URL {
                let filename = attachmentURL.lastPathComponent
                let data = try? Data(contentsOf: attachmentURL)
                let mimeType = "application/pdf" // Set correct MIME type if needed
                
                bodyData.append("--\(boundary)\r\n")
                bodyData.append("Content-Disposition: form-data; name=\"attachments\"; filename=\"\(filename)\"\r\n")
                bodyData.append("Content-Type: \(mimeType)\r\n\r\n")
                bodyData.append(data ?? Data())
                bodyData.append("\r\n")
            }
        }
       
        let bodyString = String(data: bodyData, encoding: .utf8)
        print("ParamBody", bodyString ?? "")
        
        // Execute the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Handle response
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                // Success: Decode response
                return try JSONDecoder().decode(U.self, from: data)
            default:
                
                // Handle other status codes
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(json)
                    let errorMessage = json["message"] as? String ?? json["detail"] as? String ?? "Unknown error"
                    throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                }
                throw NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)
            }
        } else {
            throw NSError(domain: "Invalid Response", code: 0, userInfo: nil)
        }
    }
    
    func put<T: Encodable, U: Decodable>(_ endpoint: String, body: T, parameters: [String: String]? = nil) async throws -> U {
        // Encode the body into JSON data
        let bodyData = try JSONEncoder().encode(body)
        
        // Create the URLRequest with the endpoint and method
        var request = try await createRequest(endpoint: endpoint, method: "PUT", parameters: parameters)
        
        // Set the request's httpBody to the encoded body data
        request.httpBody = bodyData
        // Optionally set the content type if your API requires it
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform the request and get the response data
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Decode the response data into the expected type
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                // Success: Proceed to decode the data
                return try JSONDecoder().decode(U.self, from: data)
            default:
                // Handle other status codes
                throw try handleHTTPError(httpResponse, data: data)
            }
        } else {
            // Handle unexpected response types
            throw NSError(domain: "Invalid Response", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected response type"])
        }
    }
    
    func downloadAndSaveFile(from url: URL) async throws -> URL {
        let (localURL, _) = try await URLSession.shared.download(from: url)
        
        do {
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
            
            // Remove any existing file at the destination
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.moveItem(at: localURL, to: destinationURL)
            
            print("File saved to: \(destinationURL)")
            return destinationURL
        } catch {
            print("File move error: \(error)")
            throw error
        }
    }
    // MARK: - Delete Request with Parameters
    func delete<T: Decodable>(_ endpoint: String, parameters: [String: String]? = nil, apiType: LSNetworkEnvironment.API? = .lonestar) async throws -> T {
        let request = try await createRequest(endpoint: endpoint, method: "DELETE", parameters: parameters, apiType: apiType ?? .lonestar)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check if the response is an HTTP response and get the status code
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                // Success: Proceed to decode the data
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    print("Error = ", error)
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> {
                        print(json)
                    }
                    throw error
                }
            default:
                // Handle other status codes
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> {
                    print(json)
                    var errorMessage = json["details"]
                    if let message = json["message"] {
                        errorMessage = message
                    } else if let detail = json["detail"] {
                        errorMessage = detail
                    }
                    if let message = errorMessage as? String, message.count > 0 {
                        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                    } else {
                        throw NSError(domain: "Invalid Response", code: 0, userInfo: nil)
                    }
                }
                throw NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)
            }
        } else {
            // Handle unexpected response types
            throw NSError(domain: "Invalid Response", code: 0, userInfo: nil)
        }

    }
    
    func generateThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 600)
        DispatchQueue.global().async {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            } catch {
                print("Error generating thumbnail: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    
}

// Helper extension to append Data with strings
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
