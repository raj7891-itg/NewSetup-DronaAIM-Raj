//
//  LSLogger.swift
//  DronaAIm
//
//  Centralized logging utility for the application.
//  Provides different log levels and integrates with Firebase Crashlytics for production errors.
//

import Foundation
import FirebaseCrashlytics

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

class LSLogger {
    
    /// Logs a message with the specified level
    /// - Parameters:
    ///   - level: The log level (debug, info, warning, error)
    ///   - message: The message to log
    ///   - file: The file name (automatically captured)
    ///   - function: The function name (automatically captured)
    ///   - line: The line number (automatically captured)
    static func log(
        _ level: LogLevel,
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.emoji) [\(level.rawValue)] \(fileName):\(line) \(function) - \(message)"
        
        #if DEBUG
        // In debug mode, print to console
        print(logMessage)
        #else
        // In production, only log warnings and errors
        if level == .warning || level == .error {
            print(logMessage)
            
            // Send errors to Crashlytics
            if level == .error {
                Crashlytics.crashlytics().log("\(fileName):\(line) \(function) - \(message)")
            }
        }
        #endif
    }
    
    /// Convenience method for debug logs
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message, file: file, function: function, line: line)
    }
    
    /// Convenience method for info logs
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message, file: file, function: function, line: line)
    }
    
    /// Convenience method for warning logs
    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message, file: file, function: function, line: line)
    }
    
    /// Convenience method for error logs
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message, file: file, function: function, line: line)
    }
    
    /// Logs an error object
    static func error(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        let errorMessage = "\(error.localizedDescription)"
        log(.error, errorMessage, file: file, function: function, line: line)
        
        #if !DEBUG
        // Send error details to Crashlytics in production
        Crashlytics.crashlytics().record(error: error)
        #endif
    }
}

