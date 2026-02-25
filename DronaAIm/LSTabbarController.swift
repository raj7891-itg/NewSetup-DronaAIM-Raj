//
//  LSTabbarController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 12/06/24.
//

import UIKit

class LSTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        self.navigationController?.navigationBar.isHidden = true
        self.delegate = self

        // Do any additional setup after loading the view.
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(named: "tabbarNornal")
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.backgroundColor = UIColor(named: "appColor")
        self.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension LSTabbarController: UITabBarControllerDelegate {
    // Called when a new tab is selected
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Check if the selected tab requires an API call
        if let selectedVC = tabBarController.viewControllers?.first(where: { $0 == viewController }) {
            if let tripsVC = ((selectedVC as? UINavigationController)?.viewControllers.first) as? LSDTripsListViewController {
                tripsVC.refreshList()
            } else if let eventsVC = ((selectedVC as? UINavigationController)?.viewControllers.first) as? LSDEventsViewController {
                eventsVC.refreshList()
            } else if let dashboardVC = ((selectedVC as? UINavigationController)?.viewControllers.first) as? LSDDashboardViewController {
                dashboardVC.refreshList()
            }
        }
    }

}
