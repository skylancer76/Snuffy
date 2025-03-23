//import UIKit
//import FirebaseFirestore
//
//class Add_Vaccination: UITableViewController {
//    
//    var petId: String?
//    
//    // Outlets for the Static Table Cells
//    @IBOutlet weak var vaccineNameTextField: UITextField!
//    @IBOutlet weak var vaccineTypeTextField: UITextField!
//    
//    // Outlets for the Date Pickers
//    @IBOutlet weak var dateOfVaccinePicker: UIDatePicker!
//    @IBOutlet weak var expiryDatePicker: UIDatePicker!
//    @IBOutlet weak var nextDueDatePicker: UIDatePicker!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("Pet ID: \(petId ?? "No Pet ID passed")")
//        let currentDate = Date()
//        dateOfVaccinePicker.date = currentDate
//        expiryDatePicker.date = currentDate
//        nextDueDatePicker.date = currentDate
//    }
//    
//    // Save the vaccination details to Firebase
//    @IBAction func saveVaccination(_ sender: UIBarButtonItem) {
//        print("Save Button Clicked")
//        guard let petId = petId else {
//            print("Pet ID is missing!")
//            return
//        }
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//        
//        let dateOfVaccination = dateFormatter.string(from: dateOfVaccinePicker.date)
//        let expiryDate = dateFormatter.string(from: expiryDatePicker.date)
//        let nextDueDate = dateFormatter.string(from: nextDueDatePicker.date)
//        
//        // Create a VaccinationDetails object without specifying vaccineId (it remains nil)
//        let vaccination = VaccinationDetails(
//            vaccineName: vaccineNameTextField.text ?? "",
//            vaccineType: vaccineTypeTextField.text ?? "",
//            dateOfVaccination: dateOfVaccination,
//            expiryDate: expiryDate,
//            nextDueDate: nextDueDate
//        )
//        
//        FirebaseManager.shared.saveVaccinationData(petId: petId, vaccination: vaccination) { error in
//            if let error = error {
//                print("Failed to save vaccination: \(error.localizedDescription)")
//            } else {
//                print("Vaccination saved successfully!")
//                let alertController = UIAlertController(title: nil, message: "Vaccination Data Added", preferredStyle: .alert)
//                self.present(alertController, animated: true, completion: nil)
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    alertController.dismiss(animated: true, completion: {
//                        NotificationCenter.default.post(name: NSNotification.Name("VaccinationDataAdded"), object: nil)
//                        self.navigationController?.popViewController(animated: true)
//                    })
//                }
//            }
//        }
//    }
//}


import UIKit
import FirebaseFirestore

class Add_Vaccination: UITableViewController, UITextViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var vaccineNameButton: UIButton!
    @IBOutlet weak var dateOfVaccinePicker: UIDatePicker!
    @IBOutlet weak var expiresSwitch: UISwitch!
    @IBOutlet weak var expiryDatePicker: UIDatePicker!
    @IBOutlet weak var notifyUponExpirySwitch: UISwitch!
    @IBOutlet weak var notesTextView: UITextView!
    
    // MARK: - Properties
    var petId: String?
    
    // Include "Other" directly in the list
    let vaccineOptions = [
        "DHPPi", "Kennel Cough", "Distemper", "RL",
        "Lyme Disease", "Lepto", "Parainfluenza",
        "Canine Hepatitis", "Puppy DP", "Rabies",
        "Parvovirus", "Bordatella", "Adenovirus",
        "Other"
    ]
    
    var selectedVaccineName: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        print("Pet ID: \(petId ?? "No Pet ID passed")")
        
        // Button defaults
        vaccineNameButton.setTitle("Select", for: .normal)
        vaccineNameButton.setTitleColor(.tertiaryLabel, for: .normal)
        
        // Date pickers default
        dateOfVaccinePicker.date = Date()
        expiryDatePicker.date = Date()
        
        // Make the notes text view editable
        notesTextView.delegate = self
        notesTextView.isEditable = true
        // If you want it scrollable inside the cell, set isScrollEnabled = true
        // If you want the cell to grow as you type, set isScrollEnabled = false
    }
    
    // MARK: - Actions
    
    @IBAction func expiresSwitchToggled(_ sender: UISwitch) {
        // Animate collapse/expand of the expiry date row
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func selectVaccineTapped(_ sender: UIButton) {
        // Present an action sheet with all vaccines, including "Other"
        let alert = UIAlertController(title: "Select Vaccine", message: nil, preferredStyle: .actionSheet)
        
        for vaccine in vaccineOptions {
            alert.addAction(UIAlertAction(title: vaccine, style: .default, handler: { _ in
                if vaccine == "Other" {
                    // Prompt user for a custom vaccine name
                    let inputAlert = UIAlertController(
                        title: "Enter Vaccine Name",
                        message: "Please enter the name of the vaccine",
                        preferredStyle: .alert
                    )
                    inputAlert.addTextField { textField in
                        textField.placeholder = "Vaccine Name"
                    }
                    inputAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    inputAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        if let text = inputAlert.textFields?.first?.text, !text.isEmpty {
                            self.selectedVaccineName = text
                            self.vaccineNameButton.setTitle(text, for: .normal)
                            self.vaccineNameButton.setTitleColor(.label, for: .normal)
                        }
                    }))
                    self.present(inputAlert, animated: true, completion: nil)
                } else {
                    // Standard vaccine selected
                    self.selectedVaccineName = vaccine
                    self.vaccineNameButton.setTitle(vaccine, for: .normal)
                    self.vaccineNameButton.setTitleColor(.label, for: .normal)
                }
            }))
        }
        
        // Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // iPad popover
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        
        present(alert, animated: true)
    }
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        // Dismiss the current screen
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveVaccination(_ sender: UIBarButtonItem) {
        print("Save Button Clicked")
        
        guard let petId = petId else {
            print("Pet ID is missing!")
            return
        }
        guard let vaccineName = selectedVaccineName else {
            print("Please select a vaccine")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let vaccination = VaccinationDetails(
            vaccineName: vaccineName,
            dateOfVaccination: dateFormatter.string(from: dateOfVaccinePicker.date),
            expires: expiresSwitch.isOn,
            expiryDate: expiresSwitch.isOn ? dateFormatter.string(from: expiryDatePicker.date) : nil,
            notifyUponExpiry: notifyUponExpirySwitch.isOn,
            notes: notesTextView.text
        )
        
        FirebaseManager.shared.saveVaccinationData(petId: petId, vaccination: vaccination) { error in
            if let error = error {
                print("Failed to save vaccination: \(error.localizedDescription)")
            } else {
                print("Vaccination saved successfully!")
                
                let alertController = UIAlertController(
                    title: nil,
                    message: "Vaccination Data Added",
                    preferredStyle: .alert
                )
                self.present(alertController, animated: true, completion: nil)
                
                // Dismiss alert after 1 second, then dismiss this modal
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    alertController.dismiss(animated: true) {
                        NotificationCenter.default.post(name: NSNotification.Name("VaccinationDataAdded"), object: nil)
                        
                        // Dismiss the modal sheet (instead of pop)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension Add_Vaccination {

    // Collapses or expands the Expiry Date row (Section 1, Row 1 in this example).
    // Leaves the "Notes" row to the storyboard's set height (Section 2, Row 0).
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        // Example layout:
        // Section 0: Vaccine Name & Date
        // Section 1: row 0 => "Expires" switch
        //            row 1 => "Expiry Date"
        //            row 2 => "Notify upon expiry"
        // Section 2: row 0 => "Notes" cell

        // Collapse "Expiry Date" cell if switch is off
        if indexPath.section == 1 && indexPath.row == 1 {
            return expiresSwitch.isOn ? UITableView.automaticDimension : 0
        }

        // For the Notes row (section 2, row 0), let the storyboard’s static height apply.
        // If you do want a fixed height in code, you can do:
        // if indexPath.section == 2 && indexPath.row == 0 { return 100 }

        return UITableView.automaticDimension
    }
}
