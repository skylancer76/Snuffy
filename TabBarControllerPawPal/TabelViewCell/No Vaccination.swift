//
//  No Vaccination.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 06/04/25.
//

import UIKit

class No_Vaccination: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var syringeIconImageView: UIImageView!
    @IBOutlet weak var novaccination: UILabel!



    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        
        
        iconBackgroundView.layer.cornerRadius = iconBackgroundView.frame.width / 2
        iconBackgroundView.layer.masksToBounds = true
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        iconBackgroundView.layer.cornerRadius = iconBackgroundView.frame.width / 2
    }

}
