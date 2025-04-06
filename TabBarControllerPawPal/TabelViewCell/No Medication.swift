//
//  No Medication.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 06/04/25.
//

import UIKit

class No_Medication: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var medicationIconImageView: UIImageView!
    @IBOutlet weak var medicineNameLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        

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
