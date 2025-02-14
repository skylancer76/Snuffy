//
//  Shedule Dogwalker Request.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 13/02/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

class Schedule_Dogwalker_Request: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var petPickerButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var walkingInstructionsTextView: UITextView!
    
    private var petNames: [String] = []
    private var selectedPetNames = Set<String>()
    
    // We store the current request ID so that when the address is submitted later,
    // we update the same request document.
    var currentRequestId: String?
    var selectedPetName: String = ""
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        petPickerButton.setTitle("Select Pet", for: .normal)
        fetchPetNamesForCurrentUser()
        datePicker.minimumDate = Date()
    }
    
    // MARK: - IBAction for Add Address button
    @IBAction func addAddressButtonTapped(_ sender: UIButton) {
        // If a request has not been created yet, create it now.
        if currentRequestId == nil {
            sender.isEnabled = false
            saveDogWalkerRequest { [weak self] error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    sender.isEnabled = true
                    if let error = error {
                        print("Error scheduling dog walker request: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Could not schedule request.")
                    } else {
                        print("Dog walker request saved with ID: \(self.currentRequestId ?? "nil"). Now transitioning to address screen.")
                       
                    }
                }
            }
        } 
    }
    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DogWalker" {
            if let navController = segue.destination as? UINavigationController,
               let destination = navController.topViewController as? Add_Address {
                destination.delegate = self
                destination.selectedPetName = petPickerButton.title(for: .normal) ?? ""
                destination.startDate = startTimePicker.date
                destination.endDate = endTimePicker.date
                destination.instructions = walkingInstructionsTextView.text
                destination.requestType = .dogwalker
                destination.currentRequestId = self.currentRequestId
            } else if let destination = segue.destination as? Add_Address {
                destination.delegate = self
                destination.selectedPetName = petPickerButton.title(for: .normal) ?? ""
                destination.startDate = startTimePicker.date
                destination.endDate = endTimePicker.date
                destination.instructions = walkingInstructionsTextView.text
                destination.requestType = .dogwalker
                destination.currentRequestId = self.currentRequestId
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
                                self.petNames = snapshot.documents.compactMap { doc in
                                    return doc.data()["petName"] as? String
                                }
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
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController else {
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
        // If no pet is selected yet, default to the first pet (if available)
        if selectedPetNames.isEmpty, let firstPet = petNames.first {
            selectedPetNames.insert(firstPet)
            petPickerButton.setTitle(firstPet, for: .normal)
        }
        
        let actions = petNames.map { petName -> UIAction in
            let state: UIMenuElement.State = selectedPetNames.contains(petName) ? .on : .off
            return UIAction(title: petName, state: state) { [weak self] _ in
                guard let self = self else { return }
                self.selectedPetNames.removeAll()
                self.selectedPetNames.insert(petName)
                let title = self.selectedPetNames.joined(separator: ", ")
                self.petPickerButton.setTitle(title, for: .normal)
                self.configurePetPickerMenu()
            }
        }
        
        let menu = UIMenu(title: "Select Pet", children: actions)
        petPickerButton.menu = menu
        petPickerButton.showsMenuAsPrimaryAction = true
    }
    
    // MARK: - Save Dog Walker Request
    func saveDogWalkerRequest(addressData: [String: Any]? = nil, completion: @escaping (Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "You must be logged in.")
            completion(NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        let userId = currentUser.uid
        let requestId = UUID().uuidString
        self.currentRequestId = requestId
        
        // Combine date with start and end times.
        let selectedDate = datePicker.date
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        guard let dateOnly = calendar.date(from: dateComponents) else {
            showAlert(title: "Error", message: "Invalid date selected.")
            completion(NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        let startTime = startTimePicker.date
        let endTime = endTimePicker.date
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        var combinedStartComponents = calendar.dateComponents([.year, .month, .day], from: dateOnly)
        combinedStartComponents.hour = startComponents.hour
        combinedStartComponents.minute = startComponents.minute
        guard let combinedStart = calendar.date(from: combinedStartComponents) else {
            showAlert(title: "Error", message: "Invalid start time.")
            completion(NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        var combinedEndComponents = calendar.dateComponents([.year, .month, .day], from: dateOnly)
        combinedEndComponents.hour = endComponents.hour
        combinedEndComponents.minute = endComponents.minute
        guard let combinedEnd = calendar.date(from: combinedEndComponents) else {
            showAlert(title: "Error", message: "Invalid end time.")
            completion(NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        guard combinedEnd >= combinedStart else {
            showAlert(title: "Error", message: "End time must be after start time.")
            completion(NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        
        fetchUserName(userId: userId) { [weak self] userName in
            guard let self = self else { return }
            let petName = self.petPickerButton.title(for: .normal) ?? "Unknown Pet"
            let instructions = self.walkingInstructionsTextView.text ?? ""
            var requestData: [String: Any] = [
                "requestId": requestId,
                "userId": userId,
                "userName": userName,
                "petName": petName,
                "date": Timestamp(date: self.datePicker.date),
                "startTime": Timestamp(date: self.startTimePicker.date),
                "endTime": Timestamp(date: self.endTimePicker.date),
                "instructions": instructions,
                "status": "available",
                "dogWalkerId": "",
                "timestamp": Timestamp(date: Date())
            ]
            if let addressData = addressData {
                for (key, value) in addressData {
                    requestData[key] = value
                }
            }
            print("Final Dog Walker Request Data: \(requestData)")
            FirebaseManager.shared.saveDogWalkerRequestData(data: requestData) { error in
                if let error = error {
                    print("Failed to save dog walker request: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to save the dog walker request.")
                    completion(error)
                } else {
                    print("Dog walker request saved successfully!")
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - Alert Helper
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Fetch User Name
    func fetchUserName(userId: String, completion: @escaping (String) -> Void) {
        let usersCollection = Firestore.firestore().collection("users")
        print("Attempting to fetch user name for userId: \(userId)")
        usersCollection.document(userId).getDocument { document, error in
            if let error = error {
                print("Failed to fetch user name: \(error.localizedDescription)")
                completion("Anonymous User")
            } else if let document = document, document.exists,
                      let data = document.data(),
                      let name = data["name"] as? String, !name.isEmpty {
                print("Fetched user name: \(name)")
                completion(name)
            } else {
                print("Document exists but no valid 'name' field found")
                completion("Anonymous User")
            }
        }
    }
}

// MARK: - AddAddressDelegate Conformance
extension Schedule_Dogwalker_Request: AddAddressDelegate {
    func didSubmitAddress(addressData: [String: Any]) {
        print("Delegate received address data: \(addressData)")
        guard let requestId = self.currentRequestId else {
            print("Error: No request ID found.")
            return
        }
        let requestRef = Firestore.firestore().collection("dogWalkerRequests").document(requestId)
        requestRef.updateData(addressData) { error in
            if let error = error {
                print("Error updating dog walker request with address: \(error.localizedDescription)")
            } else {
                print("Successfully updated dog walker request with address!")
                let petName = self.petPickerButton.title(for: .normal) ?? "Unknown Pet"
                let userLocation: CLLocation? = {
                    if let lat = addressData["latitude"] as? Double,
                       let lon = addressData["longitude"] as? Double {
                        return CLLocation(latitude: lat, longitude: lon)
                    }
                    return nil
                }()
                FirebaseManager.shared.autoAssignDogWalker(
                    petName: petName,
                    requestId: requestId,
                    userLocation: userLocation
                ) { assignError in
                    if let assignError = assignError {
                        print("Auto-assign dogwalker error: \(assignError.localizedDescription)")
                    } else {
                        print("Dogwalker assigned for request: \(requestId)")
                    }
                }
            }
        }
    }
}
