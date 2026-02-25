//
//  LSDPhotosListTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 29/06/24.
//

import UIKit

class LSDPhotosListTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(with model: UserDocument) {
        
        self.titleLabel.text = model.fileName
        if let size = Double(model.fileSizeInKB ?? "") {
            let fileSizeInMB = LSCalculation.shared.doubleFormatTwoChars(score: size / 1024)
            self.subTitleLabel.text = "\(fileSizeInMB) MB"
        }
        if model.contentType == "image/jpg" {
            self.imageView?.image = UIImage(named: "jpg")
        } else if model.contentType == "image/jpeg" {
            self.imageView?.image = UIImage(named: "jpg")
        } else if model.contentType == "application/pdf" {
            self.imageView?.image = UIImage(named: "pdf")
        }  else if model.contentType == "image/png" {
            self.imageView?.image = UIImage(named: "png")
        }
    }

}
