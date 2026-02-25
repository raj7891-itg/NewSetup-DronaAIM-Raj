//
//  LSTrainingCertViewController.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 7/19/24.
//

import UIKit
import QuickLook

class LSTrainingCertViewController: UIViewController {
    var viewModel = LSTrainingCertificateViewModel()
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Training Certificates"
        fetchCertificates()
        // Do any additional setup after loading the view.
    }
    
    private func fetchCertificates() {
        viewModel.fetchTrainingCertificates { certificates in
            self.tableView.reloadData()
        }
    }
 
}
extension LSTrainingCertViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSTrainingCertificateTableViewCell", for: indexPath) as? LSTrainingCertificateTableViewCell else {
            return UITableViewCell()
        }
        
        let model = viewModel.model(at: indexPath.row)
        cell.config(with: model)
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
            let quickLookViewController = QLPreviewController()
            quickLookViewController.dataSource = self
            quickLookViewController.delegate = self
            quickLookViewController.currentPreviewItemIndex = indexPath.row
            self.navigationController?.present(quickLookViewController, animated: true)
    }
}

// MARK: - QLPreviewControllerDataSource
extension LSTrainingCertViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        viewModel.numberOfRows()
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let item = viewModel.model(at: index)
         let fileUrl = item.fileUrl
        return fileUrl as NSURL
    }
}

// MARK: - QLPreviewControllerDelegate
extension LSTrainingCertViewController: QLPreviewControllerDelegate {
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        .disabled
    }
    
    func previewController(_ controller: QLPreviewController, didUpdateContentsOf previewItem: QLPreviewItem) {
        
    }
    
}
