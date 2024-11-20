//
//  MyBookingTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 14/11/24.
//

import UIKit

class MyBookingTableViewCell: UITableViewCell {

    @IBOutlet var date: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var image1: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
