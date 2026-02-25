//
//  LSVehiclesTableViewCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 9/11/24.
//

import UIKit

protocol LSVehiclesCellDelegate: AnyObject {
    func didPressRadioButton(indexPath: IndexPath)
}


class LSVehiclesTableViewCell: UITableViewCell {
    weak var delegate: LSVehiclesCellDelegate?

    @IBOutlet weak var vehicleIdLabel: UILabel!
    
    @IBOutlet weak var vinLabel: UILabel!
    @IBOutlet weak var makeLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var licencePlateLabel: UILabel!
    @IBOutlet weak var radioButton: UIButton!

    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(with vehicle: LSVehicle?, isSelected: Bool, indexPath: IndexPath) {
        self.indexPath = indexPath
        if let isDriverAssigned = vehicle?.driverID {
            self.contentView.alpha = 0.5 // Fades the entire cell
            radioButton.setImage( UIImage(named: "assigned"), for: .normal)
        } else {
            self.contentView.alpha = 1 // Fades the entire cell
            updateRadioButton(isSelected: isSelected)
        }
        
        vehicleIdLabel.text = vehicle?.vehicleID ?? "NA"
        vinLabel.text = vehicle?.vin ?? "NA"
        makeLabel.text = vehicle?.make ?? "NA"
        modelLabel.text = vehicle?.model ?? "NA"
        yearLabel.text = vehicle?.year.map { String($0) } ?? "NA"
        licencePlateLabel.text = vehicle?.licencePlateNumber ?? "NA"
    }
    
    @IBAction func radioButtonAction(_ sender: Any) {
        if let indexP = self.indexPath {
            self.delegate?.didPressRadioButton(indexPath: indexP)
        }
    }
    
    // Update the radio button's appearance
        private func updateRadioButton(isSelected: Bool) {
            let buttonImage = isSelected ? UIImage(systemName: "circle.circle") : UIImage(systemName: "circle")
            radioButton.setImage(buttonImage, for: .normal)
        }

}
