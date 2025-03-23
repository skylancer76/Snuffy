//
//  PetsMedicationDetailsTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 24/03/25.
//

import UIKit

class PetsMedicationDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var medicationIconImageView: UIImageView!
    
    @IBOutlet weak var medicineNameLabel: UILabel!
    @IBOutlet weak var medicineTypeLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        
        // Circular icon background
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

