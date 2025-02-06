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

    
    @IBOutlet weak var petPickerButton: UIButton!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var petPickupSwitch: UISwitch!
    @IBOutlet weak var petDropoffSwitch: UISwitch!
    @IBOutlet weak var caretakingInstructionsTextView: UITextView!
    
    // List to store fetched pet names for the current user
    private var petNames: [String] = []
    // Only one pet is allowed to be selected at a time.
    private var selectedPetNames = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the default title for the pet picker button.
        petPickerButton.setTitle("Select Pet", for: .normal)
        fetchPetNames()
    }

    
    @IBAction func sendButtonTapped(_ sender: UIBarButtonItem) {
        saveScheduleRequest()
    }

    
    // Fetch Pets Function
    private func fetchPetNames() {
        guard let currentUser = Auth.auth().currentUser else {
            // If not logged in, disable the picker button.
            self.petPickerButton.isEnabled = false
            return
        }
        
        // Query the "Pets" collection for pets where "ownerId" matches the current user's UID.
        let db = Firestore.firestore()
        db.collection("Pets")
            .whereField("ownerId", isEqualTo: currentUser.uid)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error fetching pets: \(error.localizedDescription)")
                        self.petNames = []
                    } else if let snapshot = snapshot {
                        var names: [String] = []
                        for document in snapshot.documents {
                            // Assume each pet document has a "name" field.
                            if let name = document.data()["name"] as? String {
                                names.append(name)
                            }
                        }
                        self.petNames = names
                    }
                    
                    print("Fetched Pet Names: \(self.petNames)")
                    
                    // If no pets are found for this user, show an alert with a button to navigate to the Add Pet tab.
                    if self.petNames.isEmpty {
                        let alert = UIAlertController(title: "No Pet Added", message: "You currently have no pets added. Please add a pet to continue.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Add Pet", style: .default, handler: { _ in
                            // Navigate to the Add Pet tab. Adjust the index as needed.
                            self.dismiss(animated: true) {
                                    // Instantiate the desired tab bar controller from the storyboard by its identifier.
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController else {
                                        print("Tab bar controller with identifier 'TabBarControllerID' not found.")
                                        return
                                    }
                                    
                                    // Access the active window using connectedScenes (for iOS 15+)
                                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = scene.windows.first {
                                        window.rootViewController = tabBarController
                                        window.makeKeyAndVisible()
                                        // Set the desired tab index (adjust index as needed)
                                        tabBarController.selectedIndex = 2
                                    } else {
                                        print("Active window not found.")
                                    }
                                }
                            }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        self.present(alert, animated: true)
                        // Disable the pet picker button since there are no pets.
                        self.petPickerButton.isEnabled = false
                    } else {
                        self.petPickerButton.isEnabled = true
                        self.configurePetPickerMenu()
                    }
                }
            }
    }
    
    
    // Configure Pet Picker Menu
    private func configurePetPickerMenu() {
        // Create UIActions for each pet name.
        let actions: [UIAction] = petNames.map { petName in
            // Set checkmark if the pet is currently selected.
            let state: UIMenuElement.State = self.selectedPetNames.contains(petName) ? .on : .off
            
            return UIAction(title: petName, state: state) { action in
                // For single selection, clear previous selections.
                if self.selectedPetNames.contains(petName) {
                    // Deselect if tapped again.
                    self.selectedPetNames.removeAll()
                } else {
                    self.selectedPetNames.removeAll()
                    self.selectedPetNames.insert(petName)
                }
                
                // Update the button title.
                let selectedTitle = self.selectedPetNames.isEmpty ? "Select Pet" : self.selectedPetNames.joined(separator: ", ")
                self.petPickerButton.setTitle(selectedTitle, for: .normal)
                
                // Refresh the menu to update the checkmark states.
                self.configurePetPickerMenu()
            }
        }
        
        // Create the menu with the pet options.
        let menu = UIMenu(title: "Select Pet", children: actions)
        petPickerButton.menu = menu
        petPickerButton.showsMenuAsPrimaryAction = true
        
        // If no pet is selected, ensure the default title is visible.
        if self.selectedPetNames.isEmpty {
            petPickerButton.setTitle("Select Pet", for: .normal)
        }
    }

    
    // Save Schedule Request to Firebase
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
            
            // Use the pet selected on the pet picker button. If none, use "Unknown Pet".
            let petName = self.petPickerButton.title(for: .normal) ?? "Unknown Pet"
            let petPickup = self.petPickupSwitch.isOn
            let petDropoff = self.petDropoffSwitch.isOn
            let instructions = self.caretakingInstructionsTextView.text ?? ""
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
    }
    
    
    //
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
    
    
    //
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
