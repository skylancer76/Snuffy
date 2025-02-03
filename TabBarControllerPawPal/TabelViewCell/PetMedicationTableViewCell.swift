//
//  PetMedicationTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 02/02/25.
//

import UIKit

class PetMedicationTableViewCell: UITableViewCell {

    @IBOutlet weak var medicineNameLabel: UILabel!
    @IBOutlet weak var medicineTypeLabel: UILabel!
    @IBOutlet weak var purposeLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var dosageLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
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
