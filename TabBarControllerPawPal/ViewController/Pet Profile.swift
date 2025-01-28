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
    var petId: String? // Receive petId from the previous screen
    
    // Outlets for pet data
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var breedLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    // Outlets for view styling
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var weightView: UIView!
    
    // Outlets for TableView
    @IBOutlet weak var petDetailsTableView: UITableView!
    
    // Data to populate the table
    let tableOptions = ["Pet Vaccinations", "Pet Diet", "Pet Medications"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Debug print to check if petId is received correctly
        print("Received Pet ID: \(petId ?? "No Pet ID")")
        
        // Set up UI styles
        setupUI()
        
        // Set TableView dataSource and delegate
        petDetailsTableView.dataSource = self
        petDetailsTableView.delegate = self
        
        // Check if petId is available and then fetch pet data
        if let petId = petId {
            fetchPetData(petId: petId)
        } else {
            print("Pet ID is missing!")
        }
    }
    
    // Function to set up UI components
    func setupUI() {
        // Apply corner radius for styling the views
        genderView.layer.cornerRadius = 10
        genderView.layer.masksToBounds = true
        
        ageView.layer.cornerRadius = 10
        ageView.layer.masksToBounds = true
        
        weightView.layer.cornerRadius = 10
        weightView.layer.masksToBounds = true
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
    
    // Create cell and populate it with data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PetDetailCell", for: indexPath)
        cell.textLabel?.text = tableOptions[indexPath.row]
        
        // Optionally, add icons based on the labels (e.g. food, pills, etc.)
        let icon = UIImage(systemName: "pawprint") // Example symbol, can customize per option
        cell.imageView?.image = icon
        
        return cell
    }
    
    // Handling row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle selection (for now, just print the option selected)
        print("Selected: \(tableOptions[indexPath.row])")
        
        // Here you could navigate to the relevant view controller (e.g. for medications, diet, etc.)
    }
}
