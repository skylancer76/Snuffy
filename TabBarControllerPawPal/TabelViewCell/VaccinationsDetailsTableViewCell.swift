//
//  VaccinationsDetailsTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 23/03/25.
//

import UIKit

class VaccinationsDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var syringeIconImageView: UIImageView!
    @IBOutlet weak var vaccineNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Rounded corners for the container
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        
        // Circle for the icon background
        iconBackgroundView.layer.cornerRadius = iconBackgroundView.frame.width / 2
        iconBackgroundView.layer.masksToBounds = true
        
        // Example background color for the circle
        iconBackgroundView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.2)
        
        // If your icon is a template image, you can tint it
        syringeIconImageView.tintColor = .systemPink
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        iconBackgroundView.layer.cornerRadius = iconBackgroundView.frame.width / 2

    }

}
