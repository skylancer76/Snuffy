//
//  Search Caretakers.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 16/12/24.
//

import UIKit

class Search_Caretakers: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myTable: UITableView!
    
    var caretakerList = [Caretakers]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseManager.shared.saveCaretakerData(caretakers: caretakers) { error in
            if let error = error {
                print("Error saving data: \(error.localizedDescription)")
            } else {
                print("Caretakers saved successfully.")
            }
        }
        
        setupTableView()
        fetchCaretakers()

        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func fetchCaretakers() {
        FirebaseManager.shared.fetchCaretakerData { [weak self] caretakers, error in
            if let error = error {
                print("Failed to fetch caretakers: \(error.localizedDescription)")
                return
            }
            
            self?.caretakerList = caretakers ?? []
            DispatchQueue.main.async {
                self?.myTable.reloadData()
            }
        }
    }

    
    private func setupTableView() {
        // Register the custom cell
        myTable.register(UITableViewCell.self, forCellReuseIdentifier: "CaretakerCell")
        
        // Set the data source and delegate
        myTable.dataSource = self
        myTable.delegate = self
        
        // Customize the table view appearance if needed
        myTable.tableFooterView = UIView(frame: .zero) // Removes empty rows
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return caretakerList.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTable.dequeueReusableCell(withIdentifier: "caretakercell", for: indexPath) as! Search_CaretakerCell
        
        let caretaker = caretakerList[indexPath.row]
        
        cell.nameLabel.text = caretaker.name
        cell.AddressLabel.text = caretaker.address
        cell.PriceLabel.text = caretaker.price
        cell.caretakerImage.image = UIImage(named: caretaker.profileImageName)
        cell.cellView.layer.cornerRadius = 15
        cell.cellView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.cellView.layer.shadowOpacity = 0.1
        cell.cellView.layer.shadowRadius = 3
        
        return cell
    }
    
    
    // UITableViewDelegate method (optional)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCaretaker = caretakerList[indexPath.row]
        print("Selected caretaker: \(selectedCaretaker.name)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "showCaretakerProfile", sender: selectedCaretaker)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCaretakerProfile" {
            if let profileVC = segue.destination as? Caretaker_Profile,
               let selectedCaretaker = sender as? Caretakers {
                // Pass data to Caretaker_Profile
                profileVC.caretakerNameForProfile = selectedCaretaker.name
            }
        }
    }
}
