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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        statusButton.layer.cornerRadius = 10
        statusButton.clipsToBounds = true
        statusButton.setTitleColor(.white, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configureCell(with request: ScheduleRequest) {
            petNameLabel.text = request.petName
            startDateLabel.text = "Start: \(request.startDate)"
            endDateLabel.text = "End: \(request.endDate)"
            
            // Set status button text and background color
            let status = request.status
            statusButton.setTitle(status, for: .normal)
            
            switch status {
            case "Pending":
                statusButton.backgroundColor = .orange
            case "Ongoing":
                statusButton.backgroundColor = .blue
            case "Completed":
                statusButton.backgroundColor = .green
            default:
                statusButton.backgroundColor = .gray
            }
        }
}
