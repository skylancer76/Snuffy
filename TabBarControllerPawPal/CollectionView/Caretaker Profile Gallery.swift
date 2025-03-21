//
//  Caretaker Profile Gallery.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 21/03/25.
//

import UIKit

class Caretaker_Profile_Gallery: UICollectionViewCell {
    @IBOutlet weak var galleryImage: UIImageView!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           
           // Round the image’s corners
           galleryImage.layer.cornerRadius = 10
           galleryImage.clipsToBounds = true
           
           // Optionally add a border or shadow to the cell’s contentView:
           contentView.layer.cornerRadius = 10
           contentView.layer.masksToBounds = true
           // For a shadow, you'd style the cell's layer (not contentView)
           // layer.shadowColor = UIColor.black.cgColor
           // layer.shadowOffset = CGSize(width: 0, height: 2)
           // layer.shadowOpacity = 0.2
           // layer.shadowRadius = 4
           // layer.masksToBounds = false
       }
}
