//
//  PetProfileTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 12/02/25.
//

import UIKit

class PetProfileTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var petDetailImage: UIImageView!
    @IBOutlet weak var petDetailName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
