//
//  Add Pet Diet.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 28/01/25.
//

import UIKit
import FirebaseFirestore

class Add_Pet_Diet: UITableViewController {
    
    var petId: String?
    
    // Outlets for the static table cells.
    @IBOutlet weak var mealTypeTextField: UITextField!
    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var foodCategoryButton: UIButton!
    @IBOutlet weak var portionSizeTextField: UITextField!
    @IBOutlet weak var feedingFrequencyTextField: UITextField!
    @IBOutlet weak var servingTimePicker: UIDatePicker!
    
    // Options for the food category.
    let foodCategories = ["Dry Food", "Wet Food", "Raw Food"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Pet ID: \(petId ?? "No Pet ID passed")")
        
        // Configure the serving time picker to show only time.
        servingTimePicker.datePickerMode = .time
        
        // Set a default title for the food category button.
        foodCategoryButton.setTitle(foodCategories.first, for: .normal)
    }
    
    // Action for when the food category button is tapped.
    @IBAction func foodCategoryButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Food Category", message: nil, preferredStyle: .actionSheet)
        
        for category in foodCategories {
            alert.addAction(UIAlertAction(title: category, style: .default, handler: { _ in
                self.foodCategoryButton.setTitle(category, for: .normal)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // For iPad compatibility.
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // Save the pet diet details to Firestore.
    @IBAction func saveDiet(_ sender: UIBarButtonItem) {
        guard let petId = petId else {
            print("Pet ID is missing!")
            return
        }
        
        // Retrieve values from UI elements.
        let mealType = mealTypeTextField.text ?? ""
        let foodName = foodNameTextField.text ?? ""
        let foodCategory = foodCategoryButton.title(for: .normal) ?? ""
        let portionSize = portionSizeTextField.text ?? ""
        let feedingFrequency = feedingFrequencyTextField.text ?? ""
        
        // Format the serving time (only time portion).
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        let servingTime = timeFormatter.string(from: servingTimePicker.date)
        
        // Create a PetDietDetails object (dietId remains nil so Firestore auto‑generates it).
        let diet = PetDietDetails(
            mealType: mealType,
            foodName: foodName,
            foodCategory: foodCategory,
            portionSize: portionSize,
            feedingFrequency: feedingFrequency,
            servingTime: servingTime
        )
        
        FirebaseManager.shared.savePetDietData(petId: petId, diet: diet) { error in
            if let error = error {
                print("Failed to save pet diet: \(error.localizedDescription)")
            } else {
                print("Pet diet saved successfully!")
                let alertController = UIAlertController(title: nil, message: "Pet Diet Data Added", preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    alertController.dismiss(animated: true, completion: {
                        // Post a notification if needed to refresh data on the Pet_Diet screen.
                        NotificationCenter.default.post(name: NSNotification.Name("PetDietDataAdded"), object: nil)
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }
}
