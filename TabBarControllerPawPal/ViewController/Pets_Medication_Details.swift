//
//  Pets_Medication_Details.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 24/03/25.
//

import UIKit

class Pets_Medication_Details: UITableViewController {
    
    var petId: String?
    var selectedMedication: PetMedicationDetails?
    
    @IBOutlet weak var medicineNameLabel: UILabel!
    @IBOutlet weak var medicineTypeLabel: UILabel!
    @IBOutlet weak var purposeConditionLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var dosageLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if let medication = selectedMedication {
            medicineNameLabel.text = medication.medicineName
            medicineTypeLabel.text = medication.medicineType
            purposeConditionLabel.text = medication.purpose
            frequencyLabel.text = medication.frequency
            dosageLabel.text = medication.dosage
            startDateLabel.text = medication.startDate
            endDateLabel.text = medication.endDate
        }
    }


    @IBAction func deleteDietTapped(_ sender: UIBarButtonItem) {
         guard let petId = petId,
               let medicationId = selectedMedication?.medicationId else {
             return
         }
         
         // Delete from Firestore (adapt the function name to your FirebaseManager as needed)
         FirebaseManager.shared.deletePetMedicationData(petId: petId, medicationId: medicationId) { error in
             if let error = error {
                 print("Error deleting medication: \(error.localizedDescription)")
             } else {
                 print("Medication deleted successfully")
                 
                 // Optionally post a notification so the list screen can refresh
                 NotificationCenter.default.post(name: NSNotification.Name("PetMedicationDataChanged"), object: nil)
                 
                 // Pop back to the previous screen
                 DispatchQueue.main.async {
                     self.navigationController?.popViewController(animated: true)
                 }
             }
         }
     }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
