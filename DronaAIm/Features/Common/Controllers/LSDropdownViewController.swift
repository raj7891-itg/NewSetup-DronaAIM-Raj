//
//  LSDropdownViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/5/24.
//

import Foundation
import UIKit

class LSDropdownViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let tableView = UITableView()

    let months = Calendar.current.monthSymbols
    var selectedMonth: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self

    }

    // MARK: - UITableViewDelegate / UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return months.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = months[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMonth = months[indexPath.row]
        print("Selected month: \(selectedMonth ?? "")")
        dismiss(animated: true, completion: nil)
    }
}
