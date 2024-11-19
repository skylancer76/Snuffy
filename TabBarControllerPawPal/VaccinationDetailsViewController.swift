//
//  VaccinationDetailsViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 19/11/24.
//

import UIKit

class VaccinationDetailsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vaccinationDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? VaccinationDetailTableViewCell else {
            return UITableViewCell()
        }
        let vaccination = vaccinationDetails[indexPath.row]
        
        // Set the labels with the corresponding data
        cell.vaccinationName.text = vaccination.vacinationName
        cell.vaccinationDate.text = vaccination.vacinationDate
        cell.vaacinationDescription.text = vaccination.vacinationDescription
        
        // Change the color based on vaccination completion
        if vaccination.isVaccinationCompleted {
            cell.vaacinationDescription.textColor = UIColor.red
        } else {
            cell.vaacinationDescription.textColor = UIColor.green
        }
        
        return cell
        
    }

    
    
    @IBOutlet var myTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
