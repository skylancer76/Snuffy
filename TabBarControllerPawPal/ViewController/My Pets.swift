//
//  My Pets.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 01/01/25.
//

import UIKit
import FirebaseFirestore

class My_Pets: UIViewController {
    
    @IBOutlet weak var addButtonView: UIView!
    @IBOutlet weak var addPetButton: UIButton!
    @IBOutlet weak var myPets: UICollectionView!
    
    var pets: [PetData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round corners for add button view
        addButtonView.layer.cornerRadius = 15
        addButtonView.layer.masksToBounds = true
        
        myPets.delegate = self
        myPets.dataSource = self
        
        // Fetch pets from Firestore
        fetchPetsFromFirestore()
        
        // Add target to Add Pet button
        addPetButton.addTarget(self, action: #selector(addPetButtonTapped), for: .touchUpInside)
    }
    
    @objc func addPetButtonTapped() {
        // Perform segue to AddNewPetViewController
        performSegue(withIdentifier: "AddNewPetSegue", sender: self)
    }
    
    func fetchPetsFromFirestore() {
        let db = Firestore.firestore()
        db.collection("Pets").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching pet data: \(error.localizedDescription)")
                return
            }
            
            self.pets = snapshot?.documents.compactMap { document in
                let data = document.data()
                let name = data["petName"] as? String
                let breed = data["petBreed"] as? String
                let image = data["petImage"] as? String
                return PetData(petImage: image, petName: name, petBreed: breed)
            } ?? []
            
            DispatchQueue.main.async {
                self.myPets.reloadData()
            }
        }
    }
}

extension My_Pets: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetCell", for: indexPath) as! My_Pets_Cell
        let pet = pets[indexPath.item]
        
        cell.configure(with: pet)
        
        // Round corners for the content view
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        
        return cell
    }
}

extension My_Pets: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2 - 24, height: 230)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15 // Adjust this for spacing between cells
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Left alignment with padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
