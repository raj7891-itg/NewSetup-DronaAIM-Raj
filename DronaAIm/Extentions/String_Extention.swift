//
//  String_Extention.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 22/11/24.
//
import UIKit

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }
    var isValidPassword: Bool {
        // Minimum length of 8 characters
        guard self.count >= 8 else { return false }
        
        // Contains at least 1 number
        let hasNumber = self.range(of: "[0-9]", options: .regularExpression) != nil
        
        // Contains at least 1 special character
        let hasSpecialCharacter = self.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
        
        // Contains at least 1 uppercase letter
        let hasUppercase = self.range(of: "[A-Z]", options: .regularExpression) != nil
        
        // Contains at least 1 lowercase letter
        let hasLowercase = self.range(of: "[a-z]", options: .regularExpression) != nil
        
        return hasNumber && hasSpecialCharacter && hasUppercase && hasLowercase
    }
    
    func generateProfileCircularImage() -> UIImage? {
        let size = CGSize(width: 32, height: 32) // Adjust as needed
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Draw black circle
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.setFillColor(UIColor.black.cgColor)
            context.cgContext.fill(rect)
            
            // Draw first character
            if let initial = self.first {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 14),
                    .foregroundColor: UIColor.white
                ]
                let charString = String(initial).uppercased()
                let textSize = charString.size(withAttributes: attributes)
                let textRect = CGRect(
                    x: (size.width - textSize.width) / 2,
                    y: (size.height - textSize.height) / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                charString.draw(in: textRect, withAttributes: attributes)
            }
        }
        
        return image
    }
    
    func generateProfileSquareImage() -> UIImage? {
        let size = CGSize(width: 60, height: 60) // Adjust as needed
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Draw black circle
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.setFillColor(UIColor.black.cgColor)
            context.cgContext.fill(rect)
            
            // Draw first character
            if let initial = self.first {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.white
                ]
                let charString = String(initial).uppercased()
                let textSize = charString.size(withAttributes: attributes)
                let textRect = CGRect(
                    x: (size.width - textSize.width) / 2,
                    y: (size.height - textSize.height) / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                charString.draw(in: textRect, withAttributes: attributes)
            }
        }
        
        return image
    }
    
}
