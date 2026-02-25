//
//  LSPhotoUploadTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 29/06/24.
//

import UIKit

class LSPhotoUploadTableViewCell: UITableViewCell {

    @IBOutlet weak var uploadBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.uploadBackgroundView.addDottedBorder(cornerRadius: 10, borderColor: .appTitle)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
