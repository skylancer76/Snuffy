//
//  My Pets.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 01/01/25.
//

import UIKit
import FirebaseFirestore

class My_Pets: UIViewController {
    
    var selectedPet: PetData?
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var addPetButton: UIBarButtonItem!
    @IBOutlet weak var myPets: UICollectionView!
    
    var pets: [PetData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.backgroundColor = .clear

        
        // Set Gradient View
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        // Set Gradient inside the view
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds                          // Match the frame of the view
        gradientLayer.colors = [
            UIColor.systemPurple.withAlphaComponent(0.3).cgColor,  // Start color
            UIColor.clear.cgColor                                  // End color
        ]
        gradientLayer.locations = [0.0, 1.0]                       // Gradually fade
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)         // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)           // Bottom-center
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        // Claer background colour of collection view
        myPets.backgroundColor = .clear
        
        
        // Collection View delegates
        myPets.delegate = self
        myPets.dataSource = self
        
        // Fetch pets from Firestore
        fetchPetsFromFirestore()
        
        // Set action programmatically
        addPetButton.target = self
        addPetButton.action = #selector(addPetButtonTapped)
        
        // Set layout for collection view
        myPets.collectionViewLayout = createLayout()
        
    }
    
    
    @objc func addPetButtonTapped() {
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
                let petId = data["petId"] as? String ?? ""
                let name = data["petName"] as? String
                let breed = data["petBreed"] as? String
                let image = data["petImage"] as? String
                let age = data["petAge"] as? String
                let gender = data["petGender"] as? String
                let weight = data["petWeight"] as? String

                // Store petId properly when creating PetData object
                return PetData(
                    petId: petId,  // Make sure petId is included
                    petImage: image,
                    petName: name,
                    petBreed: breed,
                    petGender: gender,
                    petAge: age,
                    petWeight: weight
                )
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
        cell.contentView.layer.cornerRadius = 8
        cell.backgroundColor = .clear
        cell.layer.masksToBounds = false
        cell.layer.shadowRadius = 5
        cell.layer.shadowOpacity = 0.1
        return cell
    }
    
    
    func createLayout() -> UICollectionViewLayout {
        // Define item size for two cells
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),  // Adjusted width to fit 2 cells with spacing
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        // Define group size to accommodate 2 cells
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), // 100% of the container width
            heightDimension: .absolute(235)  // Adjust height as required
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 20, trailing: 16) // Adjust section insets
        // Adjust layout to support only 1 item in case there is only one
        section.orthogonalScrollingBehavior = .none
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPet = pets[indexPath.item]
        print("Selected pet ID: \(selectedPet?.petId ?? "No Pet ID")")  // Debug print
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewPetSegue", let destinationVC = segue.destination as? Add_New_Pet {
            destinationVC.delegate = self
        } else if segue.identifier == "ShowPetProfileSegue", let destinationVC = segue.destination as? Pet_Profile {
            if let selectedPet = selectedPet {
                destinationVC.petId = selectedPet.petId  // Pass the petId, not the whole pet object
                print("Pet ID passed: \(selectedPet.petId)")  // Debug print
                destinationVC.hidesBottomBarWhenPushed = true
            } else {
                print("Selected Pet is nil!")
            }
        }
    }
    
}

extension My_Pets: AddNewPetDelegate {
    func didAddNewPet(_ pet: PetData) {
        pets.append(pet)
        
        DispatchQueue.main.async {
            self.myPets.reloadData()
        }
    }
}
