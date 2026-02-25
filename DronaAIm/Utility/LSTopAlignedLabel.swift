//
//  LSTopAlignedLabel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/9/24.
//

import Foundation
import UIKit

@IBDesignable
class LSTopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        // Calculate the size of the text
        guard let text = self.text else {
            super.drawText(in: rect)
            return
        }
        
        // Get the text's bounding rect considering the label's settings
        let textRect = text.boundingRect(
            with: CGSize(width: rect.width, height: CGFloat.greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: self.font ?? UIFont.systemFont(ofSize: 17)],
            context: nil
        )
        
        // Adjust the rect to start from the top
        var newRect = rect
        newRect.size.height = ceil(textRect.size.height)
        
        // Draw the text in the new rect
        super.drawText(in: newRect)
    }
    
    override var intrinsicContentSize: CGSize {
        // Calculate the size based on the text content
        let size = super.intrinsicContentSize
        let textHeight = sizeThatFits(CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        return CGSize(width: size.width, height: textHeight)
    }
}
