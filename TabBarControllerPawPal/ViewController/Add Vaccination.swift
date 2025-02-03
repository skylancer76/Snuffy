import UIKit
import FirebaseFirestore

class Add_Vaccination: UITableViewController {
    
    var petId: String?
    
    // Outlets for the Static Table Cells
    @IBOutlet weak var vaccineNameTextField: UITextField!
    @IBOutlet weak var vaccineTypeTextField: UITextField!
    
    // Outlets for the Date Pickers
    @IBOutlet weak var dateOfVaccinePicker: UIDatePicker!
    @IBOutlet weak var expiryDatePicker: UIDatePicker!
    @IBOutlet weak var nextDueDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Pet ID: \(petId ?? "No Pet ID passed")")
        let currentDate = Date()
        dateOfVaccinePicker.date = currentDate
        expiryDatePicker.date = currentDate
        nextDueDatePicker.date = currentDate
    }
    
    // Save the vaccination details to Firebase
    @IBAction func saveVaccination(_ sender: UIBarButtonItem) {
        print("Save Button Clicked")
        guard let petId = petId else {
            print("Pet ID is missing!")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let dateOfVaccination = dateFormatter.string(from: dateOfVaccinePicker.date)
        let expiryDate = dateFormatter.string(from: expiryDatePicker.date)
        let nextDueDate = dateFormatter.string(from: nextDueDatePicker.date)
        
        // Create a VaccinationDetails object without specifying vaccineId (it remains nil)
        let vaccination = VaccinationDetails(
            vaccineName: vaccineNameTextField.text ?? "",
            vaccineType: vaccineTypeTextField.text ?? "",
            dateOfVaccination: dateOfVaccination,
            expiryDate: expiryDate,
            nextDueDate: nextDueDate
        )
        
        FirebaseManager.shared.saveVaccinationData(petId: petId, vaccination: vaccination) { error in
            if let error = error {
                print("Failed to save vaccination: \(error.localizedDescription)")
            } else {
                print("Vaccination saved successfully!")
                let alertController = UIAlertController(title: nil, message: "Vaccination Data Added", preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    alertController.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: NSNotification.Name("VaccinationDataAdded"), object: nil)
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }
}
