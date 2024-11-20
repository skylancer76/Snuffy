//
//  TopCaretakerTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 17/11/24.
//

import UIKit

class TopCaretakerTableViewCell: UITableViewCell {
    

    @IBOutlet var verifiedLabel: UILabel!
    @IBOutlet var ratingImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var caretakerImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
