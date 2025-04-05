//
//  Pet_Diet_Details.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 05/04/25.
//

import UIKit
import FirebaseFirestore

class Pet_Diet_Details: UIViewController {
    
    var petId: String?
    @IBOutlet weak var petDietTableView: UITableView!
    
    // Array to hold fetched PetDietDetails objects.
    var petDietDetails: [PetDietDetails] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Pet ID in Pet Diet: \(petId ?? "No Pet ID")")
        
        // TableView Setup
        petDietTableView.dataSource = self
        petDietTableView.delegate = self
        petDietTableView.backgroundColor = .clear
        
        // Fetch data if petId is available
        if let petId = petId {
            fetchPetDietData(petId: petId)
        }
        
        // Set up gradient background (similar to Vaccination screen)
        setupGradientBackground()
        
        // Observe notification for data refresh
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePetDietDataAdded(_:)),
                                               name: NSNotification.Name("PetDietDataAdded"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Optionally, fetch the data here too if needed.
        if let petId = petId {
            fetchPetDietData(petId: petId)
        }
    }
    
    // MARK: - Notification Handler
    
    @objc func handlePetDietDataAdded(_ notification: Notification) {
        print("PetDietDataAdded notification received")
        if let petId = petId {
            fetchPetDietData(petId: petId)
        }
    }
    
    // Fetch pet diet data from Firestore for the given petId.
    func fetchPetDietData(petId: String) {
        let db = Firestore.firestore()
        
        db.collection("Pets")
          .document(petId)
          .collection("PetDiet")
          .getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching pet diet data: \(error.localizedDescription)")
                return
            }
            
            self.petDietDetails.removeAll()
            
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                
                let mealType = data["mealType"] as? String ?? ""
                let foodName = data["foodName"] as? String ?? ""
                let servingTime = data["servingTime"] as? String ?? ""
                
                // We only care about mealType, foodName, and servingTime for display.
                let diet = PetDietDetails(
                    dietId: document.documentID,
                    mealType: mealType,
                    foodName: foodName,
                    foodCategory: data["foodCategory"] as? String ?? "",
                    portionSize: data["portionSize"] as? String ?? "",
                    feedingFrequency: data["feedingFrequency"] as? String ?? "",
                    servingTime: servingTime
                )
                
                self.petDietDetails.append(diet)
            }
            
            DispatchQueue.main.async {
                self.petDietTableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PetDietIdentifier" {
            // If your destination is embedded in a navigation controller, grab the top view controller.
            if let navController = segue.destination as? UINavigationController,
               let addPetDietVC = navController.topViewController as? Add_Pet_Diet {
                addPetDietVC.petId = petId
                addPetDietVC.modalPresentationStyle = .pageSheet
            } else if let addPetDietVC = segue.destination as? Add_Pet_Diet {
                addPetDietVC.petId = petId
                addPetDietVC.modalPresentationStyle = .pageSheet
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func setupGradientBackground() {
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
        
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension Pet_Diet_Details: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petDietDetails.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PetsDietTableViewCell",
            for: indexPath
        ) as! PetsDietTableViewCell
        
        let diet = petDietDetails[indexPath.row]
        
        // Display only Meal Name, Meal Type, and Time
        cell.mealNameLabel.text = diet.foodName
        cell.mealTypeLabel.text = diet.mealType
        cell.servingTimeLabel.text = diet.servingTime
        
        cell.backgroundColor = .clear
        return cell
    }
    
    // Set cell height similar to Vaccination table
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedDiet = petDietDetails[indexPath.row]

        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "Pets_Diet") as? Pet_Particular_Diet {
            
            // 3. Pass the Pet ID and the selected diet
            detailVC.petId = petId
            detailVC.selectedDiet = selectedDiet
            
            // 4. Push the detail screen
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

}
