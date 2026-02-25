//
//  LSDNotificationsTableView.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 04/12/24.
//

import UIKit

class LSDNotificationsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    private var viewModel: LSDNotificationsViewModel
    
    init(viewModel: LSDNotificationsViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero, style: .plain)
        self.delegate = self
        self.dataSource = self
        self.register(LSDnotificationsTableViewCell.self, forCellReuseIdentifier: LSDnotificationsTableViewCell.identifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        super.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LSDnotificationsTableViewCell.identifier, for: indexPath) as! LSDnotificationsTableViewCell
        let notification = viewModel.notification(at: indexPath.row)
        cell.configure(with: notification)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle cell selection, maybe mark notification as read
    }
}
