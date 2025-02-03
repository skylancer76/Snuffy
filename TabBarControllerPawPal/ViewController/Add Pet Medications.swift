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
    @IBOutlet weak var medicineTypeButton: UIButton!  // Pop-up button for medicine type.
    @IBOutlet weak var purposeTextField: UITextField!
    @IBOutlet weak var frequencyTextField: UITextField!
    @IBOutlet weak var dosageTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    // Options for the medicine type.
    let medicineTypes = ["Tablet", "Syrup", "Ointment", "Injection"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Pet ID: \(petId ?? "No Pet ID passed")")
        
        // Set default title for the medicine type button.
        medicineTypeButton.setTitle(medicineTypes.first, for: .normal)
        
        // Configure the date pickers to show only date.
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date
    }
    
    // Action for when the medicine type button is tapped.
    @IBAction func medicineTypeButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Medicine Type", message: nil, preferredStyle: .actionSheet)
        
        for type in medicineTypes {
            alert.addAction(UIAlertAction(title: type, style: .default, handler: { _ in
                self.medicineTypeButton.setTitle(type, for: .normal)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // For iPad compatibility.
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // Save the pet medication details to Firestore.
    @IBAction func saveMedication(_ sender: UIBarButtonItem) {
        guard let petId = petId else {
            print("Pet ID is missing!")
            return
        }
        
        // Retrieve values from UI.
        let medicineName = medicineNameTextField.text ?? ""
        let medicineType = medicineTypeButton.title(for: .normal) ?? ""
        let purpose = purposeTextField.text ?? ""
        let frequency = frequencyTextField.text ?? ""
        let dosage = dosageTextField.text ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let startDate = dateFormatter.string(from: startDatePicker.date)
        let endDate = dateFormatter.string(from: endDatePicker.date)
        
        // Create a PetMedicationDetails object (medicationId remains nil so Firestore auto‑generates it).
        let medication = PetMedicationDetails(
            medicineName: medicineName,
            medicineType: medicineType,
            purpose: purpose,
            frequency: frequency,
            dosage: dosage,
            startDate: startDate,
            endDate: endDate
        )
        
        FirebaseManager.shared.savePetMedicationData(petId: petId, medication: medication) { error in
            if let error = error {
                print("Failed to save medication: \(error.localizedDescription)")
            } else {
                print("Medication saved successfully!")
                let alertController = UIAlertController(title: nil, message: "Pet Medication Data Added", preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    alertController.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: NSNotification.Name("PetMedicationDataAdded"), object: nil)
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }
}
