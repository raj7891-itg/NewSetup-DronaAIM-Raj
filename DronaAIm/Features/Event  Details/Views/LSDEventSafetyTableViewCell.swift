//
//  LSDEventSafetyTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 01/07/24.
//

import UIKit

class LSDEventSafetyTableViewCell: UITableViewCell {

    @IBOutlet weak var safetyDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(for eventType: LSDAllEventType) {
        safetyDescriptionLabel.text = safetyTip(for: eventType)
    }

}
