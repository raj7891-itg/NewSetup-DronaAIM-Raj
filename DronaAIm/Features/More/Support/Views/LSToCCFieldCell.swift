//
//  LSToCCFieldCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 16/07/24.
//
import UIKit

class LSToCCFieldCell: UITableViewCell, UITextFieldDelegate, LSBackspaceTextFieldDelegate {
    private let titleLabel = UILabel()
    private let textField = LSBackspaceTextField()
    private let stackView = UIStackView()
    private var tokenViews: [UIView] = []
    private var backspacePressCount = 0 // Track the number of backspace presses
    
    weak var delegate: TokenFieldCellDelegate?
    
    func configureTo(with placeholder: String, toEmail: String) {
        titleLabel.text = placeholder
        textField.text = toEmail
        textField.isUserInteractionEnabled = false
        setupViews()
    }
    
    func configureCC(with placeholder: String) {
        titleLabel.text = placeholder
//        textField.placeholder = "Mail Id"
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textField.font = UIFont.systemFont(ofSize: 14, weight: .regular)

        textField.delegate = self
        textField.customDelegate = self  // Set custom delegate
        textField.returnKeyType = .done
        
        stackView.axis = .vertical  // Set axis to vertical for multiple lines
        stackView.spacing = 8
        stackView.alignment = .leading  // Align tokens to the left
        stackView.distribution = .fillProportionally
        stackView.addArrangedSubview(textField)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let availableWidth = self.frame.width - titleLabel.frame.width - 30 // 16 + 16 (left and right padding for titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

            stackView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            textField.widthAnchor.constraint(greaterThanOrEqualToConstant: availableWidth)
        ])
    }
    
    // MARK: - Token Creation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let email = textField.text, !email.isEmpty else { return false }
        addToken(email)
        textField.text = ""
        return true
    }
    
    private func addToken(_ text: String) {
        let isValid = text.isValidEmail()
        
        // Create token view
        let tokenView = UIView()
        tokenView.layer.cornerRadius = 12
        tokenView.clipsToBounds = true
        tokenView.backgroundColor = isValid ? .systemBlue : .systemRed
        
        // Label inside the token
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        tokenView.addSubview(label)
        tokenView.translatesAutoresizingMaskIntoConstraints = false
        
        // Insert the token view into the stack
        stackView.insertArrangedSubview(tokenView, at: stackView.arrangedSubviews.count - 1)
        tokenViews.append(tokenView)
        
        // Constraints for the token label
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: tokenView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: tokenView.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: tokenView.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: tokenView.bottomAnchor, constant: -4)
        ])
        
        // Update cell height
        delegate?.heightUpdated()
    }
    
    // MARK: - LSBackspaceTextField
    func didPressBackspaceOnEmpty() {
        backspacePressCount += 1
        if backspacePressCount == 1 {
            // Highlight the last token
            highlightLastTokenBeforeDeleting()
        } else if backspacePressCount == 2 {
            // Delete the last token
            removeLastToken()
            backspacePressCount = 0 // Reset count after deletion
        }
    }
    
    private func highlightLastTokenBeforeDeleting() {
        guard let lastToken = tokenViews.last else { return }
        
        // Highlight the last token
        UIView.animate(withDuration: 0.3, animations: {
            lastToken.backgroundColor = .systemGray // Change the color to highlight
        })
    }
    
    private func removeLastToken() {
        guard let lastToken = tokenViews.popLast() else { return }
        lastToken.removeFromSuperview()
        delegate?.heightUpdated()
    }
    
    // MARK: - Updating Cell Height Dynamically
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        delegate?.heightUpdated()
//    }
    
    func getAllEmails() -> [String] {
        return tokenViews.compactMap { tokenView in
            if let label = tokenView.subviews.compactMap({ $0 as? UILabel }).first {
                return label.text?.lowercased()
            }
            return nil
        }
    }
    
    func endEditing() {
        textField.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("End editing")
        // Create a token for the text in the textField when editing ends
        if let email = textField.text, !email.isEmpty {
            addToken(email)
            textField.text = "" // Optionally clear the text field after adding the token
        }
    }
}

