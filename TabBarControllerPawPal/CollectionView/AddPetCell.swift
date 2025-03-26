//
//  AddPetCell.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 24/03/25.
//

import UIKit

class AddPetCell: UICollectionViewCell {
    
    @IBOutlet weak var plusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        plusImageView.contentMode = .scaleAspectFit
        // Optionally set a default plus image here, for example:
        // plusImageView.image = UIImage(systemName: "plus")
    }
}
