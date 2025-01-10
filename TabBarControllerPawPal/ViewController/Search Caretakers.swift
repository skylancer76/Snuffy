//
//  Search Caretakers.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 16/12/24.
//

import UIKit

class Search_Caretakers: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var allButton: UIButton!
    
    @IBOutlet weak var closestButton: UIButton!
    
    @IBOutlet weak var topRatedButton: UIButton!
    
    @IBOutlet weak var lowestPriceButton: UIButton!
    
    
    @IBOutlet weak var myTable: UITableView!
    
    var caretakerList = [Caretakers]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        myTable.dataSource = self
        myTable.delegate = self
        myTable.allowsSelection = true
        
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
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    

//    @IBAction func backButtonTapped(_ sender: Any) {
//        self.tabBarController?.selectedIndex = 0
//    }
//    
    
    
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
        cell.ratingLabel.text = caretaker.rating
        cell.caretakerImage.image = UIImage(named: caretaker.profileImageName)
        cell.cellView.layer.cornerRadius = 12
        cell.cellView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.cellView.layer.shadowOpacity = 0.06
        cell.cellView.layer.shadowRadius = 2
            
        return cell
    }
        
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell at row \(indexPath.row) tapped")
        let selectedCaretaker = caretakerList[indexPath.row]
            
        // Instantiate the destination view controller
        if let profileVC = storyboard?.instantiateViewController(withIdentifier: "CaretakerProfileVC") as? Caretaker_Profile {
            profileVC.caretakerNameForProfile = selectedCaretaker.name
            profileVC.navigationItem.hidesBackButton = true
                
            // Push the view controller to the navigation stack
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}
