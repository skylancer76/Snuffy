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

        guard let petImageURL = pet.petImage else {
            print("Pet image URL is nil or invalid")
            self.petImage.image = UIImage(named: "placeholder_image")
            return
        }

        // Extract the file name from the URL
        if let urlComponents = URLComponents(string: petImageURL),
           let path = urlComponents.path.split(separator: "/").last {
            let fileName = String(path)
            let cacheKey = "pet_images/\(fileName)"
//            let storage = Storage.storage()
//            let imageRef = storage.reference().child("pet_images/\(fileName)")
//
//            imageRef.downloadURL { [weak self] url, error in
//                guard let self = self else { return }
//
//                if let error = error {
//                    print("Error fetching image: \(error.localizedDescription)")
//                    DispatchQueue.main.async {
//                        self.petImage.image = UIImage(named: "placeholder_image")
//                    }
//                    return
//                }
//
//                if let url = url {
//                    self.loadImage(from: url)
//                }
//            }
//        } else {
//            print("Invalid petImage URL: \(petImageURL)")
//        }
            if let cachedImage = ImageCacheManager.shared.image(forKey: cacheKey) {
            self.petImage.image = cachedImage
            return
    }
            let storage = Storage.storage()
            let imageRef = storage.reference().child(cacheKey)
            imageRef.downloadURL { [weak self] url, error in
                            guard let self = self else { return }
                            
                if let error = error {
                    print("Error fetching image: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.petImage.image = UIImage(named: "placeholder_image")
                    }
                    return
                }
                if let url = url {
                                    self.loadImage(from: url, cacheKey: cacheKey)
                                }
                            }
        } else {
                    print("Invalid petImage URL: \(petImageURL)")
                    self.petImage.image = UIImage(named: "placeholder_image")
                }
            }

//    private func loadImage(from url: URL) {
//        // Use a background thread to fetch the image
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self.petImage.image = image
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.petImage.image = UIImage(named: "placeholder_image")
//                }
//            }
//        }
//    }
    private func loadImage(from url: URL, cacheKey: String) {
            // Use a background thread to fetch the image.
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    // Cache the image for later use.
                    ImageCacheManager.shared.setImage(image, forKey: cacheKey)
                    DispatchQueue.main.async {
                        self.petImage.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.petImage.image = UIImage(named: "placeholder_image")
                    }
                }
            }
        }
}
