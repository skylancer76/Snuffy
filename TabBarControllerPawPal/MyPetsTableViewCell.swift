//
//  MyPetsTableViewCell.swift
//  PawPal_MyPets_TrackPet
//
//  Created by admin19 on 16/11/24.
//

import UIKit

class MyPetsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var petImageView: UIImageView!
    
    @IBOutlet weak var petNameLabel: UILabel!
    
    @IBOutlet weak var petBreedLabel: UILabel!
    
    @IBOutlet weak var petGenderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
