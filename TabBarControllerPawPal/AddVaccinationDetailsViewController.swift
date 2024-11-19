//
//  AddVaccinationViewController.swift
//  PawPal_PetDetails
//
//  Created by admin19 on 18/11/24.
//

import UIKit

protocol AddVaccinationDelegate: AnyObject {
    func didSaveVaccination(_ vaccination: Vaccination)
}

class AddVaccinationDetailsViewController: UIViewController {
    
    @IBOutlet weak var vaccineNameTextField: UITextField!
    @IBOutlet weak var vaccineTypeTextField: UITextField!
    @IBOutlet weak var dateOfVaccinationTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var nextDueDateTextField: UITextField!
        
    weak var delegate: AddVaccinationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func saveButtonTapped(_ sender: Any) {
        
            guard
                let vaccineName = vaccineNameTextField.text, !vaccineName.isEmpty,
                let vaccineType = vaccineTypeTextField.text, !vaccineType.isEmpty,
                let dateOfVaccination = dateOfVaccinationTextField.text, !dateOfVaccination.isEmpty,
                let expiryDate = expiryDateTextField.text, !expiryDate.isEmpty,
                let nextDueDate = nextDueDateTextField.text, !nextDueDate.isEmpty
            else {
                // Show an error message if any field is empty
                print("empty")
                let alert = UIAlertController(title: "Error", message: "Please fill in all fields.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            
            // Create a new Vaccination object
            let vaccinationItem = Vaccination(
                vaccineName: vaccineName,
                vaccineType: vaccineType,
                dateOfVaccination: dateOfVaccination,
                expiryDate: expiryDate,
                nextDueDate: nextDueDate
            )
            vaccinations.append(vaccinationItem)
            // Pass data back to the list view controller
            
            // Navigate back to the previous screen
        performSegue(withIdentifier: "toHome", sender: nil)
    }
}
