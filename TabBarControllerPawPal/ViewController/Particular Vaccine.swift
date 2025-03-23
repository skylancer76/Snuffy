//
//  Particular Vaccine.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 23/03/25.
//

import UIKit
import FirebaseFirestore

class Particular_Vaccine: UITableViewController {
    
    var petId: String?
    var vaccination: VaccinationDetails?
    
    @IBOutlet weak var vaccineNameLabel: UILabel!
    @IBOutlet weak var dateOfVaccineLabel: UILabel!
    
    @IBOutlet weak var expiresLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var notifySwitch: UISwitch!
    
    @IBOutlet weak var notes: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        fillVaccineDetails()
    }
    
    private func fillVaccineDetails() {
        // Make sure we have a vaccination object
        guard let vaccination = vaccination else { return }
        
        // Populate UI
        vaccineNameLabel.text = vaccination.vaccineName
        dateOfVaccineLabel.text = vaccination.dateOfVaccination
        
        // "Expires" label
        expiresLabel.text = vaccination.expires ? "Yes" : "No"
        
        // "Expiry Date" label
        if let expDate = vaccination.expiryDate, !expDate.isEmpty {
            expiryDateLabel.text = expDate
        } else {
            expiryDateLabel.text = "N/A"
        }
        
        // Notify switch
        notifySwitch.isOn = vaccination.notifyUponExpiry
        
        // Notes
        if let notesText = vaccination.notes, !notesText.isEmpty {
            notes.text = notesText
        } else {
            notes.text = "No notes"
        }
    }
    
    // MARK: - Delete Vaccine
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        guard
            let petId = petId,
            let vaccineId = vaccination?.vaccineId
        else {
            print("Missing petId or vaccineId.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("Pets")
            .document(petId)
            .collection("Vaccinations")
            .document(vaccineId)
            .delete { error in
                if let error = error {
                    print("Error deleting vaccine: \(error.localizedDescription)")
                } else {
                    print("Vaccine deleted successfully.")
                    
                    // Optionally show a quick confirmation alert
                    let alert = UIAlertController(title: nil, message: "Vaccine Deleted", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    
                    // Dismiss after 1 second
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        alert.dismiss(animated: true) {
                            // If this VC was presented modally, call dismiss:
                            self.dismiss(animated: true)
                            // If it was pushed on a navigation stack, use:
//                             self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
    }
}

// MARK: - Hide Expiry Date row if not set
extension Particular_Vaccine {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Example layout:
        // Section 0: row 0 => Vaccine Name
        //            row 1 => Date of Vaccine
        // Section 1: row 0 => Expires label
        //            row 1 => Expiry Date label (hide if not set)
        //            row 2 => Notify upon expiry
        // Section 2: row 0 => Notes

        if indexPath.section == 1 && indexPath.row == 1 {
            // If there's no expiry date or 'expires' is false, hide row
            if let vaccination = vaccination, vaccination.expires,
               let expDate = vaccination.expiryDate, !expDate.isEmpty {
                return UITableView.automaticDimension
            } else {
                return 0
            }
        }
        
        return UITableView.automaticDimension
    }
}
