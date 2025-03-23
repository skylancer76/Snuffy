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
