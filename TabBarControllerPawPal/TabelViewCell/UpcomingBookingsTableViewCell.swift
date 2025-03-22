//
//  UpcomingBookingsTableViewCell.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 21/03/25.
//

import UIKit

class UpcomingBookingsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var caretakerImage: UIImageView!
    @IBOutlet weak var caretakerNameLabel: UILabel!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var callButton: UIImageView!
    @IBOutlet weak var messageButton: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // For the callButton
        let callTap = UITapGestureRecognizer(target: self, action: #selector(callTapped))
        callButton.addGestureRecognizer(callTap)
        callButton.isUserInteractionEnabled = true

        // For the messageButton
        let msgTap = UITapGestureRecognizer(target: self, action: #selector(messageTapped))
        messageButton.addGestureRecognizer(msgTap)
        messageButton.isUserInteractionEnabled = true
    }

    @objc func callTapped() {
        // Typically, you'd notify the view controller via a delegate or closure
        // but you can also just do it if you have direct references.
    }

    @objc func messageTapped() {
        // same as above
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
