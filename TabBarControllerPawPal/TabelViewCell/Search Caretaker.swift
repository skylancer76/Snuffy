//
//  Search Caretaker.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 16/12/24.
//

import UIKit

class Search_CaretakerCell: UITableViewCell {

    @IBOutlet weak var caretakerImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var PriceLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
