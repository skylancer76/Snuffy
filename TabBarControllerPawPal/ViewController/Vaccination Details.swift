//
//  Vaccination Details.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 28/01/25.

import UIKit
import FirebaseFirestore

class Vaccination_Details: UIViewController {
    
    var petId: String?
    @IBOutlet weak var vaccinationTableView: UITableView!
    
    var vaccinationDetails: [VaccinationDetails] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print to verify petId
        print("Pet ID in Vaccination Details: \(petId ?? "No Pet ID")")
        
        vaccinationTableView.dataSource = self
        vaccinationTableView.delegate = self
        
        if let petId = petId {
            fetchVaccinationData(petId: petId)
        }
    }

    // Fetch vaccination data from Firebase for the specific petId
    func fetchVaccinationData(petId: String) {
        let db = Firestore.firestore()
        
        db.collection("Pets").document(petId).collection("Vaccinations").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching vaccination data: \(error.localizedDescription)")
                return
            }
            
            self.vaccinationDetails.removeAll()
            
            // Map the fetched documents to VaccinationDetails
            for document in snapshot?.documents ?? [] {
                let vaccinationData = document.data()
                
                // Extract the vaccination data manually
                let vaccineName = vaccinationData["vaccineName"] as? String ?? ""
                let vaccineType = vaccinationData["vaccineType"] as? String ?? ""
                let dateOfVaccination = vaccinationData["dateOfVaccination"] as? String ?? ""
                let expiryDate = vaccinationData["expiryDate"] as? String ?? ""
                let nextDueDate = vaccinationData["nextDueDate"] as? String ?? ""
                
                // Create a VaccinationDetails object from the data
                let vaccination = VaccinationDetails(
                    vaccineName: vaccineName,
                    vaccineType: vaccineType,
                    dateOfVaccination: dateOfVaccination,
                    expiryDate: expiryDate,
                    nextDueDate: nextDueDate
                )
                
                self.vaccinationDetails.append(vaccination)
            }
            
            // Reload the table view
            self.vaccinationTableView.reloadData()
        }
    }

    // Add Vaccination Button Action
    @IBAction func addVaccination(_ sender: UIBarButtonItem) {
        if let petId = petId {
            // Instantiate the AddVaccination view controller using Storyboard ID
            if let addVaccinationVC = storyboard?.instantiateViewController(withIdentifier: "AddVaccinationVC") as? Add_Vaccination {
                // Pass petId to AddVaccination view controller
                addVaccinationVC.petId = petId
                // Navigate to the AddVaccination screen
                navigationController?.pushViewController(addVaccinationVC, animated: true)
            }
        }
    }
}

extension Vaccination_Details: UITableViewDataSource, UITableViewDelegate {
    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vaccinationDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VaccinationTableViewCell", for: indexPath) as! VaccinationTableViewCell
        
        let vaccination = vaccinationDetails[indexPath.row]
        
        // Populate cell labels with actual vaccination data
        cell.vaccineNameLabel.text = vaccination.vaccineName
        cell.vaccineTypeLabel.text = vaccination.vaccineType
        cell.dateOfVaccineLabel.text = vaccination.dateOfVaccination
        cell.expiaryDateLabel.text = vaccination.expiryDate
        cell.nextDueDateLabel.text = vaccination.nextDueDate
        
        return cell
    }
    
    // Set the height of each cell to 230 points
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    
    // TableView Delegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle vaccination detail selection if needed
    }
}
