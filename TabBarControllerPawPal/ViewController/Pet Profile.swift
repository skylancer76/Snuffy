//
//  Pet Profile.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 01/01/25.
//
import UIKit
import FirebaseFirestore

class Pet_Profile: UIViewController {
    
    // The petId passed from My_Pets view controller
    var petId: String? // Receive petId from the previous screen
    
    // Outlets for pet data
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var breedLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var petInfo: UIView!
    
    // Outlets for TableView
    @IBOutlet weak var petDetailsTableView: UITableView!
    
    // Data to populate the table
    let tableOptions = ["Pet Vaccinations", "Pet Diet", "Pet Medications"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Debug print to check if petId is received correctly
        print("Received Pet ID: \(petId ?? "No Pet ID")")
        
        // Set TableView dataSource and delegate
        petDetailsTableView.dataSource = self
        petDetailsTableView.delegate = self
        
        // Check if petId is available and then fetch pet data
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
    
    // Function to fetch pet data from Firestore using petId
    func fetchPetData(petId: String) {
        let db = Firestore.firestore()
        
        // Fetch pet data from Firestore using the petId
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
                
                // Update the UI with the fetched pet data
                DispatchQueue.main.async {
                    self.nameLabel.text = petName
                    self.breedLabel.text = petBreed
                    self.ageLabel.text = petAge
                    self.genderLabel.text = petGender
                    self.weightLabel.text = petWeight
                    
                    // Load the pet image using URL (optional)
                    self.petImage.loadImageFromUrl(petImageUrl)
                }
            } else {
                print("No pet data found for this petId.")
            }
        }
    }
    
    @IBAction func goToVaccinationDetails(_ sender: UIButton) {
        if let petId = petId {
            // Instantiate the VaccinationDetails view controller using Storyboard ID
            if let vaccinationDetailsVC = storyboard?.instantiateViewController(withIdentifier: "VaccinationDetailsVC") as? Vaccination_Details {
                // Pass petId to VaccinationDetails view controller
                vaccinationDetailsVC.petId = petId
                // Navigate to the VaccinationDetails screen
                navigationController?.pushViewController(vaccinationDetailsVC, animated: true)
            }
        }
    }
}


// Extension to load image from URL (used for the pet image)
extension UIImageView {
    func loadImageFromUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}


// MARK: - Table View Methods
extension Pet_Profile: UITableViewDataSource, UITableViewDelegate {
    
    // Number of rows in the table (1 row for each option)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PetDetailCell", for: indexPath)
        cell.textLabel?.text = tableOptions[indexPath.row]
        
        // Set icons based on the row
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
            // Apply system purple color with 70% opacity
            let tintedIcon = icon.withRenderingMode(.alwaysTemplate)
            cell.imageView?.image = tintedIcon
            cell.imageView?.tintColor = UIColor.systemPurple.withAlphaComponent(0.7)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70  // Set height of the cell to 70 points
    }
    
    
    // Handling row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle selection (for now, just print the option selected)
        print("Selected: \(tableOptions[indexPath.row])")
    }
}
