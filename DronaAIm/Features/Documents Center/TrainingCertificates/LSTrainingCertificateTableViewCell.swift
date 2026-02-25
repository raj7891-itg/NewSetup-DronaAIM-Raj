//
//  LSTrainingCertificateTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 7/19/24.
//

import UIKit

class LSTrainingCertificateTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var issueDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(with model: LSTrainingCertificateModel) {
        self.titleLabel.text = model.title
        self.sizeLabel.text = model.size
        self.issueDateLabel.text = "Issued Date : \(model.issueDate)"
        self.thumbnailImageView?.image = UIImage(named: "pdf")
    }


}
