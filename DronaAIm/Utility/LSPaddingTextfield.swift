//
//  LSPaddingTextfield.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 10/29/24.
//

import UIKit
@IBDesignable
class LSPaddingTextfield: UITextField {
    
    @IBInspectable var paddingLeft: CGFloat = 10 {
        didSet { updatePadding() }
    }
    @IBInspectable var paddingRight: CGFloat = 10 {
        didSet { updatePadding() }
    }
    @IBInspectable var paddingTop: CGFloat = 0 {
        didSet { updatePadding() }
    }
    @IBInspectable var paddingBottom: CGFloat = 0 {
        didSet { updatePadding() }
    }
    
    private var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    private func updatePadding() {
        padding = UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
    }
}
