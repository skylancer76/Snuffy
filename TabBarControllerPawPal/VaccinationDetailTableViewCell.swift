//
//  VaccinationDetailTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 19/11/24.
//

import UIKit

class VaccinationDetailTableViewCell: UITableViewCell {

    @IBOutlet var vaccinationDate: UILabel!
    
    @IBOutlet var vaacinationDescription: UILabel!
    @IBOutlet var vaccinationName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
