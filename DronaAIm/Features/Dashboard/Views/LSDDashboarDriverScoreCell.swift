//
//  LSDDashboarDriverScoreCell.swift
//  DronaAIm
//
//  Created by Siva Kumar Reddy on 8/5/24.
//

import UIKit

class LSDDashboarDriverScoreCell: UITableViewCell {
    
    struct Model {
        let progress: Float
        let score: Int
    }
    
    var model: Model? {
        didSet {
            applyModel()
        }
    }
    
    private func applyModel() {
        // bindind
    }

    @IBOutlet weak var circularProgressbar: LSHalfCirclularProgress!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var driverBadge: UIImageView!
    
    @IBOutlet weak var driverBadgeTextLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with scoreModel: LSDriverScoreModel) {
        if let score = scoreModel.cummulativeScore {
            let percentage: Double = 75.0
            let scoreAt75 = (score * percentage) / 100
            print(scoreAt75)

            let driverScore = LSCalculation.shared.doubleFormat(score: score)
            driverBadge.image = UIImage(named: "fairDriver")
            driverBadgeTextLabel.text = "Fair Driver"
            var scoreColor = UIColor.appRed
            let scoreFloor = floor(score)
            if scoreFloor >= 90 {
                scoreColor = UIColor.appGreen
                driverBadge.image = UIImage(named: "bestDriver.icon")
                driverBadgeTextLabel.text = "Best Driver"
            } else if scoreFloor >= 80 && scoreFloor <= 89 {
                scoreColor = UIColor.appYellow
                driverBadge.image = UIImage(named: "goodDriver")
                driverBadgeTextLabel.text = "Good Driver"
            }
            circularProgressbar.tintColor = scoreColor
            scoreLabel.text = driverScore
            circularProgressbar.setProgress(to: scoreAt75/100, strokeColor: scoreColor, withAnimation: true)
        } else {
            scoreLabel.text = "NA"
        }
    }

}
