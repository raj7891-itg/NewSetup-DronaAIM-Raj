//
//  LSDProfileTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/8/24.
//

import UIKit

struct LSDProfileModel {
    var title: String
    var thumbnail: UIImage
}
class LSDProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(with model: LSDProfileModel) {
        self.thumbnailImageView.image = model.thumbnail
        self.titleLabel.text = model.title
    }

}
