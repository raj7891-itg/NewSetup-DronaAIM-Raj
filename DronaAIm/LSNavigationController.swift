//
//  LSNavigationController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/30/24.
//

import Foundation
import UIKit

class LSNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarItems()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupNavigationBarItems() {
        // Create the logo button
        let logoImage = UIImage(named: "appIcon_200") // Replace with your logo image name
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .white
        logoImageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let logoBarButtonItem = UIBarButtonItem(customView: logoImageView)
        
        
        let profile = UIBarButtonItem(image: UIImage(named: "profile"), style: .plain, target: self, action: #selector(showProfileVC))
        
        let notification = UIBarButtonItem(image: UIImage(systemName: "bell.fill"), style: .plain, target: self, action: #selector(showNotificationsVC))
        
        // Set the right bar button items
        navigationItem.rightBarButtonItems = [profile, notification]
    }
}
