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
    
    // A UIDatePicker for selecting the *date* of the walk.
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // UIDatePickers for selecting *time* (start and end).
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    @IBOutlet weak var walkingInstructionsTextView: UITextView!
    
    private var petNames: [String] = []
    private var selectedPetNames = Set<String>()
    
    // We store the current request ID so that when the address is submitted later,
    // we can trigger the auto‑assignment using this ID.
    var currentRequestId: String?
    var selectedPetName: String = ""
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        petPickerButton.setTitle("Select Pet", for: .normal)
        fetchPetNamesForCurrentUser()
    }
    
    // MARK: - IBAction for Add Address button
    @IBAction func addAddressButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
            
            saveDogWalkerRequest { [weak self] error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    sender.isEnabled = true // Re-enable button after saving request
                    
                    if let error = error {
                        print("Error scheduling dog walker request: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Could not schedule request.")
                    } else {
                        print("Dog walker request saved. Now transitioning to address screen.")
                        
                        // Ensure segue is performed only once
                        if self.shouldPerformSegue(withIdentifier: "DogWalker", sender: nil) {
                            self.performSegue(withIdentifier: "DogWalker", sender: nil)
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
                
                // Pass the raw date/time picks to Add_Address.
                destination.startDate = startTimePicker.date
                destination.endDate = endTimePicker.date
                destination.instructions = walkingInstructionsTextView.text
            } else if let destination = segue.destination as? Add_Address {
                destination.delegate = self
                destination.selectedPetName = petPickerButton.title(for: .normal) ?? ""
                destination.startDate = startTimePicker.date
                destination.endDate = endTimePicker.date
                destination.instructions = walkingInstructionsTextView.text
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
    
    // MARK: - Fetch User Name
    func fetchUserName(userId: String, completion: @escaping (String) -> Void) {
        let usersCollection = Firestore.firestore().collection("users")
        print("Attempting to fetch user name for userId: \(userId)")
        usersCollection.document(userId).getDocument { document, error in
            if let error = error {
                print("Failed to fetch user name: \(error.localizedDescription)")
                completion("Anonymous User")
            } else if let document = document, document.exists {
                if let data = document.data(), let name = data["name"] as? String, !name.isEmpty {
                    print("Fetched user name: \(name)")
                    completion(name)
                } else {
                    print("Document exists but no valid 'name' field found")
                    completion("Anonymous User")
                }
            } else {
                print("Document does not exist for userId: \(userId)")
                completion("Anonymous User")
            }
        }
    }
    
    // MARK: - Save Dog Walker Request (Without Immediate Auto‑Assignment)
    func saveDogWalkerRequest(addressData: [String: Any]? = nil,
                              completion: @escaping (Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "You must be logged in.")
            completion(NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        
        let userId = currentUser.uid
        let requestId = UUID().uuidString
        self.currentRequestId = requestId
        
        // 1) Get the chosen date (day/month/year) and reset to midnight.
        let selectedDate = datePicker.date
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        guard let dateOnly = calendar.date(from: dateComponents) else {
            showAlert(title: "Error", message: "Invalid date selected.")
            completion(NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        
        // 2) Get the chosen start and end times (hour/minute) from the pickers.
        let startTime = startTimePicker.date
        let endTime = endTimePicker.date
        
        // 3) Combine dateOnly with startTime and endTime for validation.
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        var combinedStartComponents = calendar.dateComponents([.year, .month, .day], from: dateOnly)
        combinedStartComponents.hour = startComponents.hour
        combinedStartComponents.minute = startComponents.minute
        guard let combinedStart = calendar.date(from: combinedStartComponents) else {
            showAlert(title: "Error", message: "Invalid start time.")
            completion(NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        
        var endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        var combinedEndComponents = calendar.dateComponents([.year, .month, .day], from: dateOnly)
        combinedEndComponents.hour = endComponents.hour
        combinedEndComponents.minute = endComponents.minute
        guard let combinedEnd = calendar.date(from: combinedEndComponents) else {
            showAlert(title: "Error", message: "Invalid end time.")
            completion(NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        
        // Ensure that the end time is not before the start time.
        guard combinedEnd >= combinedStart else {
            showAlert(title: "Error", message: "End time must be after start time.")
            completion(NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        
        // Fetch the user's name, then build the request data.
        fetchUserName(userId: userId) { [weak self] userName in
                    guard let self = self else { return }
                    print("User name returned from fetchUserName: \(userName)")

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
            
            print("Received Address Data before merging: \(addressData ?? [:])")

                        // Merge address data
                        if let addressData = addressData {
                            for (key, value) in addressData {
                                requestData[key] = value
                            }
                        }

                        // ✅ Print the final requestData that will be saved
                        print("Final Dog Walker Request Data: \(requestData)")

                        // Save request data in Firestore
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

// MARK: - AddAddressDelegate
extension Schedule_Dogwalker_Request: AddAddressDelegate {
    func didSubmitAddress(addressData: [String: Any]) {
        print("Delegate received address data: \(addressData)")
        
        // Ensure that we're updating the existing request, not creating a new one
        guard let requestId = self.currentRequestId else {
            print("Error: No request ID found.")
            return
        }

        let db = Firestore.firestore()
        let requestRef = db.collection("dogWalkerRequests").document(requestId)
        
        // Update the existing Firestore request with address details
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

                // ✅ Now that address is updated, trigger auto-assignment
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
