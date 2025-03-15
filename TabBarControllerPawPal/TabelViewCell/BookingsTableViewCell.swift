//
//  BookingsTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 03/02/25.
//

import UIKit

class BookingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var arrowButton: UIButton!
    
    var onArrowTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Basic button styling
        statusButton.layer.cornerRadius = 10
        statusButton.clipsToBounds = true
        statusButton.setTitleColor(.white, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(with request: ScheduleCaretakerRequest) {
        petNameLabel.text = request.petName
        
        // Format the dates if needed.
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
//        startDateLabel.text = "\(dateFormatter.string(from: request.startDate))"
//        endDateLabel.text = "\(dateFormatter.string(from: request.endDate))"
        if let start = request.startDate {
                startDateLabel.text = dateFormatter.string(from: start)
            } else {
                startDateLabel.text = ""
            }
            
            if let end = request.endDate {
                endDateLabel.text = dateFormatter.string(from: end)
            } else {
                endDateLabel.text = ""  
            }
        
        // Ensure first letter of status is capitalized
        let formattedStatus = request.status.capitalized
        statusButton.setTitle(formattedStatus, for: .normal)
        

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
    
    @IBAction func arrowButtonTapped(_ sender: UIButton) {
        onArrowTap?()
    }
}
