//
//  DropdownMehu.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 13/02/25.
//
import UIKit
import Foundation

enum GraphFilterType {
    case week, month, year, custom
}

class DropdownMenu: UIView, UITableViewDelegate, UITableViewDataSource {
    
    // Properties
    private let items: [String]
    private let tableView = UITableView()
    private weak var anchorButton: UIButton?
    var type: GraphFilterType?
    
    var onItemSelected: ((String) -> Void)? // Completion handler
    
    // Initialize with items and completion handler
    init(items: [String], anchorButton: UIButton, filterType: GraphFilterType, onItemSelected: @escaping (String) -> Void) {
        self.items = items
        self.anchorButton = anchorButton
        self.type = filterType
        self.onItemSelected = onItemSelected
        super.init(frame: .zero)
        
        setupTableView()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.3) // Transparent background
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        tapGesture.cancelsTouchesInView = false // Allows tableView taps to register
        addGestureRecognizer(tapGesture)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.layer.borderWidth = 1.0
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.backgroundColor = .white
        addSubview(tableView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let anchorButton = anchorButton, let superview = superview else { return }
        frame = superview.bounds
        
        let buttonFrame = anchorButton.convert(anchorButton.bounds, to: superview)
        let dropdownWidth = buttonFrame.width
        let dropdownHeight = min(CGFloat(items.count) * 44, 300) // Limit height
        
        tableView.frame = CGRect(x: buttonFrame.minX, y: buttonFrame.maxY, width: dropdownWidth, height: dropdownHeight)
        tableView.layer.cornerRadius = 8
        tableView.clipsToBounds = true
    }
    
    // Show dropdown in parent view
    func show() {
        if let topController = UIApplication.shared.topViewController() {
            topController.view.addSubview(self)
            frame = topController.view.bounds
        }
        layoutIfNeeded()
    }
    
    @objc private func handleBackgroundTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        if !tableView.frame.contains(location) {
            dismissDropdown()
        }
    }
    
    private func dismissDropdown() {
        removeFromSuperview()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        
        // Call the completion handler **before dismissing**
        onItemSelected?(selectedItem)
        
        // Delay removal slightly to ensure closure executes properly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismissDropdown()
        }
    }
}
