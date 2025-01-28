//
//  Add Vaccination.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 28/01/25.
//

//import UIKit
//
//class Add_Vaccination: UITableViewController {
//    weak var delegate: AddVaccinationDelegate?
//       var petId: String?
//
//    
//    func saveVaccination() {
//           guard let petId = petId else { return }
//           
//           let db = Firestore.firestore()
//           let vaccination = [
//               "vaccineId": UUID().uuidString,
//               "vaccineName": "Example Vaccine",
//               "vaccineType": "Core",
//               "dateOfVaccination": "2025-01-29",
//               "expiryDate": "2026-01-29",
//               "nextDueDate": "2025-07-29",
//               "notes": "Next dose required in 6 months"
//           ]
//           
//           let petRef = db.collection("pets").document(petId)
//           
//           petRef.updateData([
//               "vaccinations": FieldValue.arrayUnion([vaccination])
//           ]) { error in
//               if let error = error {
//                   print("Error adding vaccination: \(error.localizedDescription)")
//               } else {
//                   print("Vaccination added successfully!")
//                   self.delegate?.didAddVaccination()
//                   self.dismiss(animated: true, completion: nil)
//               }
//           }
//       }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//    }
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
//
//    /*
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
//
//        // Configure the cell...
//
//        return cell
//    }
//    */
//
//    /*
//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
//    */
//
//    /*
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }    
//    }
//    */
//
//    /*
//    // Override to support rearranging the table view.
//    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//
//    }
//    */
//
//    /*
//    // Override to support conditional rearranging of the table view.
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        return true
//    }
//    */
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}

protocol AddVaccinationDelegate: AnyObject {
    func didAddVaccination()
}
import UIKit
import FirebaseFirestore

class Add_Vaccination: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var vaccineNameTextField: UITextField!
    @IBOutlet weak var vaccineTypeTextField: UITextField!
    @IBOutlet weak var dateOfVaccinationPicker: UIDatePicker!
    @IBOutlet weak var expiryDatePicker: UIDatePicker!
    @IBOutlet weak var nextDueDatePicker: UIDatePicker!
//    @IBOutlet weak var notesTextView: UITextView!

    weak var delegate: AddVaccinationDelegate?
    var petId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePickers()
    }

    private func setupDatePickers() {
        // Set pickers to current date by default
        dateOfVaccinationPicker.date = Date()
        expiryDatePicker.date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        nextDueDatePicker.date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    }

    // MARK: - Save Vaccination
    @IBAction func saveVaccinationTapped(_ sender: UIBarButtonItem ) {
        guard let petId = petId else {
            print("Error: petId is nil")
            return
        }
        
        let db = Firestore.firestore()
        
        // Convert dates to String format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let vaccination = [
            "vaccineId": UUID().uuidString,
            "vaccineName": vaccineNameTextField.text ?? "Unknown",
            "vaccineType": vaccineTypeTextField.text ?? "Unknown",
            "dateOfVaccination": dateFormatter.string(from: dateOfVaccinationPicker.date),
            "expiryDate": dateFormatter.string(from: expiryDatePicker.date),
            "nextDueDate": dateFormatter.string(from: nextDueDatePicker.date),
        ]
        
        let petRef = db.collection("Pets").document(petId)
        
        print("Saving vaccination: \(vaccination) for petId: \(petId)")

        petRef.updateData([
            "vaccinations": FieldValue.arrayUnion([vaccination])
        ]) { error in
            if let error = error {
                print("Error adding vaccination: \(error.localizedDescription)")
            } else {
                print("✅ Vaccination added successfully!")
                self.delegate?.didAddVaccination()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    
}
