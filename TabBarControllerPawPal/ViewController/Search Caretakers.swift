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
        
        let caretakers = [
                Caretakers(name: "Katie", price: "Price : Rs 350 / Day", address: "2.7 km, Chennai", profileImageName: "Profile Image 1"),
                Caretakers(name: "Ananya", price: "Price : Rs 250 / Day", address: "3 km, Chennai", profileImageName: "Ananya"),
                Caretakers(name: "Karan", price: "Price : Rs 300 / Day", address: "3.2 km, Chennai", profileImageName: "Karan"),
                Caretakers(name: "Pooja", price: "Price : Rs 350 / Day", address: "2.7 km, Chennai", profileImageName: "Pooja"),
                Caretakers(name: "Aman", price: "Price : Rs 250 / Day", address: "4 km, Chennai", profileImageName: "Aman"),
                Caretakers(name: "Shraddha", price: "Price : Rs 400 / Day", address: "5 km, Chennai", profileImageName: "Shraddha"),
                Caretakers(name: "Nidhi", price: "Price : Rs 400 / Day", address: "4.5 km, Chennai", profileImageName: "Profile Image 1")
            ]

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
        
        let cell = myTable.dequeueReusableCell(withIdentifier: "caretakercell", for: indexPath) as! Search_Caretaker
        
        let caretaker = caretakerList[indexPath.row]
        
        cell.nameLabel.text = caretaker.name
        cell.AddressLabel.text = caretaker.address
        cell.PriceLabel.text = caretaker.price
        cell.caretakerImage.image = UIImage(named: caretaker.profileImageName)
        
        return cell
    }
    
    // UITableViewDelegate method (optional)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCaretaker = caretakerList[indexPath.row]
        print("Selected caretaker: \(selectedCaretaker.name)")
        tableView.deselectRow(at: indexPath, animated: true)
    }

}


