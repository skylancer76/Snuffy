//
//  Pet Vaccination Details.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 13/03/25.
//

//import UIKit
//import Firebase
//import FirebaseFirestore
//
//class Pet_Vaccination_Details: UIViewController, UITableViewDataSource, UITableViewDelegate  {
//    var petId: String?
//    @IBOutlet weak var vaccinationTableView: UITableView!
//    var vaccinationDetails: [VaccinationDetails] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        vaccinationTableView.dataSource = self
//               vaccinationTableView.delegate = self
//               
//               // Fetch vaccination data if we have a valid petId
//               if let petId = petId {
//                   fetchVaccinationData(petId: petId)
//               }
//               
//               // Gradient background setup (optional)
//               let gradientView = UIView(frame: view.bounds)
//               gradientView.translatesAutoresizingMaskIntoConstraints = false
//               view.addSubview(gradientView)
//               view.sendSubviewToBack(gradientView)
//               
//               let gradientLayer = CAGradientLayer()
//               gradientLayer.frame = view.bounds
//               gradientLayer.colors = [
//                   UIColor.systemPink.withAlphaComponent(0.3).cgColor,
//                   UIColor.clear.cgColor
//               ]
//               gradientLayer.locations = [0.0, 1.0]
//               gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
//               gradientLayer.endPoint   = CGPoint(x: 0.5, y: 0.5)
//               gradientView.layer.insertSublayer(gradientLayer, at: 0)
//               
//               // Make the table view background transparent to see the gradient
//               vaccinationTableView.backgroundColor = .clear
//    }
//    func fetchVaccinationData(petId: String) {
//            let db = Firestore.firestore()
//            
//            db.collection("Pets")
//                .document(petId)
//                .collection("Vaccinations")
//                .getDocuments { snapshot, error in
//                    if let error = error {
//                        print("Error fetching vaccination data: \(error.localizedDescription)")
//                        return
//                    }
//                    
//                    self.vaccinationDetails.removeAll()
//                    
//                    // Parse each document
//                    for document in snapshot?.documents ?? [] {
//                        let vaccinationData = document.data()
//                        
//                        let vaccineName = vaccinationData["vaccineName"] as? String ?? ""
//                        let vaccineType = vaccinationData["vaccineType"] as? String ?? ""
//                        let dateOfVaccination = vaccinationData["dateOfVaccination"] as? String ?? ""
//                        let expiryDate = vaccinationData["expiryDate"] as? String ?? ""
//                        let nextDueDate = vaccinationData["nextDueDate"] as? String ?? ""
//                        
//                        // Initialize the local VaccinationDetails struct
//                        let vaccination = VaccinationDetails(
//                            vaccineId: document.documentID,
//                            vaccineName: vaccineName,
//                            vaccineType: vaccineType,
//                            dateOfVaccination: dateOfVaccination,
//                            expiryDate: expiryDate,
//                            nextDueDate: nextDueDate
//                        )
//                        
//                        self.vaccinationDetails.append(vaccination)
//                    }
//                    
//                    // Reload the table view on the main thread
//                    DispatchQueue.main.async {
//                        self.vaccinationTableView.reloadData()
//                    }
//                }
//        }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return vaccinationDetails.count
//    }
//    
//    // Configure each cell
//    func tableView(_ tableView: UITableView,
//                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: "VaccinationTableViewCell",
//            for: indexPath
//        ) as? VaccinationTableViewCell else {
//            return UITableViewCell()
//        }
//        
//        let vaccination = vaccinationDetails[indexPath.row]
//        
//        // Populate labels
//        cell.vaccineNameLabel.text = vaccination.vaccineName
//        cell.vaccineTypeLabel.text = vaccination.vaccineType
//        cell.dateOfVaccineLabel.text = vaccination.dateOfVaccination
//        cell.expiaryDateLabel.text = vaccination.expiryDate
//        cell.nextDueDateLabel.text = vaccination.nextDueDate
//        
//        // Hide the delete button (caretaker cannot delete)
//        cell.deleteButton.isHidden = true
//        
//        return cell
//    }
//    
//    // Set the cell height as desired
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 230
//    }
//    
//    // Handle cell selection if needed
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // e.g., show more info or do nothing
//    }
//    }
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
