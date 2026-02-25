//
//  CustomTextField.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 16/07/24.
//
import UIKit
protocol LSBackspaceTextFieldDelegate: AnyObject {
    func didPressBackspaceOnEmpty()
}

class LSBackspaceTextField: UITextField {
    weak var customDelegate: LSBackspaceTextFieldDelegate?

    override func deleteBackward() {
        if text?.isEmpty ?? true {
            customDelegate?.didPressBackspaceOnEmpty()
        }
        super.deleteBackward()
    }
}
