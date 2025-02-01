//
//  VaccinationTableViewCell.swift
//  PawPal_PetDetails
//
//  Created by admin19 on 18/11/24.
//

import UIKit

class VaccinationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vaccineNameLabel: UILabel!
    @IBOutlet weak var vaccineTypeLabel: UILabel!
    @IBOutlet weak var dateOfVaccineLabel: UILabel!
    @IBOutlet weak var expiaryDateLabel: UILabel!
    @IBOutlet weak var nextDueDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
