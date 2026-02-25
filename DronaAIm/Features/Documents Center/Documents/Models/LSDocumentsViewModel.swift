//
//  LSDocumentsViewModel.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 29/06/24.
//

import Foundation

class LSDocumentsViewModel {
    private var documents: [LSDocumentModel] = []

    var filteredDocuments: [LSDocumentModel] = [] {
        didSet {
            self.onDocumentsUpdated?()
        }
    }
    
    var onDocumentsUpdated: (() -> Void)?

    func fetchDocuments() {
        // Replace this with real network code to fetch documents
        let mockDocuments = [
//            LSDocumentModel(title: "Photo ID Cards"),
            LSDocumentModel(title: "Driver's License"),
//            LSDocumentModel(title: "Signature"),
            LSDocumentModel(title: "Other")
        ]
        self.documents = mockDocuments
        self.filteredDocuments = mockDocuments
    }

    func filterDocuments(with searchTerm: String) {
        if searchTerm.isEmpty {
            filteredDocuments = documents
        } else {
            filteredDocuments = documents.filter { $0.title.contains(searchTerm) }
        }
    }
}
