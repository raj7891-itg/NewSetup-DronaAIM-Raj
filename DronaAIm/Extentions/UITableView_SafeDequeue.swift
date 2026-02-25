//
//  UITableView_SafeDequeue.swift
//  DronaAIm
//
//  Extension for UITableView to safely dequeue cells without force casting
//

import UIKit

// Protocol to access UIKit's original method
private protocol UITableViewUIKitMethods {
    func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell
}

extension UITableView: UITableViewUIKitMethods {}

extension UITableView {
    
    /// Safely dequeues a reusable cell of the specified type
    /// - Parameters:
    ///   - type: The cell type to dequeue
    ///   - identifier: The reuse identifier (defaults to type name)
    ///   - indexPath: The index path for the cell
    /// - Returns: A cell of the specified type, or nil if casting fails
    func dequeueReusableCell<T: UITableViewCell>(
        ofType type: T.Type,
        withIdentifier identifier: String? = nil,
        for indexPath: IndexPath
    ) -> T? {
        let cellIdentifier = identifier ?? String(describing: type)
        // Call UIKit's original method through protocol to avoid recursion
        let cell = (self as UITableViewUIKitMethods).dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        guard let typedCell = cell as? T else {
            LSLogger.error("Failed to cast cell to \(String(describing: type)) with identifier: \(cellIdentifier)")
            return nil
        }
        
        return typedCell
    }
    
    /// Safely dequeues a reusable cell of the specified type, with fallback
    /// - Parameters:
    ///   - type: The cell type to dequeue
    ///   - identifier: The reuse identifier (defaults to type name)
    ///   - indexPath: The index path for the cell
    ///   - fallback: A closure to create a fallback cell if dequeue fails
    /// - Returns: A cell of the specified type
    func dequeueReusableCell<T: UITableViewCell>(
        ofType type: T.Type,
        withIdentifier identifier: String? = nil,
        for indexPath: IndexPath,
        fallback: () -> T
    ) -> T {
        // Use the safe dequeue method we defined above
        if let cell = dequeueReusableCell(ofType: type, withIdentifier: identifier, for: indexPath) {
            return cell
        }
        LSLogger.warning("Using fallback cell for \(String(describing: type))")
        return fallback()
    }
}

// Protocol to access UIKit's original method for UICollectionView
private protocol UICollectionViewUIKitMethods {
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell
}

extension UICollectionView: UICollectionViewUIKitMethods {}

extension UICollectionView {
    
    /// Safely dequeues a reusable cell of the specified type
    /// - Parameters:
    ///   - type: The cell type to dequeue
    ///   - identifier: The reuse identifier (defaults to type name)
    ///   - indexPath: The index path for the cell
    /// - Returns: A cell of the specified type, or nil if casting fails
    func dequeueReusableCell<T: UICollectionViewCell>(
        ofType type: T.Type,
        withIdentifier identifier: String? = nil,
        for indexPath: IndexPath
    ) -> T? {
        let cellIdentifier = identifier ?? String(describing: type)
        // Call UIKit's original method through protocol to avoid recursion
        let cell = (self as UICollectionViewUIKitMethods).dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        
        guard let typedCell = cell as? T else {
            LSLogger.error("Failed to cast collection view cell to \(String(describing: type)) with identifier: \(cellIdentifier)")
            return nil
        }
        
        return typedCell
    }
}
