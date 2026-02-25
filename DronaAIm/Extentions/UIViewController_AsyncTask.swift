//
//  UIViewController_AsyncTask.swift
//  DronaAIm
//
//  Extension for UIViewController to simplify async/await task execution
//  with automatic progress indicator management and error handling.
//

import UIKit

extension UIViewController {
    
    /// Executes an async task with automatic progress indicator and error handling
    /// - Parameters:
    ///   - showProgress: Whether to show progress indicator (default: true)
    ///   - progressMessage: Optional message to display in progress indicator
    ///   - task: The async task to execute
    ///   - onSuccess: Optional completion handler called on success
    ///   - onError: Optional error handler (if not provided, shows default error alert)
    func performAsyncTask<T>(
        showProgress: Bool = true,
        progressMessage: String? = nil,
        task: @escaping () async throws -> T,
        onSuccess: ((T) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        if showProgress {
            LSProgress.show(in: self.view, message: progressMessage)
        }
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let result = try await task()
                await MainActor.run {
                    if showProgress {
                        LSProgress.hide(from: self.view)
                    }
                    onSuccess?(result)
                }
            } catch {
                await MainActor.run {
                    if showProgress {
                        LSProgress.hide(from: self.view)
                    }
                    
                    if let customErrorHandler = onError {
                        customErrorHandler(error)
                    } else {
                        // Default error handling
                        let errorMessage = error.userFriendlyMessage
                        UIAlertController.showError(on: self, message: errorMessage)
                        LSLogger.error("Async task failed: \(error)")
                    }
                }
            }
        }
    }
    
    /// Executes an async task that returns Void
    /// - Parameters:
    ///   - showProgress: Whether to show progress indicator (default: true)
    ///   - progressMessage: Optional message to display in progress indicator
    ///   - task: The async task to execute
    ///   - onSuccess: Optional completion handler called on success
    ///   - onError: Optional error handler (if not provided, shows default error alert)
    func performAsyncTask(
        showProgress: Bool = true,
        progressMessage: String? = nil,
        task: @escaping () async throws -> Void,
        onSuccess: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        performAsyncTask(
            showProgress: showProgress,
            progressMessage: progressMessage,
            task: { try await task(); return () },
            onSuccess: { _ in onSuccess?() },
            onError: onError
        )
    }
}

