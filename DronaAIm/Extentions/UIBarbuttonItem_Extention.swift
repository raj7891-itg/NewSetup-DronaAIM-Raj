//
//  UIBarbuttonItem_Extention.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/30/24.
//

import Foundation
import UIKit

extension UIBarButtonItem {

    static func logoBarButtonItem() -> UIBarButtonItem {
        let logoImage = UIImage(named: "app_nav_logo") // Replace with your logo image name
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .white
        logoImageView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        return UIBarButtonItem(customView: logoImageView)
    }
    
    static func profileBarButtonItem(target: Any?, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "profile"), for: .normal)
        button.tintColor = .white
        
        let size: CGFloat = 30
        button.frame = CGRect(x: 0, y: 0, width: size, height: size)
        button.layer.cornerRadius = size / 2
        button.clipsToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        
        if let userDetails = UserDefaults.standard.userDetails,
           let profileUrl = userDetails.signedUrl {
            button.sd_setImage(
                with: URL(string: profileUrl),
                for: .normal,
                placeholderImage: UIImage(named: "profile"),
                context: nil
            )
        }
        
        button.addTarget(target, action: action, for: .touchUpInside)
        
        // ✅ Wrap inside a fixed-size container
        let container = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        container.addSubview(button)
        
        return UIBarButtonItem(customView: container)
    }

    static func notificationBarButtonItem(target: Any?, action: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(systemName: "bell.fill"), style: .plain, target: target, action: action)
    }
}
