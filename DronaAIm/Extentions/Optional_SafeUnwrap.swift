//
//  Optional_SafeUnwrap.swift
//  DronaAIm
//
//  Extension for Optional to provide safe unwrapping with logging
//

import Foundation

extension Optional {
    
    /// Safely unwraps the optional, logging an error if nil
    /// - Parameters:
    ///   - file: The file name (automatically captured)
    ///   - function: The function name (automatically captured)
    ///   - line: The line number (automatically captured)
    ///   - message: Optional custom error message
    /// - Returns: The unwrapped value, or nil if unwrapping fails
    func safeUnwrap(
        file: String = #file,
        function: String = #function,
        line: Int = #line,
        message: String? = nil
    ) -> Wrapped? {
        if self == nil {
            let errorMessage = message ?? "Force unwrap failed"
            let fileName = (file as NSString).lastPathComponent
            LSLogger.error("\(errorMessage) in \(fileName):\(line) \(function)")
        }
        return self
    }
    
    /// Safely unwraps the optional, throwing an error if nil
    /// - Parameters:
    ///   - error: The error to throw if unwrapping fails
    /// - Returns: The unwrapped value
    /// - Throws: The provided error if unwrapping fails
    func unwrapOrThrow(_ error: Error) throws -> Wrapped {
        guard let value = self else {
            throw error
        }
        return value
    }
}

/// Safely casts a value to the specified type
/// - Parameters:
///   - value: The value to cast
///   - type: The target type
///   - file: The file name (automatically captured)
///   - function: The function name (automatically captured)
///   - line: The line number (automatically captured)
/// - Returns: The casted value, or nil if casting fails
func safeCast<T>(
    _ value: Any,
    to type: T.Type,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) -> T? {
    guard let casted = value as? T else {
        let fileName = (file as NSString).lastPathComponent
        LSLogger.error("Force cast failed in \(fileName):\(line) \(function) - Expected \(String(describing: type))")
        return nil
    }
    return casted
}

