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
        guard let vaccination = vaccination else { return }
        
        // Populate UI
        vaccineNameLabel.text = vaccination.vaccineName
        dateOfVaccineLabel.text = vaccination.dateOfVaccination
        
        expiresLabel.text = vaccination.expires ? "Yes" : "No"
        
        // If expiry date is present
        if let expDate = vaccination.expiryDate, !expDate.isEmpty {
            expiryDateLabel.text = expDate
        } else {
            expiryDateLabel.text = "N/A"
        }
        
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
        guard let petId = petId,
              let vaccineId = vaccination?.vaccineId else {
            print("Missing petId or vaccineId.")
            return
        }
        
        FirebaseManager.shared.deleteVaccinationData(petId: petId, vaccineId: vaccineId) { error in
            if let error = error {
                print("Error deleting vaccine: \(error.localizedDescription)")
            } else {
                print("Vaccine deleted successfully")
                
                NotificationCenter.default.post(name: NSNotification.Name("VaccinationDataAdded"), object: nil)
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Hide Rows
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {



        if indexPath.section == 1 {
            if let v = vaccination,
               v.expires,
               let expDate = v.expiryDate,
               !expDate.isEmpty {
                // Expiry is set => show normal
                return UITableView.automaticDimension
            } else {
                // No expiry => hide
                return 0
            }
        }
        
        // Hide Section 2 row (notes) if empty
        if indexPath.section == 2 {
            if let v = vaccination,
               let notesText = v.notes,
               !notesText.isEmpty {
                return UITableView.automaticDimension
            } else {
                return 0
            }
        }
        
        return UITableView.automaticDimension
    }
    
    // MARK: - Hide Section Headers
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 1 {
            if let v = vaccination,
               v.expires,
               let expDate = v.expiryDate,
               !expDate.isEmpty {
                return "Expiry Info"
            } else {
                return nil
            }
        }
        
       
        if section == 2 {
            if let v = vaccination,
               let notesText = v.notes,
               !notesText.isEmpty {
                return "Notes"
            } else {
                return nil
            }
        }
        
        return nil
    }

}
