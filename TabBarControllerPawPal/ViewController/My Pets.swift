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
    @IBOutlet weak var addButtonView: UIView!
    @IBOutlet weak var addPetButton: UIButton!
    @IBOutlet weak var myPets: UICollectionView!
    
    var pets: [PetData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round corners for add button view
        addButtonView.layer.cornerRadius = 15
//        addButtonView.layer.masksToBounds = true
        addButtonView.layer.shadowOffset = CGSize(width: 2, height: 2)
        addButtonView.layer.shadowOpacity = 0.05
        addButtonView.layer.shadowRadius = 3
        
        myPets.delegate = self
        myPets.dataSource = self
        
        // Fetch pets from Firestore
        fetchPetsFromFirestore()
        
        // Add target to Add Pet button
        addPetButton.addTarget(self, action: #selector(addPetButtonTapped), for: .touchUpInside)
        myPets.collectionViewLayout = createLayout()
        
        
        
        // Set Gradient View
        let gradientView = UIView(frame: view.bounds)
            gradientView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(gradientView)
            view.sendSubviewToBack(gradientView)
        
        // Set Gradient inside the view
        let gradientLayer = CAGradientLayer()
            gradientLayer.frame = view.bounds // Match the frame of the view
            gradientLayer.colors = [
                UIColor.systemPurple.withAlphaComponent(0.3).cgColor, // Start color
                UIColor.clear.cgColor       // End color
            ]
            gradientLayer.locations = [0.0, 1.0] // Gradually fade
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Top-center
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)   // Bottom-center
        
            // Apply the gradient to the gradientView
            gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Clear the background of collection view
        myPets.backgroundColor = .clear
        
        
    }
    
    
    @objc func addPetButtonTapped() {
        // Perform segue to AddNewPetViewController
        performSegue(withIdentifier: "AddNewPetSegue", sender: self)
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "AddNewPetSegue",
//           let destinationVC = segue.destination as? AddNewPetViewController {
//            destinationVC.delegate = self
//        }
//    }
    
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
                let age = data["petAge"] as? String
                let gender = data["petGender"] as? String
                let weight = data["petWeight"] as? String
            
                return PetData(
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
        cell.contentView.layer.cornerRadius = 10
        cell.layer.shadowOffset = CGSize(width: 3, height: 3)
        cell.layer.shadowOpacity = 0.07
        cell.layer.shadowRadius = 3
        cell.layer.masksToBounds = false
        cell.backgroundColor = .clear
        cell.petImage.layer.cornerRadius = 4
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            selectedPet = pets[indexPath.item]
            
        }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewPetSegue",
           let destinationVC = segue.destination as? AddNewPetViewController {
            destinationVC.delegate = self
        } else if segue.identifier == "ShowPetProfileSegue",
                  let destinationVC = segue.destination
                    as? Pet_Profile {
            destinationVC.petData = selectedPet
            destinationVC.hidesBottomBarWhenPushed = true
        }
    }
    
}

