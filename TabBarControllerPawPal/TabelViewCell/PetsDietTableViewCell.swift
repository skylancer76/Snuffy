//
//  PetsDietTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 24/03/25.
//

import UIKit

class PetsDietTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var mealIconImageView: UIImageView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var mealTypeLabel: UILabel!
    @IBOutlet weak var servingTimeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        
        // Circle for the icon background
        iconBackgroundView.layer.cornerRadius = iconBackgroundView.frame.width / 2
        iconBackgroundView.layer.masksToBounds = true
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
