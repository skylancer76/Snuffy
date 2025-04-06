//
//  Add Pet Medications.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 02/02/25.
//

import UIKit
import FirebaseFirestore

class Add_Pet_Medications: UITableViewController {
    
    var petId: String?
    
    // Outlets for the static table cells.
    @IBOutlet weak var medicineNameTextField: UITextField!
    @IBOutlet weak var medicineTypeButton: UIButton!
    @IBOutlet weak var purposeTextField: UITextField!
    @IBOutlet weak var frequencyTextField: UITextField!
    @IBOutlet weak var dosageTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    // Options for the medicine type.
    let medicineTypes = ["Tablet", "Syrup", "Ointment", "Injection"]
    
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Pet ID: \(petId ?? "No Pet ID passed")")
        
        // Set default title for the medicine type button.
        medicineTypeButton.setTitle(medicineTypes.first, for: .normal)
        
        // Configure the date pickers to show only date.
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date
        
        setupActivityIndicator()
    }
    
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Medicine Type Selection
    @IBAction func medicineTypeButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Medicine Type",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        // Add an action for each medicine type
        for type in medicineTypes {
            alert.addAction(UIAlertAction(title: type, style: .default, handler: { _ in
                self.medicineTypeButton.setTitle(type, for: .normal)
            }))
        }
        
        // Add a cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // iPad popover anchor
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Save
    @IBAction func saveMedication(_ sender: UIBarButtonItem) {
        guard let petId = petId else {
            print("Pet ID is missing!")
            return
        }
        
        // Retrieve values from UI.
        let medicineName = medicineNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let medicineType = medicineTypeButton.title(for: .normal) ?? ""
        let purpose = purposeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let frequency = frequencyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let dosage = dosageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Validate that required details are provided.
        if medicineName.isEmpty || purpose.isEmpty || frequency.isEmpty || dosage.isEmpty {
            let alert = UIAlertController(
                title: "Incomplete Details",
                message: "Please fill in all required fields before saving.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Format dates as dd/MM/yyyy
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let startDate = dateFormatter.string(from: startDatePicker.date)
        let endDate = dateFormatter.string(from: endDatePicker.date)
        
        // Create a PetMedicationDetails object (Firestore auto-generates ID)
        let medication = PetMedicationDetails(
            medicineName: medicineName,
            medicineType: medicineType,
            purpose: purpose,
            frequency: frequency,
            dosage: dosage,
            startDate: startDate,
            endDate: endDate
        )
        
        activityIndicator.startAnimating()
        // Save to Firestore
        FirebaseManager.shared.savePetMedicationData(petId: petId, medication: medication) { error in
            DispatchQueue.main.async {
                
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    print("Failed to save medication: \(error.localizedDescription)")
                } else {
                    print("Medication saved successfully!")
                    
                    let alertController = UIAlertController(
                        title: nil,
                        message: "Pet Medication Data Added",
                        preferredStyle: .alert
                    )
                    self.present(alertController, animated: true, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        alertController.dismiss(animated: true) {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("PetMedicationDataAdded"),
                                object: nil
                            )
                            // Dismiss the modal sheet
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Cancel
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        // Since this is presented modally, dismiss
        self.dismiss(animated: true, completion: nil)
    }
}
