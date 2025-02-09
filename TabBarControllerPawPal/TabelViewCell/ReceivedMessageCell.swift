//
//  ReceivedMessageCell.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 09/02/25.
//

import UIKit

class ReceivedMessageCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bubbleView.layer.cornerRadius = 10
    }
    
    func configure(with message: ChatMessage) {
            messageLabel?.text = message.text
        }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
