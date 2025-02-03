//
//  Pet Profile.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 01/01/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class Pet_Profile: UIViewController {
    
    // The petId passed from My_Pets view controller
    var petId: String?
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var breedLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var petInfo: UIView!
    
    // Outlet for TableView
    @IBOutlet weak var petDetailsTableView: UITableView!
    
    // Data to populate the table
    let tableOptions = ["Pet Vaccinations", "Pet Diet", "Pet Medications"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Received Pet ID: \(petId ?? "No Pet ID")")
        petDetailsTableView.dataSource = self
        petDetailsTableView.delegate = self
        
        if let petId = petId {
            fetchPetData(petId: petId)
        } else {
            print("Pet ID is missing!")
        }
        
        petImage.layer.cornerRadius = 20
        petImage.layer.masksToBounds = true
        
        petInfo.layer.cornerRadius = 12
        petInfo.layer.masksToBounds = true
    }
    
    // Fetch pet data from Firestore using petId
    func fetchPetData(petId: String) {
        let db = Firestore.firestore()
        db.collection("Pets").document(petId).getDocument { document, error in
            if let error = error {
                print("Error fetching pet data: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists, let data = document.data() {
                let petName = data["petName"] as? String ?? "Unknown"
                let petBreed = data["petBreed"] as? String ?? "Unknown"
                let petAge = data["petAge"] as? String ?? "Unknown"
                let petGender = data["petGender"] as? String ?? "Unknown"
                let petWeight = data["petWeight"] as? String ?? "Unknown"
                let petImageUrl = data["petImage"] as? String ?? ""
                
                DispatchQueue.main.async {
                    self.nameLabel.text = petName
                    self.breedLabel.text = petBreed
                    self.ageLabel.text = petAge
                    self.genderLabel.text = petGender
                    self.weightLabel.text = petWeight
                    self.petImage.loadImageFromUrl(petImageUrl)
                }
            } else {
                print("No pet data found for this petId.")
            }
        }
    }
    
    // Remove any IBAction segues attached directly to the cell.
    // We will handle navigation in didSelectRowAt.
}

extension UIImageView {
    func loadImageFromUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}

extension Pet_Profile: UITableViewDataSource, UITableViewDelegate {
    
    // Number of rows in the table (one row for each option)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableOptions.count
    }
    
    // Configure each cell with the corresponding option and icon.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PetDetailCell", for: indexPath)
        cell.textLabel?.text = tableOptions[indexPath.row]
        
        let icon: UIImage?
        switch tableOptions[indexPath.row] {
        case "Pet Vaccinations":
            icon = UIImage(systemName: "syringe.fill")
        case "Pet Diet":
            icon = UIImage(systemName: "fork.knife")
        case "Pet Medications":
            icon = UIImage(systemName: "pills.fill")
        default:
            icon = nil
        }
        if let icon = icon {
            let tintedIcon = icon.withRenderingMode(.alwaysTemplate)
            cell.imageView?.image = tintedIcon
            cell.imageView?.tintColor = UIColor.systemPurple.withAlphaComponent(0.6)
        }
        return cell
    }
    
    // Set cell height.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // Handle cell selection to navigate to the proper screen.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let petId = petId else { return }
        let option = tableOptions[indexPath.row]
        
        switch option {
        case "Pet Vaccinations":
            if let vaccinationDetailsVC = storyboard?.instantiateViewController(withIdentifier: "VaccinationDetailsVC") as? Vaccination_Details {
                vaccinationDetailsVC.petId = petId
                navigationController?.pushViewController(vaccinationDetailsVC, animated: true)
            }
        case "Pet Diet":
            if let petDietVC = storyboard?.instantiateViewController(withIdentifier: "PetDietVC") as? Pet_Diet {
                petDietVC.petId = petId
                navigationController?.pushViewController(petDietVC, animated: true)
            }
        case "Pet Medications":
            if let petMedicationVC = storyboard?.instantiateViewController(withIdentifier: "PetMedicationVC") as? Pet_Medications {
                petMedicationVC.petId = petId
                navigationController?.pushViewController(petMedicationVC, animated: true)
            }
        default:
            break
        }
    }
}
