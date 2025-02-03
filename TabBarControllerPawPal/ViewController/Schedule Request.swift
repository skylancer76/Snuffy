//
//  Schedule Request.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 22/01/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class Schedule_Request: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var petPickerButton: UIButton!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var petPickupSwitch: UISwitch!
    @IBOutlet weak var petDropoffSwitch: UISwitch!
    @IBOutlet weak var caretakingInstructionsTextField: UITextField!
    
    // List to store fetched pet names
    private var petNames: [String] = []
    private var selectedPetNames = Set<String>()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPetNames()
    }
    
    // MARK: - Actions
    

    
    @IBAction func sendButtonTapped(_ sender: UIBarButtonItem) {
        saveScheduleRequest()
    }
    
    // MARK: - Fetch Pet Names
    
    private func fetchPetNames() {
            FirebaseManager.shared.fetchPetNames { names in
                self.petNames = names
                print("Fetched Pet Names: \(self.petNames)")
                self.configurePetPickerMenu()
            }
        }
    private func configurePetPickerMenu() {
        // If there are no pet names, disable the button.
        guard !petNames.isEmpty else {
            petPickerButton.isEnabled = false
            return
        }
        
        // Create UIActions for each pet name.
        let actions: [UIAction] = petNames.map { petName in
            // Use a checkmark if the pet is selected.
            let state: UIMenuElement.State = self.selectedPetNames.contains(petName) ? .on : .off
            return UIAction(title: petName, state: state) { action in
                // Toggle selection with a maximum of 2 selections.
                if self.selectedPetNames.contains(petName) {
                    self.selectedPetNames.remove(petName)
                } else {
                    if self.selectedPetNames.count < 2 {
                        self.selectedPetNames.insert(petName)
                    } else {
                        // Already 2 pets are selected; do nothing.
                        // Optionally, you could show an alert here.
                    }
                }
                // Update the button title to show all selected pet names.
                let selectedTitle = self.selectedPetNames.joined(separator: ", ")
                self.petPickerButton.setTitle(selectedTitle, for: .normal)
                // Rebuild the menu to update the checkmarks.
                self.configurePetPickerMenu()
            }
        }
        
        // Create the menu without using .singleSelection (so our custom logic applies).
        let menu = UIMenu(title: "Select Pet(s)", children: actions)
        petPickerButton.menu = menu
        petPickerButton.showsMenuAsPrimaryAction = true
        
        // Optionally, set an initial title if none are selected.
        if self.selectedPetNames.isEmpty {
            petPickerButton.setTitle("", for: .normal)
        }
    }
    
   
    
    // MARK: - Save Schedule Request
    
    func saveScheduleRequest() {
        // Ensure the user is logged in
        guard let currentUser = Auth.auth().currentUser else {
            self.showAlert(title: "Error", message: "You must be logged in to send a schedule request.")
            return
        }
        
        let userId = currentUser.uid
        let startDate = startDatePicker.date // Date object
        let endDate = endDatePicker.date     // Date object
        
        // Validation: End date cannot be earlier than start date
        guard endDate >= startDate else {
            self.showAlert(title: "Error", message: "End date cannot be earlier than the start date.")
            return
        }
        
        // If the dates are valid, fetch additional data and proceed
        fetchUserName(userId: userId) { [weak self] userName in
            guard let self = self else { return }
            
            let pet = self.petPickerButton.title(for: .normal) ?? "Unknown Pet"
            let petPickup = self.petPickupSwitch.isOn
            let petDropoff = self.petDropoffSwitch.isOn
            let instructions = self.caretakingInstructionsTextField.text ?? ""
            let requestId = UUID().uuidString // Generate a unique request ID
            
            // Prepare data for Firestore
            let requestData: [String: Any] = [
                "requestId": requestId,
                "userId": userId,
                "userName": userName, // Fetched from the database
                "pet": pet,
                "startDate": startDate,
                "endDate": endDate,
                "petPickup": petPickup,
                "petDropoff": petDropoff,
                "instructions": instructions,
                "timestamp": Date() // Current date and time
            ]
            
            // Save to Firestore
            FirebaseManager.shared.saveScheduleRequestData(data: requestData) { error in
                if let error = error {
                    print("Failed to save schedule request: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to save the schedule request.")
                } else {
                    self.showAlert(title: "Success", message: "Schedule request saved successfully!")
                }
            }
        }
    }
    func fetchUserName(userId: String, completion: @escaping (String) -> Void) {
        let usersCollection = Firestore.firestore().collection("users")
        usersCollection.document(userId).getDocument { document, error in
            if let error = error {
                print("Failed to fetch user name: \(error.localizedDescription)")
                completion("Anonymous User") // Fallback if fetching fails
            } else if let document = document, let data = document.data(), let name = data["name"] as? String {
                completion(name) // Pass the user's name to the completion handler
            } else {
                completion("Anonymous User") // Fallback if no data is found
            }
        }
    }

    
    // MARK: - Alert Helper
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
