//
//  My Pets.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 01/01/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class My_Pets: UIViewController {
    
    var selectedPet: PetData?
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var addPetButton: UIButton!
    @IBOutlet weak var myPets: UICollectionView!
    
    var pets: [PetData] = []
    var petsListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Gradient View
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        
        // Set Gradient inside the view
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds // Match the frame of the view
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor, // Start color
            UIColor.clear.cgColor                               // End color
        ]
        gradientLayer.locations = [0.0, 1.0]                     // Gradually fade
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)       // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)         // Bottom-center
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Clear background color of collection view
        myPets.backgroundColor = .clear
        
        // Collection View delegates
        myPets.delegate = self
        myPets.dataSource = self
        
        // Fetch pets from Firestore (only once)
        fetchPetsFromFirestore()
        
        // Set layout for collection view
        myPets.collectionViewLayout = createLayout()
        
        // Clear background
        backgroundView.backgroundColor = .clear
    }
    
    // Add Pet Buttton function
    @IBAction func addPetButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "AddNewPetSegue", sender: self)
    }
    
    
    func fetchPetsFromFirestore() {
        let db = Firestore.firestore()
        
        // Ensure the user is logged in
        guard let currentUser = Auth.auth().currentUser else {
            print("User is not logged in")
            return
        }
        
        // Listen to pets where ownerID matches the current user
        petsListener = db.collection("Pets")
            .whereField("ownerID", isEqualTo: currentUser.uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
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
                    
                    return PetData(
                        petId: petId,
                        petImage: image,
                        petName: name,
                        petBreed: breed,
                        petGender: gender,
                        petAge: age,
                        petWeight: weight
                    )
                } ?? []
                
                // Optionally prefetch images for the updated pets array.
                self.prefetchImages(for: self.pets)
                
                DispatchQueue.main.async {
                    self.myPets.reloadData()
                }
            }
    }
    
    func prefetchImages(for pets: [PetData]) {
        for pet in pets {
            // Ensure there's a valid image URL string.
            guard let imageUrlString = pet.petImage,
                  let url = URL(string: imageUrlString) else {
                continue
            }
            
            // Start downloading the image using ImageDownloader.
            ImageDownloader.shared.downloadImage(from: url) { localURL in
                if let localURL = localURL {
                    print("Downloaded image for \(pet.petName ?? "Unknown") to \(localURL.path)")
                    // Optionally: update your pet model or notify cells if needed.
                } else {
                    print("Failed to download image for \(pet.petName ?? "Unknown")")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewPetSegue",
           let destinationVC = segue.destination as? Add_New_Pet {
            destinationVC.delegate = self
            
        } else if segue.identifier == "ShowPetProfileSegue",
                  let destinationVC = segue.destination as? Pet_Profile {
            // Pass the pet ID if we have a selected pet
            if let selectedPet = selectedPet {
                destinationVC.petId = selectedPet.petId
                print("Pet ID passed: \(selectedPet.petId)")  // Debug print
                destinationVC.hidesBottomBarWhenPushed = true
            } else {
                print("Selected Pet is nil!")
            }
        }
    }
}

// MARK: - CollectionView DataSource & Delegate
extension My_Pets: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetCell", for: indexPath) as! My_Pets_Cell
        let pet = pets[indexPath.item]
        cell.configure(with: pet)
        cell.contentView.layer.cornerRadius = 12
        cell.backgroundColor = .clear
        cell.layer.masksToBounds = false
        cell.layer.shadowRadius = 5
        cell.layer.shadowOpacity = 0.1
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 1) Set the selectedPet
        selectedPet = pets[indexPath.item]
        print("Selected pet ID: \(selectedPet?.petId ?? "No Pet ID")")
        
        // 2) Manually perform the segue
        performSegue(withIdentifier: "ShowPetProfileSegue", sender: self)
    }
    
    func createLayout() -> UICollectionViewLayout {
        // Define item size for two cells
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        // Define group size to accommodate 2 cells
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(235)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 20, trailing: 16)
        
        // No horizontal scrolling
        section.orthogonalScrollingBehavior = .none
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: - AddNewPetDelegate
extension My_Pets: AddNewPetDelegate {
    func didAddNewPet(_ pet: PetData) {
        pets.append(pet)
        DispatchQueue.main.async {
            self.myPets.reloadData()
        }
    }
}
