//
//  BodyFieldCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 16/07/24.
//
import UIKit


class LSBodyFieldCell: UITableViewCell, UITextViewDelegate {
    
    private let textView = UITextView()
    
    func configure(with userdetails: LSUserDetailsModel, tableView: UITableView) {
        setupView(tableView: tableView)
        placeholderbody(userdetails: userdetails)
    }
    
    private func setupView(tableView: UITableView) {
        textView.delegate = self
        textView.textColor = .black
        textView.font = .systemFont(ofSize: 14)
        
        contentView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        let minRowHeight: CGFloat = 55
            let sections = tableView.numberOfSections
            let height =  tableView.frame.size.height  - (CGFloat(sections) * minRowHeight)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
        ])
    }
    
    private func placeholderbody(userdetails: LSUserDetailsModel) {
        guard let selectedOrganization = UserDefaults.standard.selectedOrganization else { return }
        guard let lonestarId = selectedOrganization.lonestarId else { return }

        var body = """
           Dear Support Team,

           We are experiencing an issue with [briefly describe the issue, e.g., "accessing telematics reports"].

           • Driver ID: \(userdetails.userId) 
           """

           // Conditionally add Driver Name if it exists
        if let driverName = userdetails.fullName, !driverName.isEmpty {
               body += "\n• Driver Name: \(driverName)"
           }

           // Add the remaining lines
           body += "\n"
           body += """
           • DronaAIm Id: \(lonestarId)
           • Issue Description: [Provide a few details of the problem]
           • Date/Time of Issue: [When the issue occurred]
           • Urgency: [High/Low]

           Thank you.

           Best regards,
           [Your Name]
           [Your Position]
           [Company Name]
           [Contact Information]
           """

           // Convert the body into an attributed string
           let attributedString = NSMutableAttributedString(string: body)
        attributedString.addAttributes([.font: UIFont.systemFont(ofSize: textView.font?.pointSize ?? 14)], range: NSRange(location: 0, length: body.count))

           // Apply bold formatting to specific labels
           let boldAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: textView.font?.pointSize ?? 14)]
        let labelsToBold = ["Driver ID:", "Driver Name:", "DronaAIm Id:", "Issue Description:", "Date/Time of Issue:", "Urgency:"]

           for label in labelsToBold {
               if let range = body.range(of: label) {
                   let nsRange = NSRange(range, in: body)
                   attributedString.addAttributes(boldAttributes, range: nsRange)
               }
           }

           // Set the attributed text to the text view
           textView.attributedText = attributedString
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == .lightGray {
//            textView.text = nil
//            textView.textColor = .black
//        }
//    }
//    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = "Message"
//            textView.textColor = .lightGray
//        }
//    }
    
    func getBodyString() -> String {
        return textView.text ?? ""
    }
}

class LSAttachmentCell: UITableViewCell {
}
