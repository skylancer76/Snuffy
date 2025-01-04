//
//  ViewController.swift
//  PawPal_PetDetails
//
//  Created by admin19 on 18/11/24.
//

//import UIKit
//class vaccinationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//    
//    
//    @IBOutlet weak var tableView: UITableView!
//            
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.dataSource = self
//        tableView.delegate = self
//        
////        vaccinations.append(
////            Vaccination(vaccineName: "a", vaccineType: "a", dateOfVaccination: "a", expiryDate: "a", nextDueDate: "a")
////        )
//    }
//    
//    
//    @IBAction func backButtonTapped(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//        
//    // MARK: - UITableViewDataSource Methods
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return vaccinations.count
//    }
//        
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "VaccinationCell", for: indexPath)
//        let vaccination = vaccinations[indexPath.row]
//        if let cell = cell as? VaccinationTableViewCell{
//            cell.vaccineNameLabel.text = vaccination.vaccineName
//            cell.vaccineTypeLabel.text = vaccination.vaccineType
//            cell.dateOfVaccineLabel.text = vaccination.nextDueDate
//            cell.expiaryDateLabel.text = vaccination.expiryDate
//            cell.nextDueDateLabel.text = vaccination.nextDueDate
//        }
//
//        return cell
//    }
//        
//    // MARK: - Deleting Vaccination
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            vaccinations.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }
//    @IBAction func comHere(segue:UIStoryboardSegue){
//        tableView.reloadData()
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        350
//    }
//}
//
//
//extension vaccinationViewController: AddVaccinationDelegate {
//    func didSaveVaccination(_ vaccination: Vaccination) {
//        vaccinations.append(vaccination)
//        tableView.reloadData()
//    }
//}
