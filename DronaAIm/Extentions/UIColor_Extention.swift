//
//  UIColor_Extention.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 20/06/24.
//

import Foundation
import UIKit

extension UIColor {
    // Create UIColor from hex string
    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        let r = (color & 0xFF0000) >> 16
        let g = (color & 0x00FF00) >> 8
        let b = color & 0x0000FF
        
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
    
    // Create UIColor from hex string with alpha
    convenience init(hex: String, alpha: CGFloat) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        let r = (color & 0xFF0000) >> 16
        let g = (color & 0x00FF00) >> 8
        let b = color & 0x0000FF
        
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: alpha
        )
    }
}
