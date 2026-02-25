//
//  SubjectFieldCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 16/07/24.
//
import UIKit
class LSSubjectFieldCell: UITableViewCell {
    
    private let textField = UITextField()
    private let titleLabel = UILabel()

    func configure(with placeholder: String, title: String) {
        titleLabel.text = placeholder
        textField.text = title
        setupView()
    }
    
    private func setupView() {
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textField.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        contentView.addSubview(textField)
        contentView.addSubview(titleLabel)

        textField.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let availableWidth = self.frame.width - titleLabel.frame.width - 30 // 16 + 16 (left and right padding for titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

            textField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            textField.widthAnchor.constraint(greaterThanOrEqualToConstant: availableWidth)

        ])
    }
    
    func getSubject() -> String {
        return textField.text ?? ""
    }
}

