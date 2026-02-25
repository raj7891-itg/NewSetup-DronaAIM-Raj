//
//  Error_UserFriendly.swift
//  DronaAIm
//
//  Extension for Error to provide user-friendly error messages
//

import Foundation

extension Error {
    
    /// Returns a user-friendly error message for display to users
    var userFriendlyMessage: String {
        // If it's an NSError with a localized description, use it
        if let nsError = self as NSError? {
            // First, check if there's a user-friendly message in userInfo
            if let message = nsError.userInfo[NSLocalizedDescriptionKey] as? String, !message.isEmpty {
                return message
            }
            
            // Map common error codes to user-friendly messages
            switch nsError.code {
            case -1009:
                return "No internet connection. Please check your network and try again."
            case -1001:
                return "Request timed out. Please try again."
            case -1004:
                return "Could not connect to server. Please try again later."
            case -1005:
                return "Network connection was lost. Please check your connection."
            case -1200:
                return "SSL connection error. Please try again."
            case -1202:
                return "SSL certificate error. Please contact support."
            case 401:
                return "Authentication failed. Please log in again."
            case 403:
                return "Access denied. You don't have permission to perform this action."
            case 404:
                return "The requested resource was not found."
            case 500...599:
                return "Server error. Please try again later."
            default:
                // Check error domain for more specific messages
                if nsError.domain == "HTTPError" {
                    return "An error occurred. Please try again."
                } else if nsError.domain.contains("Network") {
                    return "Network error. Please check your connection and try again."
                }
            }
        }
        
        // Fallback to localized description
        let localizedDesc = self.localizedDescription
        if !localizedDesc.isEmpty && localizedDesc != "The operation couldn't be completed." {
            return localizedDesc
        }
        
        // Final fallback
        return "Something went wrong. Please try again."
    }
}

