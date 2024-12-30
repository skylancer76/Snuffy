//
//  Caretaker Profile.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 25/12/24.
//

import UIKit
import FirebaseFirestore

class Caretaker_Profile: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var caretakerName: UILabel!
    @IBOutlet weak var caretakerAddress: UILabel!
    @IBOutlet weak var caretakerRating: UILabel!
    @IBOutlet weak var experience: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var petsSitted: UILabel!
    @IBOutlet weak var distanceAway: UILabel!
    @IBOutlet weak var aboutCaretaker: UILabel!
    @IBOutlet weak var scheduleBooking: UIButton!
    @IBOutlet weak var caretakerGallery: UICollectionView!
    
    var caretakerNameForProfile: String?
    var galleryImages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
          
        caretakerGallery.delegate = self
        caretakerGallery.dataSource = self
        fetchCaretakerProfile()
    //  setupGalleryView()
    }

    private func fetchCaretakerProfile() {
        guard let selectedName = caretakerNameForProfile else { return }
            
        FirebaseManager.shared.fetchCaretakerProfile(name: selectedName) { [weak self] caretaker, error in
            if let error = error {
                print("Failed to fetch caretaker profile: \(error.localizedDescription)")
                return
            }
                
            guard let caretaker = caretaker else {
                print("No caretaker found with the given name.")
                return
            }
                
            self?.updateUI(with: caretaker)
            self?.galleryImages = caretaker.galleryImages
            DispatchQueue.main.async {
                self?.caretakerGallery.reloadData()
            }
        }
    }
        
        
    private func updateUI(with caretaker: Caretakers) {
        backgroundImage.image = UIImage(named: caretaker.coverImage ?? "background image")
        profileImage.image = UIImage(named: caretaker.profileImageName)
        caretakerName.text = caretaker.name
        caretakerAddress.text = caretaker.address
        caretakerRating.text = caretaker.rating
        experience.text = caretaker.experience
        price.text = caretaker.price
        petsSitted.text = caretaker.petSitted
        distanceAway.text = caretaker.distance
        aboutCaretaker.text = caretaker.about
    }
        
    
    
    private func setupGalleryView() {
        caretakerGallery.register(UINib(nibName: "GalleryCell", bundle: nil), forCellWithReuseIdentifier: "GalleryCell")
    }
}


extension Caretaker_Profile: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! Caretaker_Profile_Gallery
        let imageName = galleryImages[indexPath.item]
        cell.galleryImage.image = UIImage(named: imageName)
        return cell
    }
}
