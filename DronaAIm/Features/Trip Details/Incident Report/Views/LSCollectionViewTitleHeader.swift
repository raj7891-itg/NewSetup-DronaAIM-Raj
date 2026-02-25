//
//  LSCollectionViewTitleHeader.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/15/24.
//

import Foundation
import UIKit

class LSCollectionViewTitleHeader: UICollectionReusableView {
    static let identifier = "LSCollectionViewTitleHeader"
    
     private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        
        // Set up constraints for the label
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
