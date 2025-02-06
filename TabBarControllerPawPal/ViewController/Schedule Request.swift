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
            
            let state: UIMenuElement.State = self.selectedPetNames.contains(petName) ? .on : .off
            return UIAction(title: petName, state: state) { action in
               
                if self.selectedPetNames.contains(petName) {
                    self.selectedPetNames.remove(petName)
                } else {
                    if self.selectedPetNames.count < 2 {
                        self.selectedPetNames.insert(petName)
                    } else {
                        
                    }
                }
               
                let selectedTitle = self.selectedPetNames.joined(separator: ", ")
                self.petPickerButton.setTitle(selectedTitle, for: .normal)
               
                self.configurePetPickerMenu()
            }
        }
        
      
        let menu = UIMenu(title: "Select Pet(s)", children: actions)
        petPickerButton.menu = menu
        petPickerButton.showsMenuAsPrimaryAction = true
        
        
        if self.selectedPetNames.isEmpty {
            petPickerButton.setTitle("", for: .normal)
        }
    }
    
    
    
    // MARK: - Save Schedule Request
    
    func saveScheduleRequest() {
        guard let currentUser = Auth.auth().currentUser else {
            self.showAlert(title: "Error", message: "You must be logged in to send a schedule request.")
            return
        }
        
        let userId = currentUser.uid
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        
        guard endDate >= startDate else {
            self.showAlert(title: "Error", message: "End date cannot be earlier than the start date.")
            return
        }
        
        fetchUserName(userId: userId) { [weak self] userName in
            guard let self = self else { return }
            
            let petName = self.petPickerButton.title(for: .normal) ?? "Unknown Pet"
            let petPickup = self.petPickupSwitch.isOn
            let petDropoff = self.petDropoffSwitch.isOn
            let instructions = self.caretakingInstructionsTextField.text ?? ""
            let requestId = UUID().uuidString
            
            let requestData: [String: Any] = [
                "requestId": requestId,
                "userId": userId,
                "userName": userName,
                "petName": petName,
                "startDate": Timestamp(date: startDate),
                "endDate": Timestamp(date: endDate),
                "petPickup": petPickup,
                "petDropoff": petDropoff,
                "instructions": instructions,
                "status": "available", // Initially available before assigning caretaker
                "timestamp": Timestamp(date: Date())
            ]
            
            FirebaseManager.shared.saveScheduleRequestData(data: requestData) { error in
                if let error = error {
                    print("Failed to save schedule request: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to save the schedule request.")
                } else {
                    print("Schedule request saved successfully! Now auto-assigning caretaker...")
                    // Show success alert here
                    DispatchQueue.main.async {
                        self.showAlert(title: "Success", message: "Your request is sent!")
                    }
                    
                    FirebaseManager.shared.autoAssignCaretaker(petName: petName, requestId: requestId) { error in
                        if let error = error {
                            print("Failed to auto-assign caretaker: \(error.localizedDescription)")
                        } else {
                            print("Caretaker successfully assigned for request: \(requestId)")
                        }
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
        
        
    }
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
