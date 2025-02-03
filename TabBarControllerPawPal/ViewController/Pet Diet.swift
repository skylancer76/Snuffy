//
//  Pet Diet.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 28/01/25.
//

import UIKit
import FirebaseFirestore

class Pet_Diet: UIViewController {
    
    var petId: String?
    @IBOutlet weak var petDietTableView: UITableView!
    
    // Array to hold fetched PetDietDetails objects.
    var petDietDetails: [PetDietDetails] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Pet ID in Pet Diet: \(petId ?? "No Pet ID")")
        
        petDietTableView.dataSource = self
        petDietTableView.delegate = self
        
        if let petId = petId {
            fetchPetDietData(petId: petId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let petId = petId {
            fetchPetDietData(petId: petId)
        }
    }
    
    // Fetch pet diet data from Firestore for the given petId.
    func fetchPetDietData(petId: String) {
        let db = Firestore.firestore()
        
        db.collection("Pets").document(petId).collection("PetDiet").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching pet diet data: \(error.localizedDescription)")
                return
            }
            
            self.petDietDetails.removeAll()
            
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                
                let mealType = data["mealType"] as? String ?? ""
                let foodName = data["foodName"] as? String ?? ""
                let foodCategory = data["foodCategory"] as? String ?? ""
                let portionSize = data["portionSize"] as? String ?? ""
                let feedingFrequency = data["feedingFrequency"] as? String ?? ""
                let servingTime = data["servingTime"] as? String ?? ""
                
                let diet = PetDietDetails(
                    dietId: document.documentID,
                    mealType: mealType,
                    foodName: foodName,
                    foodCategory: foodCategory,
                    portionSize: portionSize,
                    feedingFrequency: feedingFrequency,
                    servingTime: servingTime
                )
                
                self.petDietDetails.append(diet)
            }
            
            DispatchQueue.main.async {
                self.petDietTableView.reloadData()
            }
        }
    }
    
    @IBAction func addPetDiet(_ sender: UIBarButtonItem) {
        if let petId = petId {
            if let addPetDietVC = storyboard?.instantiateViewController(withIdentifier: "AddPetDietVC") as? Add_Pet_Diet {
                addPetDietVC.petId = petId
                navigationController?.pushViewController(addPetDietVC, animated: true)
            }
        }
    }
    
    // Delete action when the delete button is tapped.
    @objc func deleteDietButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let diet = petDietDetails[index]
        guard let petId = petId, let dietId = diet.dietId else { return }
        
        FirebaseManager.shared.deletePetDietData(petId: petId, dietId: dietId) { error in
            if let error = error {
                print("Error deleting diet: \(error.localizedDescription)")
            } else {
                print("Diet deleted successfully")
                self.petDietDetails.remove(at: index)
                DispatchQueue.main.async {
                    self.petDietTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension Pet_Diet: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petDietDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PetDietTableViewCell", for: indexPath) as! PetDietTableViewCell
        
        let diet = petDietDetails[indexPath.row]
        
        cell.mealTypeLabel.text = diet.mealType
        cell.foodNameLabel.text = diet.foodName
        cell.foodCategoryLabel.text = diet.foodCategory
        cell.portionSizeLabel.text = diet.portionSize
        cell.feedingFrequencyLabel.text = diet.feedingFrequency
        cell.servingTimeLabel.text = diet.servingTime
        
        // Set the delete button's tag and add target action.
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteDietButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // Set the height of each cell as desired.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle cell selection if needed.
    }
}

