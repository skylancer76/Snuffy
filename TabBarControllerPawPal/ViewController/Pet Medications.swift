//
//  Pet Medications.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 02/02/25.
//

import UIKit
import FirebaseFirestore

class Pet_Medications: UIViewController {
    
    var petId: String?
    @IBOutlet weak var petMedicationTableView: UITableView!
    
    // Array to hold fetched pet medication records.
    var petMedications: [PetMedicationDetails] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Pet ID in Pet Medication: \(petId ?? "No Pet ID")")
        petMedicationTableView.dataSource = self
        petMedicationTableView.delegate = self
        
        if let petId = petId {
            fetchPetMedicationData(petId: petId)
        }
        
        // Set Gradient View
        let gradientView = UIView(frame: view.bounds)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gradientView)
        view.sendSubviewToBack(gradientView)
        // Set Gradient inside the view
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds                           // Match the frame of the view
        gradientLayer.colors = [
            UIColor.systemPink.withAlphaComponent(0.3).cgColor,     // Start color
            UIColor.clear.cgColor                                   // End color
        ]
        gradientLayer.locations = [0.0, 1.0]                        // Gradually fade
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)          // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.5)            // Bottom-center
        // Apply the gradient to the gradientView
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Clear the background colour of the table view
        petMedicationTableView.backgroundColor = .clear
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let petId = petId {
            fetchPetMedicationData(petId: petId)
        }
    }
    
    // Fetch medication data from Firestore.
    func fetchPetMedicationData(petId: String) {
        let db = Firestore.firestore()
        
        db.collection("Pets").document(petId).collection("PetMedication").getDocuments { snapshot, error in
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
    
    // Action to push the Add Pet Medication screen.
    @IBAction func addPetMedication(_ sender: UIBarButtonItem) {
        if let petId = petId,
           let addMedVC = storyboard?.instantiateViewController(withIdentifier: "AddPetMedicationVC") as? Add_Pet_Medications {
            addMedVC.petId = petId
            navigationController?.pushViewController(addMedVC, animated: true)
        }
    }
    
    // Delete action when the delete button is tapped.
    @objc func deleteMedicationButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let medication = petMedications[index]
        guard let petId = petId, let medicationId = medication.medicationId else { return }
        
        FirebaseManager.shared.deletePetMedicationData(petId: petId, medicationId: medicationId) { error in
            if let error = error {
                print("Error deleting medication: \(error.localizedDescription)")
            } else {
                print("Medication deleted successfully")
                self.petMedications.remove(at: index)
                DispatchQueue.main.async {
                    self.petMedicationTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension Pet_Medications: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petMedications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PetMedicationTableViewCell", for: indexPath) as! PetMedicationTableViewCell
        
        let medication = petMedications[indexPath.row]
        cell.medicineNameLabel.text = medication.medicineName
        cell.medicineTypeLabel.text = medication.medicineType
        cell.purposeLabel.text = medication.purpose
        cell.frequencyLabel.text = medication.frequency
        cell.dosageLabel.text = medication.dosage
        cell.startDateLabel.text = medication.startDate
        cell.endDateLabel.text = medication.endDate
        
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteMedicationButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 290
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Optionally handle cell selection.
    }
}
