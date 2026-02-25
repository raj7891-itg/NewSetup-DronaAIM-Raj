//
//  LSDBottomBar.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 04/12/24.
//

import Foundation
import UIKit

class LSDBottomBar: UIView {

    private var readAllButton: UIButton!
    private var hideButton: UIButton!
    private var unhideButton: UIButton!
    private var bottomBarDelegate: LSDBottomBarDelegate?
    private lazy var bottomBar: UIToolbar = {
            let toolbar = UIToolbar()
            toolbar.isHidden = true
            return toolbar
        }()

    init(frame: CGRect, delegate: LSDBottomBarDelegate) {
        super.init(frame: frame)
        self.bottomBarDelegate = delegate
        setupBottomBar()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBottomBar()
    }

    private func setupBottomBar() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -44)
        ])
    }

    @objc private func didTapReadAll() {
        bottomBarDelegate?.didTapReadAllButton()
    }

    @objc private func didTapHide() {
        bottomBarDelegate?.didTapHideButton()
    }

    @objc private func didTapUnhide() {
        bottomBarDelegate?.didTapUnhideButton()
    }
}

protocol LSDBottomBarDelegate {
    func didTapReadAllButton()
    func didTapHideButton()
    func didTapUnhideButton()
}
