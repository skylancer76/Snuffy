//
//  Vaccination Details.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 28/01/25.
//

//import UIKit
//import FirebaseFirestore
//
//class Vaccination_Details: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    
//    @IBOutlet weak var tableView: UITableView!
//    
//    var petId: String?
//    var vaccinations: [VaccinationDetails] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.delegate = self
//        tableView.dataSource = self
//        fetchVaccinations()
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return vaccinations.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VaccinationCell", for: indexPath) as? VaccinationTableViewCell else {
//            return UITableViewCell()
//        }
//
//        let vaccination = vaccinations[indexPath.row]
//        cell.vaccineNameLabel.text = vaccination.vaccineName
//        cell.vaccineTypeLabel.text = vaccination.vaccineType
//        cell.dateOfVaccineLabel.text = vaccination.dateOfVaccination
//        cell.expiaryDateLabel.text = vaccination.expiryDate
//        cell.nextDueDateLabel.text = vaccination.nextDueDate
//
//        return cell
//    }
//    
//    // Fetch vaccinations from the nested vaccinations field in Firestore
//    func fetchVaccinations() {
//        guard let petId = petId else { return }
//        let db = Firestore.firestore()
//        
//        db.collection("Pets").document(petId).getDocument { (document, error) in
//            if let error = error {
//                print("Error fetching pet vaccinations: \(error.localizedDescription)")
//                return
//            }
//            
//            if let document = document, document.exists {
//                if let vaccinationData = document.data()?["vaccinations"] as? [[String: Any]] {
//                    self.vaccinations = vaccinationData.compactMap { data in
//                        return VaccinationDetails(
//                            vaccineId: data["vaccineId"] as? String ?? UUID().uuidString,
//                            vaccineName: data["vaccineName"] as? String ?? "",
//                            vaccineType: data["vaccineType"] as? String ?? "",
//                            dateOfVaccination: data["dateOfVaccination"] as? String ?? "",
//                            expiryDate: data["expiryDate"] as? String ?? "",
//                            nextDueDate: data["nextDueDate"] as? String ?? "",
//                            notes: data["notes"] as? String ?? ""
//                        )
//                    }
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                }
//            }
//        }
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToAddVaccination",
//           let destinationVC = segue.destination as? Add_Vaccination {
//            destinationVC.petId = self.petId 
//        }
//    }
//
//
//}
//
//// Delegate method to refresh vaccinations when new data is added
//extension Vaccination_Details: AddVaccinationDelegate {
//    func didAddVaccination() {
//        fetchVaccinations()
//    }
//}


import UIKit
import FirebaseFirestore

class Vaccination_Details: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var petId: String?
    var vaccinations: [VaccinationDetails] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        print("Vaccination_Details Loaded - petId:", petId ?? "nil") // Debugging
        
        fetchVaccinations()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vaccinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VaccinationCell", for: indexPath) as? VaccinationTableViewCell else {
            return UITableViewCell()
        }

        let vaccination = vaccinations[indexPath.row]
        cell.vaccineNameLabel.text = vaccination.vaccineName
        cell.vaccineTypeLabel.text = vaccination.vaccineType
        cell.dateOfVaccineLabel.text = vaccination.dateOfVaccination
        cell.expiaryDateLabel.text = vaccination.expiryDate
        cell.nextDueDateLabel.text = vaccination.nextDueDate

        return cell
    }
    
    // Fetch vaccinations from the nested vaccinations field in Firestore
    func fetchVaccinations() {
        guard let petId = petId else {
            print(" Error: petId is nil while fetching vaccinations")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("Pets").document(petId).getDocument { (document, error) in
            if let error = error {
                print(" Error fetching pet vaccinations: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                print(" Document found for petId:", petId)
                
                if let vaccinationData = document.data()?["vaccinations"] as? [[String: Any]] {
                    self.vaccinations = vaccinationData.compactMap { data in
                        return VaccinationDetails(
                            vaccineId: data["vaccineId"] as? String ?? UUID().uuidString,
                            vaccineName: data["vaccineName"] as? String ?? "",
                            vaccineType: data["vaccineType"] as? String ?? "",
                            dateOfVaccination: data["dateOfVaccination"] as? String ?? "",
                            expiryDate: data["expiryDate"] as? String ?? "",
                            nextDueDate: data["nextDueDate"] as? String ?? "",
                            notes: data["notes"] as? String ?? ""
                        )
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        print("Vaccination data loaded successfully.")
                    }
                } else {
                    print(" No vaccinations found for this pet.")
                }
            } else {
                print(" No document found for petId:", petId)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddVaccination",
           let destinationVC = segue.destination as? Add_Vaccination {
            destinationVC.petId = self.petId
            destinationVC.delegate = self
            print(" Passing petId to Add_Vaccination:", petId ?? "nil") // Debugging
        }
    }
}

// Delegate method to refresh vaccinations when new data is added
extension Vaccination_Details: AddVaccinationDelegate {
    func didAddVaccination() {
        print(" Reloading vaccinations after addition")
        fetchVaccinations()
    }
}
