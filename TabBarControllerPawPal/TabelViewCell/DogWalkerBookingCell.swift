//
//  DogWalkerBookingCell.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 13/02/25.
//

import UIKit

class DogWalkerBookingCell: UITableViewCell {
    
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var bgView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(with request: ScheduleDogWalkerRequest) {
        petNameLabel.text = request.petName
        
        
        statusButton.setTitle(request.status, for: .normal)
            var config = statusButton.configuration ?? UIButton.Configuration.filled()
            switch request.status {
            case "pending":
                config.baseBackgroundColor = .systemRed
            case "accepted":
                config.baseBackgroundColor = .systemBlue
            case "ongoing":
                config.baseBackgroundColor = .systemYellow
            case "completed":
                config.baseBackgroundColor = .systemGreen
            default:
                config.baseBackgroundColor = .gray
            }
            config.baseForegroundColor = .white
            statusButton.configuration = config
    }

}
