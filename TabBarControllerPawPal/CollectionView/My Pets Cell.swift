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
        
        // Ensure petImage is a valid, unwrapped string
        guard let petImageName = pet.petImage else {
            print("Pet image name is nil or invalid")
            self.petImage.image = UIImage(named: "placeholder_image")
            return
        }
        
        // Fetch the pet image from Firebase Storage
        let storage = Storage.storage()
        let imageRef = storage.reference().child("pet_images/\(petImageName)")
        
        imageRef.downloadURL { [weak self] url, error in
            guard let self = self else { return } // Prevent retain cycle
            
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.petImage.image = UIImage(named: "placeholder_image")
                }
                return
            }
            
            if let url = url {
                self.loadImage(from: url)
            }
        }
    }
    
    private func loadImage(from url: URL) {
        // Use a background thread to fetch the image
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
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
