//
//  My Bookings Cell.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 31/12/24.
//

import UIKit

class My_Bookings_Cell: UITableViewCell {

    
    @IBOutlet var cellView: UIView!
    @IBOutlet var date: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
