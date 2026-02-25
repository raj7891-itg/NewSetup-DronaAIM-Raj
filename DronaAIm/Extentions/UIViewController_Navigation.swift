//
//  UIViewController_Navigation.swift
//  DronaAIm
//
//  Extension for UIViewController to provide common navigation methods
//  Eliminates code duplication across multiple view controllers
//

import UIKit

extension UIViewController {
    
    /// Navigates to the Notifications view controller
    /// Can be used as @objc selector for bar button items
    @objc func showNotificationsVC() {
        let notificationsVC = LSDNotificationsViewController.instantiate(fromStoryboard: .driver)
        notificationsVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(notificationsVC, animated: true)
    }
    
    /// Navigates to the Profile view controller
    /// Can be used as @objc selector for bar button items
    @objc func showProfileVC() {
        let profileVC = LSDProfileViewController.instantiate(fromStoryboard: .driver)
        profileVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}

