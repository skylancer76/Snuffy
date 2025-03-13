//
//  Pet Medication Details.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 13/03/25.
//

import UIKit
import FirebaseFirestore

class Pet_Medication_Details: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    var petId: String?
    @IBOutlet weak var petMedicationTableView: UITableView!
    
    // Array to hold fetched medication records
    var petMedications: [PetMedicationDetails] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Pet ID in Pet Medication: \(petId ?? "No Pet ID")")
        petMedicationTableView.dataSource = self
        petMedicationTableView.delegate = self
        
        if let petId = petId {
            fetchPetMedicationData(petId: petId)
        }
        
        // Setup gradient background
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Make the table view background transparent
        petMedicationTableView.backgroundColor = .clear
    }
    
    // MARK: - Data Fetching
    func fetchPetMedicationData(petId: String) {
        let db = Firestore.firestore()
        
        db.collection("Pets")
            .document(petId)
            .collection("PetMedication")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching pet medication data: \(error.localizedDescription)")
                    return
                }
                
                self.petMedications.removeAll()
                
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    
                    let medicineName = data["medicineName"] as? String ?? ""
                    let medicineType = data["medicineType"] as? String ?? ""
                    let purpose = data["purpose"] as? String ?? ""
                    let frequency = data["frequency"] as? String ?? ""
                    let dosage = data["dosage"] as? String ?? ""
                    let startDate = data["startDate"] as? String ?? ""
                    let endDate = data["endDate"] as? String ?? ""
                    
                    let medication = PetMedicationDetails(
                        medicationId: document.documentID,
                        medicineName: medicineName,
                        medicineType: medicineType,
                        purpose: purpose,
                        frequency: frequency,
                        dosage: dosage,
                        startDate: startDate,
                        endDate: endDate
                    )
                    
                    self.petMedications.append(medication)
                }
                
                DispatchQueue.main.async {
                    self.petMedicationTableView.reloadData()
                }
            }
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petMedications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PetMedicationTableViewCell", for: indexPath) as? PetMedicationTableViewCell else {
            return UITableViewCell()
        }
        
        let medication = petMedications[indexPath.row]
        cell.medicineNameLabel.text = medication.medicineName
        cell.medicineTypeLabel.text = medication.medicineType
        cell.purposeLabel.text = medication.purpose
        cell.frequencyLabel.text = medication.frequency
        cell.dosageLabel.text = medication.dosage
        cell.startDateLabel.text = medication.startDate
        cell.endDateLabel.text = medication.endDate
        
        // Hide the delete button as caretaker should not delete records
        cell.deleteButton.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 290
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Optionally handle cell selection if needed
    }
}
