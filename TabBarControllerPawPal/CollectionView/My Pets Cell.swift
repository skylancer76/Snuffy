//
//  My Pets Cell.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 01/01/25.
//


import UIKit
import FirebaseStorage

class My_Pets_Cell: UICollectionViewCell {
    
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var petBreed: UILabel!
    
    func configure(with pet: PetData) {
        petName.text = pet.petName
        petBreed.text = pet.petBreed
        
        // Validate the image URL string.
        guard let imageUrlString = pet.petImage,
              let url = URL(string: imageUrlString) else {
            petImage.image = UIImage(named: "placeholder_image")
            return
        }
        
        // Use the URL's lastPathComponent as the file name.
        // NOTE: If your URLs include query parameters or are not unique,
        // consider using a hashed version of the URL instead.
        let fileName = url.lastPathComponent
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let localURL = cachesDirectory.appendingPathComponent(fileName)
        
        // Check if the file exists locally.
        if FileManager.default.fileExists(atPath: localURL.path),
           let image = UIImage(contentsOfFile: localURL.path) {
            petImage.image = image
        } else {
            // If not found locally, attempt to download the image.
            ImageDownloader.shared.downloadImage(from: url) { downloadedLocalURL in
                if let downloadedLocalURL = downloadedLocalURL,
                   let image = UIImage(contentsOfFile: downloadedLocalURL.path) {
                    DispatchQueue.main.async {
                        self.petImage.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.petImage.image = UIImage(named: "placeholder_image")
                    }
                }
            }
            petImage.image = UIImage(named: "placeholder_image")
        }
    }
}
