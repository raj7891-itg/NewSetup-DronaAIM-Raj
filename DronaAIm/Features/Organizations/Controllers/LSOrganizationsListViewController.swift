//
//  LSOrganizationsListViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 30/06/25.
//

import UIKit

class LSOrganizationsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var organizations: [LSOrgRoleAndScoreMapping] = []
    var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Choose an Organization "
        fetchUserDetails()
        // Do any additional setup after loading the view.
    }

    private func fetchUserDetails() {
        Task {
            LSProgress.show(in: self.view)
            let currentUser = try await LSNetworkManager.shared.currentUser()
            let userId = currentUser.userId
            
            // Call Api to fetch User Information
            let endpoint = LSAPIEndpoints.userDetails(for: userId)
            let userDetails: LSUserDetailsModel = try await LSNetworkManager.shared.get(endpoint, apiType: .analytics)
            organizations = userDetails.orgRoleAndScoreMapping
                .filter { $0.role == "driver" }
            self.tableView.reloadData()
            LSProgress.hide(from: self.view)
        }
    }

}

extension LSOrganizationsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if organizations.count > 0 {
            return self.tableView(tableView, tripsCellForRowAt: indexPath)
        }
        return self.tableView(tableView, noDataCellForRowAt: indexPath)

    }
    
    func tableView(_ tableView: UITableView, tripsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSOrganizationsListTableViewCell", for: indexPath) as? LSOrganizationsListTableViewCell else {
            return UITableViewCell()
        }
    
        let org = self.organizations[indexPath.row]
        cell.config(with: org)

        return cell
    }
    
    func tableView(_ tableView: UITableView, noDataCellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let noDataFound = UILabel.init(frame: tableView.bounds)
        noDataFound.backgroundColor = .appBackground
        noDataFound.text = "No vehicles available"
        noDataFound.textAlignment = .center
        noDataFound.textColor = .lightGray
        cell.addSubview(noDataFound)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let org = self.organizations[indexPath.row]
        if org.policyDetails.first?.isActive ?? false  {
            if org.role == "driver" {
                UserDefaults.standard.selectedOrganization = org
                DispatchQueue.main.async {
                    let tabbarController = LSTabbarController.instantiate(fromStoryboard: .driver)
                    let navigationController = UINavigationController(rootViewController: tabbarController)
                    if let window = UIApplication.shared.keyWindow {
                        window.rootViewController = navigationController
                    }
                }
            } else {
                UIAlertController.showError(on: self, message: "Unauthorized user")
            }
            
        } else if let message = org.policyDetails.first?.message {
            UIAlertController.showError(on: self, message: message)
        }
        

    }
    
}
