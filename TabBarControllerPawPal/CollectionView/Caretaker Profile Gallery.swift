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
            galleryImage.layer.masksToBounds = true

       }
}
