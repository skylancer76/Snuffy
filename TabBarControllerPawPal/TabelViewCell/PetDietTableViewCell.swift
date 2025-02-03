//
//  PetDietTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 02/02/25.
//

import UIKit

class PetDietTableViewCell: UITableViewCell {

    @IBOutlet weak var mealTypeLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodCategoryLabel: UILabel!
    @IBOutlet weak var portionSizeLabel: UILabel!
    @IBOutlet weak var feedingFrequencyLabel: UILabel!
    @IBOutlet weak var servingTimeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
