//
//  Schedule Booking.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 07/01/25.
//

import UIKit
import FirebaseFirestore

class Schedule_Booking: UIViewController {
    var caretakerName: String?
    var caretakerId: String?
    @IBOutlet var datePickerView: UIDatePicker!
    @IBOutlet var selectPetButton: UIButton!
    @IBOutlet var pickUpButton: UIButton!
    @IBOutlet var dropOffButton: UIButton!
    @IBOutlet var instructionsTextView: UITextField!
    @IBOutlet var startTime: UIDatePicker!
    @IBOutlet var submitButton: UIButton!
    
    var startDate: Date?
    var endDate: Date?
    var selectedPets: [String] = []
    var pickUpRequired: Bool = false
    var dropOffRequired: Bool = false
    var caretakerInstructions: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Configure DatePicker for date range selection
        datePickerView.datePickerMode = .date
        datePickerView.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)

        // Configure Pet Selection Menu
        let petMenuActions = createPetMenuActions()
        let petMenu = UIMenu(title: "Select Pets", options: .displayInline, children: petMenuActions)
        
        selectPetButton.menu = petMenu
        selectPetButton.showsMenuAsPrimaryAction = true

        // Configure Pick-Up/Drop-Off Menus
        let pickUpMenu = UIMenu(title: "Pick-Up Required?", options: .displayInline, children: createYesNoMenuActions(isForPickup: true))
        pickUpButton.menu = pickUpMenu
        pickUpButton.showsMenuAsPrimaryAction = true
        
        let dropOffMenu = UIMenu(title: "Drop-Off Required?", options: .displayInline, children: createYesNoMenuActions(isForPickup: false))
        dropOffButton.menu = dropOffMenu
        dropOffButton.showsMenuAsPrimaryAction = true

        // Configure Start Time Picker
        startTime.datePickerMode = .time
        startTime.addTarget(self, action: #selector(startTimeSelected(_:)), for: .valueChanged)
    }
 
    
    private func createPetMenuActions() -> [UIAction] {
        let pets = ["Pet 1", "Pet 2", "Pet 3"]
        return pets.map { pet in
            UIAction(title: pet) { [weak self] _ in
                guard let self = self else { return }
                if self.selectedPets.contains(pet) {
                    self.selectedPets.removeAll { $0 == pet }
                } else {
                    self.selectedPets.append(pet)
                }
                self.updatePetSelectionButtonTitle()
                print("\(self.selectedPets)")
                
            }
        }
    }
    private func updatePetSelectionButtonTitle() {
        if selectedPets.isEmpty {
            selectPetButton.setTitle("Select Pets", for: .normal)
        } else {
            // Join the selected pets with commas and display them
            let petNames = selectedPets.joined(separator: ", ")
            selectPetButton.setTitle("\(petNames)", for: .normal)
        }
    }

    private func createYesNoMenuActions(isForPickup: Bool) -> [UIAction] {
        return [
            UIAction(title: "Yes") { [weak self] _ in
                guard let self = self else { return }
                if isForPickup {
                    self.pickUpRequired = true
                    self.pickUpButton.setTitle("Yes", for: .normal)
                } else {
                    self.dropOffRequired = true
                    self.dropOffButton.setTitle("Yes", for: .normal)
                }
            },
            UIAction(title: "No") { [weak self] _ in
                guard let self = self else { return }
                if isForPickup {
                    self.pickUpRequired = false
                    self.pickUpButton.setTitle("No", for: .normal)
                } else {
                    self.dropOffRequired = false
                    self.dropOffButton.setTitle("No", for: .normal)
                }
            }
        ]
    }

    
    @objc private func dateSelected(_ sender: UIDatePicker) {
        if startDate == nil {
            startDate = sender.date
            print("Start Date Selected: \(startDate!)")
            showAlert(title: "Date Selected", message: "Start date has been selected: \(formatDate(startDate!))")
        } else {
            endDate = sender.date
            print("End Date Selected: \(endDate!)")
            showAlert(title: "Date Selected", message: "End date has been selected: \(formatDate(endDate!))")
            
            if let start = startDate, let end = endDate, end < start {
                print("End date cannot be earlier than the start date!")
                endDate = nil
            }
        }
    }
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    @IBAction func dissMissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func startTimeSelected(_ sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let selectedTime = timeFormatter.string(from: sender.date)
        print("Start Time Selected: \(selectedTime)")
    }

    @IBAction func submitRequest(_ sender: UIButton) {
        // Collect caretaker instructions
        caretakerInstructions = instructionsTextView.text ?? ""
        
        // Validate input
        guard let startDate = startDate, let endDate = endDate else {
            showAlert(title: "Error", message: "Please select a valid date range.")
            return
        }
        
        if selectedPets.isEmpty {
            showAlert(title: "Error", message: "Please select at least one pet.")
            return
        }

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let selectedStartTime = timeFormatter.string(from: startTime.date)
        
        // Save to Firebase Firestore
        let db = Firestore.firestore()
        
        let requestData: [String: Any] = [
            "startDate": startDate,
            "endDate": endDate,
            "startTime": selectedStartTime,
            "selectedPets": selectedPets,
            "pickUpRequired": pickUpRequired,
            "dropOffRequired": dropOffRequired,
            "caretakerInstructions": caretakerInstructions,
            "caretakerName": caretakerName ?? "",
            "caretakerId": caretakerId ?? ""
        ]
        
        db.collection("bookingRequests").addDocument(data: requestData) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to send request: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Success", message: "Your request has been sent!",completion: {
                    self.clearFields()
                    self.navigateToMyBookings()
                })
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    private func clearFields() {
        startDate = nil
        endDate = nil
        selectedPets.removeAll()
        pickUpRequired = false
        dropOffRequired = false
        caretakerInstructions = ""

        datePickerView.setDate(Date(), animated: false)
        selectPetButton.setTitle("Select Pets", for: .normal)
        pickUpButton.setTitle("Pick-Up Required?", for: .normal)
        dropOffButton.setTitle("Drop-Off Required?", for: .normal)
        startTime.setDate(Date(), animated: false)
        instructionsTextView.text = ""
    }
    private func navigateToMyBookings() {
        guard let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarControllerID") as? UITabBarController else {
            print("Error: Could not instantiate UITabBarController.")
            return
        }
        
        tabBarController.selectedIndex = 1 // Replace 1 with the index of the "My Bookings" tab
        self.view.window?.rootViewController = tabBarController
        self.view.window?.makeKeyAndVisible()
    }
}

