//
//  LSMoreViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/30/24.
//

import UIKit

class LSMoreViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var options = [LSDProfileModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        options = [LSDProfileModel(title: "Support", thumbnail: UIImage(named: "profile_documentCenter")!)]
//        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    private func setupNavigationBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.logoBarButtonItem()
        let profileButton = UIBarButtonItem.profileBarButtonItem(target: self, action: #selector(showProfileVC))
        let notificationButton = UIBarButtonItem.notificationBarButtonItem(target: self, action: #selector(showNotificationsVC))
        navigationItem.rightBarButtonItems = [profileButton, notificationButton]
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension LSMoreViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSDProfileTableViewCell", for: indexPath) as! LSDProfileTableViewCell
        let model = options[indexPath.row]
        cell.config(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 0 {
            let supportVC = LSSupportViewController.instantiate(fromStoryboard: .driver)
            self.navigationController?.pushViewController(supportVC, animated: true)
        } 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
        
}
