//
//  Vaccination Details.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 28/01/25.



//import UIKit
//import FirebaseFirestore
//
//class Vaccination_Details: UIViewController {
//    
//    var petId: String?
//    @IBOutlet weak var vaccinationTableView: UITableView!
//    
//    // The array of vaccination records fetched from Firestore.
//    // Each record now includes a 'vaccineId' (the document ID).
//    var vaccinationDetails: [VaccinationDetails] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        
//        
//        print("Pet ID in Vaccination Details: \(petId ?? "No Pet ID")")
//        
//        vaccinationTableView.dataSource = self
//        vaccinationTableView.delegate = self
//        
//        if let petId = petId {
//            fetchVaccinationData(petId: petId)
//        }
//        
//        
//        // Set Gradient View
//        let gradientView = UIView(frame: view.bounds)
//        gradientView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(gradientView)
//        view.sendSubviewToBack(gradientView)
//        // Set Gradient inside the view
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = view.bounds                           // Match the frame of the view
//        gradientLayer.colors = [
//            UIColor.systemPink.withAlphaComponent(0.3).cgColor,     // Start color
//            UIColor.clear.cgColor                                   // End color
//        ]
//        gradientLayer.locations = [0.0, 1.0]                        // Gradually fade
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)          // Top-center
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)            // Bottom-center
//        // Apply the gradient to the gradientView
//        gradientView.layer.insertSublayer(gradientLayer, at: 0)
//        
//        // Clear the background colour of the table view
//        vaccinationTableView.backgroundColor = .clear
//        
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if let petId = petId {
//            fetchVaccinationData(petId: petId)
//        }
//    }
//    
//    // Fetch vaccination data from Firestore for the given petId.
//    func fetchVaccinationData(petId: String) {
//        let db = Firestore.firestore()
//        
//        db.collection("Pets").document(petId).collection("Vaccinations").getDocuments { snapshot, error in
//            if let error = error {
//                print("Error fetching vaccination data: \(error.localizedDescription)")
//                return
//            }
//            
//            self.vaccinationDetails.removeAll()
//            
//            // Iterate through the returned documents.
//            for document in snapshot?.documents ?? [] {
//                let vaccinationData = document.data()
//                
//                let vaccineName = vaccinationData["vaccineName"] as? String ?? ""
//                let vaccineType = vaccinationData["vaccineType"] as? String ?? ""
//                let dateOfVaccination = vaccinationData["dateOfVaccination"] as? String ?? ""
//                let expiryDate = vaccinationData["expiryDate"] as? String ?? ""
//                let nextDueDate = vaccinationData["nextDueDate"] as? String ?? ""
//                
//                // Initialize VaccinationDetails using the Firestore document ID.
//                let vaccination = VaccinationDetails(
//                    vaccineId: document.documentID,
//                    vaccineName: vaccineName,
//                    vaccineType: vaccineType,
//                    dateOfVaccination: dateOfVaccination,
//                    expiryDate: expiryDate,
//                    nextDueDate: nextDueDate
//                )
//                
//                self.vaccinationDetails.append(vaccination)
//            }
//            
//            DispatchQueue.main.async {
//                self.vaccinationTableView.reloadData()
//            }
//        }
//    }
//
//    // Action to push the Add Vaccination screen.
//    @IBAction func addVaccination(_ sender: UIBarButtonItem) {
//        if let petId = petId {
//            if let addVaccinationVC = storyboard?.instantiateViewController(withIdentifier: "AddVaccinationVC") as? Add_Vaccination {
//                addVaccinationVC.petId = petId
//                navigationController?.pushViewController(addVaccinationVC, animated: true)
//            }
//        }
//    }
//    
//    // This function is triggered when a cell's delete button is pressed.
//    @objc func deleteButtonTapped(_ sender: UIButton) {
//        let index = sender.tag
//        let vaccination = vaccinationDetails[index]
//        guard let petId = petId, let vaccineId = vaccination.vaccineId else { return }
//        
//        let db = Firestore.firestore()
//        // Delete the document using the vaccineId.
//        db.collection("Pets").document(petId).collection("Vaccinations").document(vaccineId).delete { error in
//            if let error = error {
//                print("Error deleting document: \(error.localizedDescription)")
//            } else {
//                print("Document successfully deleted")
//                // Update the local array and table view.
//                self.vaccinationDetails.remove(at: index)
//                DispatchQueue.main.async {
//                    self.vaccinationTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - UITableViewDataSource & UITableViewDelegate
//extension Vaccination_Details: UITableViewDataSource, UITableViewDelegate {
//    
//    // Number of rows equals the number of vaccination records.
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return vaccinationDetails.count
//    }
//    
//    // Configure the cell and add the delete button action.
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "VaccinationTableViewCell", for: indexPath) as! VaccinationTableViewCell
//        
//        let vaccination = vaccinationDetails[indexPath.row]
//        
//        cell.vaccineNameLabel.text = vaccination.vaccineName
//        cell.vaccineTypeLabel.text = vaccination.vaccineType
//        cell.dateOfVaccineLabel.text = vaccination.dateOfVaccination
//        cell.expiaryDateLabel.text = vaccination.expiryDate
//        cell.nextDueDateLabel.text = vaccination.nextDueDate
//        
//        // Set the button's tag to the row index to identify which record to delete.
//        cell.deleteButton.tag = indexPath.row
//        cell.deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
//        
//        return cell
//    }
//    
//    // Set the cell height to 230 points.
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 230
//    }
//    
//    // Optionally, handle cell selection.
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // Handle selection if needed.
//    }
//}
import UIKit
import FirebaseFirestore

class Vaccination_Details: UIViewController {
    
    var petId: String?
    @IBOutlet weak var vaccinationTableView: UITableView!
    
    var vaccinationDetails: [VaccinationDetails] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Pet ID in Vaccination Details: \(petId ?? "No Pet ID")")
        
        vaccinationTableView.dataSource = self
        vaccinationTableView.delegate = self
        
        // Fetch data if we have a pet ID
        if let petId = petId {
            fetchVaccinationData(petId: petId)
        }
        
        // Set up gradient background
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Make table view background clear
        vaccinationTableView.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data each time this view appears
        if let petId = petId {
            fetchVaccinationData(petId: petId)
        }
    }
    
    func fetchVaccinationData(petId: String) {
        let db = Firestore.firestore()
        
        db.collection("Pets")
          .document(petId)
          .collection("Vaccinations")
          .getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching vaccination data: \(error.localizedDescription)")
                return
            }
            
            self.vaccinationDetails.removeAll()
            
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                
                let vaccineName = data["vaccineName"] as? String ?? ""
                let dateOfVaccination = data["dateOfVaccination"] as? String ?? ""
                let expires = data["expires"] as? Bool ?? false
                let expiryDate = data["expiryDate"] as? String
                let notifyUponExpiry = data["notifyUponExpiry"] as? Bool ?? false
                let notes = data["notes"] as? String
                
                // Construct the local model
                let vaccination = VaccinationDetails(
                    vaccineId: document.documentID,
                    vaccineName: vaccineName,
                    dateOfVaccination: dateOfVaccination,
                    expires: expires,
                    expiryDate: expiryDate,
                    notifyUponExpiry: notifyUponExpiry,
                    notes: notes
                )
                
                self.vaccinationDetails.append(vaccination)
            }
            
            DispatchQueue.main.async {
                self.vaccinationTableView.reloadData()
            }
        }
    }

    // Present Add Vaccination as a page sheet
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddVaccinationDetails" {
            // If your destination is embedded in a navigation controller,
            // grab the top view controller.
            if let navController = segue.destination as? UINavigationController,
               let addVaccinationVC = navController.topViewController as? Add_Vaccination {
                addVaccinationVC.petId = petId
                // Optionally set the modal presentation style in code:
                addVaccinationVC.modalPresentationStyle = .pageSheet
            } else if let addVaccinationVC = segue.destination as? Add_Vaccination {
                addVaccinationVC.petId = petId
                addVaccinationVC.modalPresentationStyle = .pageSheet
            }
        }
    }

    
    // Deletion logic
    @objc func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let vaccination = vaccinationDetails[index]
        guard let petId = petId, let vaccineId = vaccination.vaccineId else { return }
        
        let db = Firestore.firestore()
        db.collection("Pets")
          .document(petId)
          .collection("Vaccinations")
          .document(vaccineId)
          .delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                print("Document successfully deleted")
                self.vaccinationDetails.remove(at: index)
                DispatchQueue.main.async {
                    self.vaccinationTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension Vaccination_Details: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vaccinationDetails.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "VaccinationTableViewCell",
            for: indexPath
        ) as! VaccinationsDetailsTableViewCell
        
        let vaccination = vaccinationDetails[indexPath.row]
        
        // Show only vaccine name & date on the cell
        cell.vaccineNameLabel.text = vaccination.vaccineName
        cell.dateLabel.text = "Given on \(vaccination.dateOfVaccination)"
        
     

        
        // Make the cell’s background clear to show the gradient behind
        cell.backgroundColor = .clear
        
        return cell
    }
    
    // Example fixed cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedVaccination = vaccinationDetails[indexPath.row]
        
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "Particular_Vaccine") as? Particular_Vaccine {
            detailVC.petId = petId
            detailVC.vaccination = selectedVaccination
            
            // If you want to push it:
            navigationController?.pushViewController(detailVC, animated: true)
            
            // Or present modally:
            // detailVC.modalPresentationStyle = .pageSheet
            // present(detailVC, animated: true)
        }
    }

}
