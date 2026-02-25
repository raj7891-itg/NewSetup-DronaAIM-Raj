//
//  LSTrainingCertificateViewModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 7/19/24.
//

import Foundation

class LSTrainingCertificateViewModel {
    private var certificates = [LSTrainingCertificateModel]()
    
    func fetchTrainingCertificates(completion: @escaping ([LSTrainingCertificateModel]) -> Void) {
        let bundleURL = Bundle.main.url(forResource: "training_certificate", withExtension: "pdf")
         certificates = [
            LSTrainingCertificateModel(title: "Training Certificate Sample 1.pdf", size: "1.09 MB", issueDate: "Jan 2, 2024", fileUrl: bundleURL!),
            LSTrainingCertificateModel(title: "Training Certificate Sample 2.pdf", size: "1.09 MB", issueDate: "Feb 2, 2024", fileUrl: bundleURL!),
            LSTrainingCertificateModel(title: "Training Certificate Sample 3.pdf", size: "1.09 MB", issueDate: "Mar 12, 2024", fileUrl: bundleURL!),
            LSTrainingCertificateModel(title: "Training Certificate Sample 4.pdf", size: "1.09 MB", issueDate: "Apr 20, 2024", fileUrl: bundleURL!),
            LSTrainingCertificateModel(title: "Training Certificate Sample 5.pdf", size: "1.09 MB", issueDate: "May 12, 2024", fileUrl: bundleURL!)
        ]
        completion(certificates)
    }
    
    func numberOfRows() -> Int {
        return certificates.count
    }
    
    func model(at index: Int) -> LSTrainingCertificateModel {
        return certificates[index]
    }
}
