//
//  Pet Medications.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 02/02/25.
//


import UIKit
import FirebaseFirestore

class Pet_Medications: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var petId: String?
    @IBOutlet weak var petMedicationTableView: UITableView!
    
    // Array to hold fetched pet medication records.
    var petMedications: [PetMedicationDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Pet ID in Pet Medication: \(petId ?? "No Pet ID")")
        
        // Table view setup
        petMedicationTableView.dataSource = self
        petMedicationTableView.delegate = self
        petMedicationTableView.backgroundColor = .clear
        
        // Observe "PetMedicationDataAdded" to refresh instantly
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMedicationDataAdded(_:)),
            name: NSNotification.Name("PetMedicationDataAdded"),
            object: nil
        )
        
        // Fetch data if we have a pet ID
        if let petId = petId {
            fetchPetMedicationData(petId: petId)
        }
        
        // Gradient background
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Optionally fetch again
        if let petId = petId {
            fetchPetMedicationData(petId: petId)
        }
    }
    
    deinit {
        // Remove observer when this screen is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Handle Notification
    @objc func handleMedicationDataAdded(_ notification: Notification) {
        print("PetMedicationDataAdded notification received. Refreshing data...")
        if let petId = petId {
            fetchPetMedicationData(petId: petId)
        }
    }
    
    // MARK: - Fetch medication data from Firestore
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
                
                // Prepare date formatters
                let storedFormatter = DateFormatter()
                // This is how they're *stored* if you used "dd/MM/yyyy" in Add_Pet_Medications
                storedFormatter.dateFormat = "dd/MM/yyyy"
                
                let displayFormatter = DateFormatter()
                // Display them as dd.MM.yy (e.g. 24.03.25)
                // If you prefer dd.MM.yyyy, change below
                displayFormatter.dateFormat = "dd.MM.yy"
                
                for document in snapshot?.documents ?? [] {
                    let data = document.data()
                    
                    let medicineName = data["medicineName"] as? String ?? ""
                    let medicineType = data["medicineType"] as? String ?? ""
                    let purpose = data["purpose"] as? String ?? ""
                    let frequency = data["frequency"] as? String ?? ""
                    let dosage = data["dosage"] as? String ?? ""
                    
                    // Convert stored startDate to dd.MM.yy
                    let rawStartDate = data["startDate"] as? String ?? ""
                    let startDate: String
                    if let dateObj = storedFormatter.date(from: rawStartDate) {
                        startDate = displayFormatter.string(from: dateObj)
                    } else {
                        // If parse fails, use the original string
                        startDate = rawStartDate
                    }
                    
                    // Convert stored endDate to dd.MM.yy
                    let rawEndDate = data["endDate"] as? String ?? ""
                    let endDate: String
                    if let dateObj = storedFormatter.date(from: rawEndDate) {
                        endDate = displayFormatter.string(from: dateObj)
                    } else {
                        endDate = rawEndDate
                    }
                    
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
    
    // MARK: - Navigation (Segue to Add Pet Medication)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddPetMedicationSegue" {
            // If your destination is embedded in a navigation controller:
            if let navController = segue.destination as? UINavigationController,
               let addMedVC = navController.topViewController as? Add_Pet_Medications {
                addMedVC.petId = petId
                addMedVC.modalPresentationStyle = .pageSheet
            }
            // Else if it’s a direct segue to Add_Pet_Medications (no Nav Controller):
            else if let addMedVC = segue.destination as? Add_Pet_Medications {
                addMedVC.petId = petId
                addMedVC.modalPresentationStyle = .pageSheet
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If no medications, show one row for the "No Medication" cell.
        if petMedications.isEmpty {
            return 1
        } else {
            return petMedications.count
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if petMedications.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoPetMedication", for: indexPath) as! No_Medication
            cell.medicineNameLabel.text = "No medication found"
            cell.backgroundColor = .clear
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PetsMedicationTableViewCell",
                for: indexPath
            ) as! PetsMedicationDetailsTableViewCell
            
            let medication = petMedications[indexPath.row]
            
            // 1) Medicine Name
            cell.medicineNameLabel.text = medication.medicineName
            
            // 2) Medicine Type
            cell.medicineTypeLabel.text = medication.medicineType
            
            // 3) Date Range (already formatted as dd.MM.yy in fetch)
            cell.dateRangeLabel.text = "\(medication.startDate) - \(medication.endDate)"
            
            cell.backgroundColor = .clear
            return cell
        }
    }
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 1. Get the selected medication
        let selectedMedication = petMedications[indexPath.row]
        
        // 2. Instantiate your detail view controller
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "Pets_Medication_Details") as? Pets_Medication_Details {
            
            // 3. Pass the petId and selected medication
            detailVC.petId = petId
            detailVC.selectedMedication = selectedMedication
            
            // 4. Push the detail screen
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
