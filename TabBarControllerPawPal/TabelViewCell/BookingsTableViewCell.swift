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
        // Basic button styling
        statusButton.layer.cornerRadius = 10
        statusButton.clipsToBounds = true
        statusButton.setTitleColor(.white, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(with request: ScheduleRequest) {
        petNameLabel.text = request.petName
        
        // Format the dates if needed.
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        startDateLabel.text = "\(dateFormatter.string(from: request.startDate))"
        endDateLabel.text = "\(dateFormatter.string(from: request.endDate))"
        
        // Set status button title
        let status = request.status
        statusButton.setTitle(status, for: .normal)
        
        // Instead of changing backgroundColor, update the button’s tintColor.
        switch status {
        case "Pending":
            statusButton.tintColor = .systemOrange
        case "Ongoing":
            statusButton.tintColor = .systemBlue
        case "Completed":
            statusButton.tintColor = .systemGreen
        default:
            statusButton.tintColor = .systemPink
        }
    }
}
