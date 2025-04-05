//
//  Pet_Vaccination_Details.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 05/04/25.
//

import UIKit
import FirebaseFirestore


class Pet_Vaccination_Details: UIViewController {
    
    
    
    var petId: String?
    @IBOutlet weak var vaccinationTableView: UITableView!
    
    var vaccinationDetails: [VaccinationDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Pet ID in Vaccination Details: \(petId ?? "No Pet ID")")
        
        vaccinationTableView.dataSource = self
        vaccinationTableView.delegate = self
        
        
        
        // Initial fetch if petId is available
        if let petId = petId {
            fetchVaccinationData(petId: petId)
        }
        
        // Gradient background
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
        
        vaccinationTableView.backgroundColor = .clear
    }
    
    
    // Refresh each time the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let petId = petId {
            fetchVaccinationData(petId: petId)
        }
    }
    
    
    
    // MARK: - Fetch
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
    
}


extension Pet_Vaccination_Details: UITableViewDataSource, UITableViewDelegate {
    
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
        
        // Show only vaccine name & date
        cell.vaccineNameLabel.text = vaccination.vaccineName
        cell.dateLabel.text = "Given on \(vaccination.dateOfVaccination)"
        cell.backgroundColor = .clear
        
        return cell
    }
    
    // Example fixed cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // Tap -> show detail
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedVaccination = vaccinationDetails[indexPath.row]
        
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "Pet_Particular_Vaccine") as? Pet_Particular_Vaccine {
            detailVC.petId = petId
            detailVC.vaccination = selectedVaccination
            
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
