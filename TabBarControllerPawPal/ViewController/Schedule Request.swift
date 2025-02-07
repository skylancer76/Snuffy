//
//  Schedule Request.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 22/01/25.
//

//
//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//
//class Schedule_Request: UITableViewController {
//    
//    // MARK: - Outlets
//    
//    @IBOutlet weak var petPickerButton: UIButton!
//    @IBOutlet weak var startDatePicker: UIDatePicker!
//    @IBOutlet weak var endDatePicker: UIDatePicker!
//    @IBOutlet weak var petPickupSwitch: UISwitch!
//    @IBOutlet weak var petDropoffSwitch: UISwitch!
//    @IBOutlet weak var caretakingInstructionsTextView: UITextView!
//    
//    // List to store fetched pet names for the current user
//    private var petNames: [String] = []
//    // Only one pet is allowed to be selected at a time.
//    private var selectedPetNames = Set<String>()
//    
//    // MARK: - View Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Set the default title for the pet picker button.
//        petPickerButton.setTitle("Select Pet", for: .normal)
//        fetchPetNamesForCurrentUser()
//    }
//    
//    // MARK: - Actions
//    
//    @IBAction func sendButtonTapped(_ sender: UIBarButtonItem) {
//        saveScheduleRequest()
//    }
//    
//    // MARK: - Fetch Pet Names Using the User's petIds
//    
//    private func fetchPetNamesForCurrentUser() {
//        guard let currentUser = Auth.auth().currentUser else {
//            print("No logged in user found.")
//            petPickerButton.isEnabled = false
//            return
//        }
//        
//        let db = Firestore.firestore()
//        print("Current User UID: \(currentUser.uid)")
//        
//        // First, fetch the user document to get the petIds array.
//        let userDocRef = db.collection("users").document(currentUser.uid)
//        userDocRef.getDocument { [weak self] (document, error) in
//            guard let self = self else { return }
//            if let error = error {
//                print("Error fetching user document: \(error.localizedDescription)")
//                self.petPickerButton.isEnabled = false
//                return
//            }
//            
//            guard let document = document, document.exists,
//                  let data = document.data() else {
//                print("User document does not exist.")
//                self.petPickerButton.isEnabled = false
//                return
//            }
//            
//            // Retrieve the petIds array from the user document.
//            if let petIds = data["petIds"] as? [String], !petIds.isEmpty {
//                print("User petIds: \(petIds)")
//                // Use a Firestore query to fetch all pet documents whose document IDs are in petIds.
//                // Note: The "in" query supports up to 10 values.
//                db.collection("Pets")
//                    .whereField(FieldPath.documentID(), in: petIds)
//                    .getDocuments { snapshot, error in
//                        DispatchQueue.main.async {
//                            if let error = error {
//                                print("Error fetching pets: \(error.localizedDescription)")
//                                self.petNames = []
//                            } else if let snapshot = snapshot {
//                                print("Found \(snapshot.documents.count) pet documents for current user.")
//                                var names: [String] = []
//                                for document in snapshot.documents {
//                                    print("Pet document data: \(document.data())")
//                                    if let petName = document.data()["petName"] as? String {
//                                        names.append(petName)
//                                    } else {
//                                        print("petName field not found in document with ID: \(document.documentID)")
//                                    }
//                                }
//                                self.petNames = names
//                            }
//                            
//                            print("Fetched Pet Names: \(self.petNames)")
//                            
//                            if self.petNames.isEmpty {
//                                let alert = UIAlertController(title: "No Pet Added", message: "You currently have no pets added. Please add a pet to continue.", preferredStyle: .alert)
//                                alert.addAction(UIAlertAction(title: "Add Pet", style: .default, handler: { _ in
//                                    self.dismiss(animated: true) {
//                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                                        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController else {
//                                            print("Tab bar controller with identifier 'TabBarControllerID' not found.")
//                                            return
//                                        }
//                                        
//                                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                                           let window = scene.windows.first {
//                                            window.rootViewController = tabBarController
//                                            window.makeKeyAndVisible()
//                                            tabBarController.selectedIndex = 2 // Adjust the tab index as needed.
//                                        } else {
//                                            print("Active window not found.")
//                                        }
//                                    }
//                                }))
//                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//                                self.present(alert, animated: true)
//                                self.petPickerButton.isEnabled = false
//                            } else {
//                                self.petPickerButton.isEnabled = true
//                                self.configurePetPickerMenu()
//                            }
//                        }
//                    }
//            } else {
//                print("No petIds found in the user document.")
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "No Pet Added", message: "You currently have no pets added. Please add a pet to continue.", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "Add Pet", style: .default, handler: { _ in
//                        self.dismiss(animated: true) {
//                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                            guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController else {
//                                print("Tab bar controller with identifier 'TabBarControllerID' not found.")
//                                return
//                            }
//                            
//                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                               let window = scene.windows.first {
//                                window.rootViewController = tabBarController
//                                window.makeKeyAndVisible()
//                                tabBarController.selectedIndex = 2 // Adjust the tab index as needed.
//                            } else {
//                                print("Active window not found.")
//                            }
//                        }
//                    }))
//                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//                    self.present(alert, animated: true)
//                    self.petPickerButton.isEnabled = false
//                }
//            }
//        }
//    }
//    
//    // MARK: - Configure Pet Picker Menu
//    
//    private func configurePetPickerMenu() {
//        // Create UIActions for each pet name.
//        let actions: [UIAction] = petNames.map { petName in
//            // Set checkmark if the pet is currently selected.
//            let state: UIMenuElement.State = self.selectedPetNames.contains(petName) ? .on : .off
//            
//            return UIAction(title: petName, state: state) { action in
//                // For single selection, clear previous selections.
//                if self.selectedPetNames.contains(petName) {
//                    self.selectedPetNames.removeAll()
//                } else {
//                    self.selectedPetNames.removeAll()
//                    self.selectedPetNames.insert(petName)
//                }
//                
//                // Update the button title.
//                let selectedTitle = self.selectedPetNames.isEmpty ? "Select Pet" : self.selectedPetNames.joined(separator: ", ")
//                self.petPickerButton.setTitle(selectedTitle, for: .normal)
//                
//                // Refresh the menu to update the checkmark states.
//                self.configurePetPickerMenu()
//            }
//        }
//        
//        // Create the menu with the pet options.
//        let menu = UIMenu(title: "Select Pet", children: actions)
//        petPickerButton.menu = menu
//        petPickerButton.showsMenuAsPrimaryAction = true
//        
//        // Ensure the default title is shown if nothing is selected.
//        if self.selectedPetNames.isEmpty {
//            petPickerButton.setTitle("Select Pet", for: .normal)
//        }
//    }
//    
//    // MARK: - Save Schedule Request
//    
//    func saveScheduleRequest() {
//        guard let currentUser = Auth.auth().currentUser else {
//            self.showAlert(title: "Error", message: "You must be logged in to send a schedule request.")
//            return
//        }
//        
//        let userId = currentUser.uid
//        let startDate = startDatePicker.date
//        let endDate = endDatePicker.date
//        
//        guard endDate >= startDate else {
//            self.showAlert(title: "Error", message: "End date cannot be earlier than the start date.")
//            return
//        }
//        
//        fetchUserName(userId: userId) { [weak self] userName in
//            guard let self = self else { return }
//            
//            // Use the pet selected on the pet picker button. If none, use "Unknown Pet".
//            let petName = self.petPickerButton.title(for: .normal) ?? "Unknown Pet"
//            let petPickup = self.petPickupSwitch.isOn
//            let petDropoff = self.petDropoffSwitch.isOn
//            let instructions = self.caretakingInstructionsTextView.text ?? ""
//            let requestId = UUID().uuidString
//            
//            let requestData: [String: Any] = [
//                "requestId": requestId,
//                "userId": userId,
//                "userName": userName,
//                "petName": petName,
//                "startDate": Timestamp(date: startDate),
//                "endDate": Timestamp(date: endDate),
//                "petPickup": petPickup,
//                "petDropoff": petDropoff,
//                "instructions": instructions,
//                "status": "available", // Initially available before assigning caretaker
//                "timestamp": Timestamp(date: Date())
//            ]
//            
//            FirebaseManager.shared.saveScheduleRequestData(data: requestData) { error in
//                if let error = error {
//                    print("Failed to save schedule request: \(error.localizedDescription)")
//                    self.showAlert(title: "Error", message: "Failed to save the schedule request.")
//                } else {
//                    print("Schedule request saved successfully! Now auto-assigning caretaker...")
//                    DispatchQueue.main.async {
//                        self.showAlert(title: "Success", message: "Your request is sent!")
//                    }
//                    
//                    FirebaseManager.shared.autoAssignCaretaker(petName: petName, requestId: requestId) { error in
//                        if let error = error {
//                            print("Failed to auto-assign caretaker: \(error.localizedDescription)")
//                        } else {
//                            print("Caretaker successfully assigned for request: \(requestId)")
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func fetchUserName(userId: String, completion: @escaping (String) -> Void) {
//        let usersCollection = Firestore.firestore().collection("users")
//        usersCollection.document(userId).getDocument { document, error in
//            if let error = error {
//                print("Failed to fetch user name: \(error.localizedDescription)")
//                completion("Anonymous User") // Fallback if fetching fails
//            } else if let document = document, let data = document.data(), let name = data["name"] as? String {
//                completion(name)
//            } else {
//                completion("Anonymous User")
//            }
//        }
//    }
//    
//    func showAlert(title: String, message: String) {
//        DispatchQueue.main.async {
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            self.present(alert, animated: true)
//        }
//    }
//}
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - Schedule_Request View Controller
class Schedule_Request: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var petPickerButton: UIButton!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var petPickupSwitch: UISwitch!
    @IBOutlet weak var petDropoffSwitch: UISwitch!
    @IBOutlet weak var caretakingInstructionsTextView: UITextView!
    
    private var petNames: [String] = []
    private var selectedPetNames = Set<String>()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        petPickerButton.setTitle("Select Pet", for: .normal)
        fetchPetNamesForCurrentUser()
    }
    
    // MARK: - IBAction for Add Address button
    @IBAction func addAddressButtonTapped(_ sender: UIButton) {
        // Ensure your storyboard segue identifier is "GoToAddAddress"
        performSegue(withIdentifier: "GoToAddAddress", sender: nil)
    }
    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToAddAddress" {
            if let navController = segue.destination as? UINavigationController,
               let destination = navController.topViewController as? Add_Address {
                destination.delegate = self
                destination.selectedPetName = petPickerButton.title(for: .normal) ?? ""
                destination.startDate = startDatePicker.date
                destination.endDate = endDatePicker.date
                destination.isPetPickup = petPickupSwitch.isOn
                destination.isPetDropoff = petDropoffSwitch.isOn
                destination.instructions = caretakingInstructionsTextView.text
            } else if let destination = segue.destination as? Add_Address {
                destination.delegate = self
                destination.selectedPetName = petPickerButton.title(for: .normal) ?? ""
                destination.startDate = startDatePicker.date
                destination.endDate = endDatePicker.date
                destination.isPetPickup = petPickupSwitch.isOn
                destination.isPetDropoff = petDropoffSwitch.isOn
                destination.instructions = caretakingInstructionsTextView.text
            }
        }
    }


    // MARK: - Fetch Pet Names for the Current User
    private func fetchPetNamesForCurrentUser() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No logged in user found.")
            petPickerButton.isEnabled = false
            return
        }
        
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(currentUser.uid)
        
        userDocRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                self.petPickerButton.isEnabled = false
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("User document does not exist.")
                self.petPickerButton.isEnabled = false
                return
            }
            
            if let petIds = data["petIds"] as? [String], !petIds.isEmpty {
                db.collection("Pets")
                    .whereField(FieldPath.documentID(), in: petIds)
                    .getDocuments { snapshot, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error fetching pets: \(error.localizedDescription)")
                                self.petNames = []
                            } else if let snapshot = snapshot {
                                var names: [String] = []
                                for doc in snapshot.documents {
                                    if let petName = doc.data()["petName"] as? String {
                                        names.append(petName)
                                    }
                                }
                                self.petNames = names
                            }
                            
                            if self.petNames.isEmpty {
                                self.handleNoPetsFound()
                                self.petPickerButton.isEnabled = false
                            } else {
                                self.petPickerButton.isEnabled = true
                                self.configurePetPickerMenu()
                            }
                        }
                    }
            } else {
                DispatchQueue.main.async {
                    self.handleNoPetsFound()
                }
            }
        }
    }
    
    private func handleNoPetsFound() {
        let alert = UIAlertController(title: "No Pet Added",
                                      message: "You currently have no pets. Please add a pet to continue.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add Pet", style: .default, handler: { _ in
            self.dismiss(animated: true) {
                // Adjust this logic to navigate to a screen where the user can add a pet.
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let tabBarController =
                    storyboard.instantiateViewController(withIdentifier: "TabBarControllerID")
                    as? UITabBarController else {
                        print("Tab bar controller with ID not found.")
                        return
                    }
                
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first {
                    window.rootViewController = tabBarController
                    window.makeKeyAndVisible()
                    tabBarController.selectedIndex = 2
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Pet Picker Menu
    private func configurePetPickerMenu() {
        let actions = petNames.map { petName -> UIAction in
            let state: UIMenuElement.State = selectedPetNames.contains(petName) ? .on : .off
            return UIAction(title: petName, state: state) { [weak self] _ in
                guard let self = self else { return }
                // For single selection, clear any existing selection before adding the new one.
                if self.selectedPetNames.contains(petName) {
                    self.selectedPetNames.removeAll()
                } else {
                    self.selectedPetNames.removeAll()
                    self.selectedPetNames.insert(petName)
                }
                let title = self.selectedPetNames.isEmpty ? "Select Pet" : self.selectedPetNames.joined(separator: ", ")
                self.petPickerButton.setTitle(title, for: .normal)
                self.configurePetPickerMenu()
            }
        }
        
        let menu = UIMenu(title: "Select Pet", children: actions)
        petPickerButton.menu = menu
        petPickerButton.showsMenuAsPrimaryAction = true
        
        if selectedPetNames.isEmpty {
            petPickerButton.setTitle("Select Pet", for: .normal)
        }
    }
    
    // MARK: - Save Schedule Request
    func saveScheduleRequest(addressData: [String: Any]? = nil,
                               completion: @escaping (Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "You must be logged in.")
            completion(NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        
        let userId = currentUser.uid
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        
        guard endDate >= startDate else {
            showAlert(title: "Error", message: "End date must be after start date.")
            completion(NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        
        fetchUserName(userId: userId) { [weak self] userName in
            guard let self = self else { return }
            
            // Use the selected pet name if available.
            let petName = (self.petPickerButton.title(for: .normal) != "Select Pet")
                            ? self.petPickerButton.title(for: .normal)! : "Unknown Pet"
            let petPickup = self.petPickupSwitch.isOn
            let petDropoff = self.petDropoffSwitch.isOn
            let instructions = self.caretakingInstructionsTextView.text ?? ""
            let requestId = UUID().uuidString
            
            // Prepare the schedule request data.
            var requestData: [String: Any] = [
                "requestId": requestId,
                "userId": userId,
                "userName": userName,
                "petName": petName,
                "startDate": Timestamp(date: startDate),
                "endDate": Timestamp(date: endDate),
                "petPickup": petPickup,
                "petDropoff": petDropoff,
                "instructions": instructions,
                "status": "available",
                "timestamp": Timestamp(date: Date())
            ]
            
            // Merge address data (if provided) into the request data.
            if let addressData = addressData {
                for (key, value) in addressData {
                    requestData[key] = value
                }
            }
            
            // Save to Firebase using FirebaseManager.
            FirebaseManager.shared.saveScheduleRequestData(data: requestData) { error in
                if let error = error {
                    print("Failed to save schedule request: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to save the schedule request.")
                    completion(error)
                } else {
                    print("Schedule request saved successfully!")
                    // Trigger auto-assignment of caretaker.
                    FirebaseManager.shared.autoAssignCaretaker(petName: petName, requestId: requestId) { assignError in
                        if let assignError = assignError {
                            print("Auto-assign caretaker error: \(assignError.localizedDescription)")
                        } else {
                            print("Caretaker assigned for request: \(requestId)")
                        }
                    }
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - Fetch User Name
    func fetchUserName(userId: String, completion: @escaping (String) -> Void) {
        Firestore.firestore().collection("users")
            .document(userId)
            .getDocument { document, error in
                if let error = error {
                    print("Failed to fetch user name: \(error.localizedDescription)")
                    completion("Anonymous User")
                } else if let doc = document,
                          let data = doc.data(),
                          let name = data["name"] as? String {
                    completion(name)
                } else {
                    completion("Anonymous User")
                }
            }
    }
    
    // MARK: - Show Alert Helper
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}


// MARK: - AddAddressDelegate Conformance
extension Schedule_Request: AddAddressDelegate {
    func didSubmitAddress(addressData: [String: Any]) {
        print("Delegate received address data: \(addressData)")
        // Call saveScheduleRequest with the provided address data.
        self.saveScheduleRequest(addressData: addressData) { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("Error scheduling request: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Could not schedule request.")
                } else {
                    // Show the success alert that the schedule request was sent.
                    let alert = UIAlertController(title: "Success",
                                                  message: "Your schedule request has been sent.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        // Once the alert is dismissed, pop back to the previous screen.
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
