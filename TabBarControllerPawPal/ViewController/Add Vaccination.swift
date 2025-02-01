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
        
        // Debug print to check if petId is being passed
        print("Pet ID: \(petId ?? "No Pet ID passed")")
        
        // Set the initial date pickers to the current date if needed
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
        
        // Get the dates from the date pickers and format them to strings
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let dateOfVaccination = dateFormatter.string(from: dateOfVaccinePicker.date)
        let expiryDate = dateFormatter.string(from: expiryDatePicker.date)
        let nextDueDate = dateFormatter.string(from: nextDueDatePicker.date)
        
        // Creating a VaccinationDetails object with the form input data
        let vaccination = VaccinationDetails(
            vaccineName: vaccineNameTextField.text ?? "",
            vaccineType: vaccineTypeTextField.text ?? "",
            dateOfVaccination: dateOfVaccination,
            expiryDate: expiryDate,
            nextDueDate: nextDueDate
        )
        
        // Save vaccination data using FirebaseManager
        FirebaseManager.shared.saveVaccinationData(petId: petId, vaccination: vaccination) { error in
            if let error = error {
                print("Failed to save vaccination: \(error.localizedDescription)")
            } else {
                print("Vaccination saved successfully!")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
