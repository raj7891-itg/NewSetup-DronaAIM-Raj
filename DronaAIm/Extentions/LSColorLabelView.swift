//
//  LSColorLabelView.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 10/06/24.
//

import UIKit

class LSColorLabelView: UIView {

    private let colorCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5 // Half of the height and width to make it a circle
        view.layer.masksToBounds = true
        return view
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()

    init(color: UIColor, text: String) {
        super.init(frame: .zero)
        setupView(color: color, text: text)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(color: .clear, text: "")
    }

    private func setupView(color: UIColor, text: String) {
        addSubview(colorCircle)
        addSubview(label)

        colorCircle.backgroundColor = color
        label.text = text

        NSLayoutConstraint.activate([
            colorCircle.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorCircle.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorCircle.widthAnchor.constraint(equalToConstant: 10),
            colorCircle.heightAnchor.constraint(equalToConstant: 10),

            label.leadingAnchor.constraint(equalTo: colorCircle.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

