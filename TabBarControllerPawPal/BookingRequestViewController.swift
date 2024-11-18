//
//  BookingRequestViewController.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 18/11/24.
//

import UIKit

class BookingRequestViewController: UIViewController {
    
    
    
    
    @IBOutlet var datePickerView: UIDatePicker!
    
    @IBOutlet var selectPetButton: UIButton!
    @IBOutlet var startTimeButton: UIButton!
    @IBOutlet var endTimeButton: UIButton!
    @IBOutlet var pickUpButton: UIButton!
    @IBOutlet var dropOffButton: UIButton!
    
    
    
    var isSelectingStartDate = true
    var startDate: Date?
    var endDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerView.datePickerMode = .date
        
        let usersItem = UIAction(title: "Pet", image: UIImage(systemName: "dog.fill")) { (action) in
            
            print("Users action was tapped")
        }
        
        let addUserItem = UIAction(title: "Buzzo", image: UIImage(systemName: "dog.fill")) { (action) in
            
            print("Buzzo got selected")
        }
        
        let removeUserItem = UIAction(title: "Haachi", image: UIImage(systemName: "dog.fill")) { (action) in
            print("Haachi got selected")
        }
        
        let menu = UIMenu(title: "My Menu", options: .displayInline, children: [usersItem , addUserItem , removeUserItem])
        
        selectPetButton.menu = menu
        selectPetButton.showsMenuAsPrimaryAction = true
        
        let startTime = UIAction(title: "Time", image: UIImage(systemName: "dog.fill")) { (action) in
            
            print("Users action was tapped")
        }
        
        let Time1 = UIAction(title: "11 Am") { (action) in
            
            print("11 Am time selected")
        }
        
        let Time2 = UIAction(title: "2 PM") { (action) in
            print("2 PM time selected")
        }
        
        let hourMenu = UIMenu(title: "My Menu", options: .displayInline, children: [startTime , Time1 , Time2])
        startTimeButton.menu = hourMenu
        startTimeButton.showsMenuAsPrimaryAction = true
        
        endTimeButton.menu = hourMenu
        endTimeButton.showsMenuAsPrimaryAction = true
        
        
        let PickUp = UIAction(title: "PickUp" ) { (action) in
            
            print("Users action was tapped")
        }
        
        let Yes = UIAction(title: "Yes") { (action) in
            
            print("Pick Up/ drop off required")
        }
        
        let No = UIAction(title: "No") { (action) in
            print("Pick Up / drop off not required")
        }
        
        let PickUpMenu = UIMenu(title: "My Menu", options: .displayInline, children: [PickUp , Yes , No])
        
        pickUpButton.menu = PickUpMenu
        pickUpButton.showsMenuAsPrimaryAction = true
        
        dropOffButton.menu = PickUpMenu
        dropOffButton.showsMenuAsPrimaryAction = true
        
    }
    
    
    @IBAction func dateSelected(_ sender: UIDatePicker) {
        
        if isSelectingStartDate {
            startDate = sender.date
            print("Start Date Selected: \(startDate!)")
            isSelectingStartDate = false
        } else {
            endDate = sender.date
            print("End Date Selected: \(endDate!)")
            isSelectingStartDate = true
            
            
            if let start = startDate, let end = endDate, end < start {
                print("End date cannot be earlier than the start date!")
                endDate = nil
            }
        }
    }
    
    
    @IBAction func sendRequestButtonTapped(_ sender: UIButton) {
            // Step 1: Show alert
            let alertController = UIAlertController(
                title: "Request Sent",
                message: "Your request has been sent and is pending approval.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                // Step 2: Navigate to HomeViewController after alert dismissal
                self.navigateToHomeViewController()
            }))
            present(alertController, animated: true)
        }
        
        private func navigateToHomeViewController() {
            if let homeVC = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
                homeVC.modalTransitionStyle = .crossDissolve
                homeVC.modalPresentationStyle = .fullScreen
                present(homeVC, animated: true)
            }
        }
    
    
    /*
      MARK: - Navigation
     
      In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      Get the new view controller using segue.destination.
      Pass the selected object to the new view controller.
     }
     */
    
    
}
