//
//  Pet Diet Details.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 13/03/25.
//

import UIKit
import Firebase
import FirebaseFirestore

class Pet_Diet_Details: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var petId: String?
    @IBOutlet weak var petDietTableView: UITableView!
    
    var petDietDetails: [PetDietDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Pet ID in Pet Diet: \(petId ?? "No Pet ID")")
               
               petDietTableView.dataSource = self
               petDietTableView.delegate = self
               
               if let petId = petId {
                   fetchPetDietData(petId: petId)
               }
               
               // Setup gradient background
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
               gradientLayer.endPoint   = CGPoint(x: 0.5, y: 0.5)
               gradientView.layer.insertSublayer(gradientLayer, at: 0)
               
               // Make the table view background transparent
               petDietTableView.backgroundColor = .clear
    }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return petDietDetails.count
        }
        
        // Configure each cell and hide the delete button
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PetDietTableViewCell", for: indexPath) as? PetDietTableViewCell else {
                return UITableViewCell()
            }
            
            let diet = petDietDetails[indexPath.row]
            cell.mealTypeLabel.text = diet.mealType
            cell.foodNameLabel.text = diet.foodName
            cell.foodCategoryLabel.text = diet.foodCategory
            cell.portionSizeLabel.text = diet.portionSize
            cell.feedingFrequencyLabel.text = diet.feedingFrequency
            cell.servingTimeLabel.text = diet.servingTime
            
            // Hide delete button as caretaker cannot delete records
            cell.deleteButton.isHidden = true
            
            return cell
        }
        
        // Set a consistent cell height
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 250
        }
        
        // Optionally handle cell selection
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // Optionally navigate to a detailed view if needed
        }
}
