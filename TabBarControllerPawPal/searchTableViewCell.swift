//
//  searchTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 13/11/24.
//

import UIKit

class searchTableViewCell: UITableViewCell {

    
    @IBOutlet var rating: UIImageView!
    @IBOutlet var distance: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var profileImageName: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
