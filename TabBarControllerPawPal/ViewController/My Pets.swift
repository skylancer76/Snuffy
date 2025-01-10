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
        myPets.collectionViewLayout = createLayout()
    }
    
    @objc func addPetButtonTapped() {
        // Perform segue to AddNewPetViewController
        performSegue(withIdentifier: "AddNewPetSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewPetSegue",
           let destinationVC = segue.destination as? AddNewPetViewController {
            destinationVC.delegate = self
        }
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


extension My_Pets: UICollectionViewDataSource , UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetCell", for: indexPath) as! My_Pets_Cell
        let pet = pets[indexPath.item]
        cell.configure(with: pet)
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.masksToBounds = true
        cell.petImage.layer.cornerRadius = 8
        cell.petImage.layer.masksToBounds = true
        
        return cell
    }
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(250))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }
}

