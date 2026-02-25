//
//  LSOrganizationsListTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 30/06/25.
//

import UIKit

class LSOrganizationsListTableViewCell: UITableViewCell {
    @IBOutlet weak var organizationNameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var greenTickImageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    func config(with org: LSOrgRoleAndScoreMapping?) {
        greenTickImageView.isHidden = true

        if let selected = UserDefaults.standard.selectedOrganization, let orgName = org?.name, orgName == selected.name {
            greenTickImageView.isHidden = false
            containerView.layer.borderColor = UIColor.appGreen.cgColor
            containerView.layer.borderWidth = 2.0
        }

        organizationNameLabel.text = org?.name
        
        let roleDisplayName: String

        switch org?.role {
        case "driver":
            roleDisplayName = "Driver"
        case "fleetManager":
            roleDisplayName = "Fleet Manager"
        case "insurer":
            roleDisplayName = "Insurer"
        case "fleetManagerSuperUser":
            roleDisplayName = "Super Fleet Manager"
        case "insurerSuperUser":
            roleDisplayName = "Super Insurer"
        case "admin":
            roleDisplayName = "DronaAIm Admin"
        default:
            roleDisplayName = org?.role?.capitalized ?? ""
        }
        roleLabel.text = roleDisplayName

    }

}
