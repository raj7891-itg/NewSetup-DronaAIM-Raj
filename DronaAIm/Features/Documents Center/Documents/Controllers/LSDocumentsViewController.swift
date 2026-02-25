//
//  LSDocumentsViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 29/06/24.
//


import UIKit

class LSDocumentsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let viewModel = LSDocumentsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Document Centre"
        // Enable automatic dimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50 // Estimate row height
        tableView.separatorColor = UIColor(hex: "9CACBA ")

        viewModel.onDocumentsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.fetchDocuments()
    }
}

extension LSDocumentsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredDocuments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let document = viewModel.filteredDocuments[indexPath.row]
        let title = document.title
//        let attributedTitle = NSMutableAttributedString(string: title, attributes: [
//            .foregroundColor: UIColor.appTheme // Title color
//        ])
//        let redAsterisk = NSAttributedString(string: " *", attributes: [
//            .foregroundColor: UIColor.appRed // Asterisk color
//        ])
//        attributedTitle.append(redAsterisk)
        cell.textLabel?.text = title

        cell.textLabel?.textColor = UIColor.appTheme
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let photosIdVC = LSDPhotoIdCardsViewController.instantiate(fromStoryboard: .driver)
        if indexPath.row == 0 {
            photosIdVC.idCardType = .drivingLicence
            navigationController?.pushViewController(photosIdVC, animated: true)
        } else if indexPath.row == 1 {
            photosIdVC.idCardType = .other
            navigationController?.pushViewController(photosIdVC, animated: true)
        }
    }
}
