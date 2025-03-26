//
//  MyPetsCell.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 24/03/25.
//

import UIKit

class MyPetsCell: UICollectionViewCell {
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petName: UILabel!
    
    func configure(with pet: PetData) {
        petName.text = pet.petName
        
        
        // Validate the image URL string.
        guard let imageUrlString = pet.petImage,
              let url = URL(string: imageUrlString) else {
            petImage.image = UIImage(named: "placeholder_image")
            return
        }
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
