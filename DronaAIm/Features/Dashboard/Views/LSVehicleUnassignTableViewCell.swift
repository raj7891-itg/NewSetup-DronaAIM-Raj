//
//  LSVehicleUnassignTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/12/24.
//

import UIKit

class LSVehicleUnassignTableViewCell: UITableViewCell {

    @IBOutlet weak var vehicleIdLabel: UILabel!
    @IBOutlet weak var vinLabel: UILabel!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!

    @IBOutlet weak var licencePlateLabel: UILabel!
    
    @IBOutlet weak var changeVehicleButton: UIButton!
    @IBOutlet weak var unassignVehicleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(with vehicle: LSVehicle?) {
        vehicleIdLabel.text = vehicle?.vehicleID ?? "NA"
        vinLabel.text = vehicle?.vin ?? "NA"
        makeLabel.text = vehicle?.make ?? "NA"
        modelLabel.text = vehicle?.model ?? "NA"
        yearLabel.text = vehicle?.year.map { String($0) } ?? "NA"
        licencePlateLabel.text = vehicle?.licencePlateNumber ?? "NA"

    }
}
