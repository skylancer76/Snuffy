//
//  DogwalkerBookingsTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 11/03/25.
//

import UIKit

class DogwalkerBookingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var petBreedLabel: UILabel!
    @IBOutlet weak var petOwnerLabel: UILabel!
    @IBOutlet weak var petDurationLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        petImage.layer.cornerRadius = 8
        petImage.clipsToBounds = true
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
}
