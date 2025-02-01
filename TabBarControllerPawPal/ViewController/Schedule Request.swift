//
//  Schedule Request.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 22/01/25.
//

import UIKit

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
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPetNames()
    }
    
    // MARK: - Actions
    
    @IBAction func petPickerButtonTapped(_ sender: UIButton) {
        showPetPickerDropdown()
    }
    
    @IBAction func sendButtonTapped(_ sender: UIBarButtonItem) {
        saveScheduleRequest()
    }
    
    // MARK: - Fetch Pet Names
    
    private func fetchPetNames() {
        FirebaseManager.shared.fetchPets { pets in
            // Extract pet names
            self.petNames = pets.map { $0.name }
            print("Fetched Pet Names: \(self.petNames)") // Debug log
        }
    }
    
    // MARK: - Pet Picker Dropdown
    
    private func showPetPickerDropdown() {
        let alertController = UIAlertController(title: "Select Pet", message: nil, preferredStyle: .actionSheet)
        
        // Add an action for each pet name
        for petName in petNames {
            let action = UIAlertAction(title: petName, style: .default) { _ in
                self.petPickerButton.setTitle(petName, for: .normal)
            }
            alertController.addAction(action)
        }
        
        // Add a cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the dropdown
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Save Schedule Request
    
    func saveScheduleRequest() {
        // Collect user input
        let pet = petPickerButton.title(for: .normal) ?? "Unknown Pet"
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        let petPickup = petPickupSwitch.isOn
        let petDropoff = petDropoffSwitch.isOn
        let instructions = caretakingInstructionsTextField.text ?? ""
        
        // Prepare data dictionary
        let requestData: [String: Any] = [
            "pet": pet,
            "startDate": startDate.timeIntervalSince1970,
            "endDate": endDate.timeIntervalSince1970,
            "petPickup": petPickup,
            "petDropoff": petDropoff,
            "instructions": instructions
        ]
        
        // Save data to Firestore using FirebaseManager
        FirebaseManager.shared.saveScheduleRequestData(data: requestData) { error in
            if let error = error {
                print("Failed to save schedule request: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Failed to save the schedule request.")
            } else {
                self.showAlert(title: "Success", message: "Schedule request saved successfully!")
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
