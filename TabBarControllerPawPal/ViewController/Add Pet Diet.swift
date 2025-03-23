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
    
    // Outlets for the static table cells
    @IBOutlet weak var mealTypeButton: UIButton!
    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var foodCategoryButton: UIButton!
    @IBOutlet weak var portionSizeTextField: UITextField!
    @IBOutlet weak var feedingFrequencyTextField: UITextField!
    @IBOutlet weak var servingTimePicker: UIDatePicker!
    
    // Options for the food category
    let foodCategories = ["Dry Food", "Wet Food", "Raw Food"]
    
    // Options for the meal type
    let mealTypes = ["Breakfast", "Lunch", "Dinner"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Pet ID: \(petId ?? "No Pet ID passed")")
        
        // 1) Set default title for Meal Type and color
        mealTypeButton.setTitle("Select", for: .normal)
        
        // 2) Configure serving time picker
        servingTimePicker.datePickerMode = .time
        
        // 3) Set default for Food Category and color
        foodCategoryButton.setTitle(foodCategories.first, for: .normal)
//        foodCategoryButton.setTitleColor(.tertiaryLabel, for: .normal)
    }
    
    // MARK: - Meal Type Selection
    @IBAction func mealTypeButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Meal Type",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        for type in mealTypes {
            alert.addAction(UIAlertAction(title: type, style: .default, handler: { _ in
                self.mealTypeButton.setTitle(type, for: .normal)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // For iPad popover compatibility
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Food Category Selection
    @IBAction func foodCategoryButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Food Category",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        for category in foodCategories {
            alert.addAction(UIAlertAction(title: category, style: .default, handler: { _ in
                self.foodCategoryButton.setTitle(category, for: .normal)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // For iPad popover compatibility
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Save Diet
    @IBAction func saveDiet(_ sender: UIBarButtonItem) {
            guard let petId = petId else {
                print("Pet ID is missing!")
                return
            }
            
            // Retrieve and trim values from UI elements
            let mealType = mealTypeButton.title(for: .normal) ?? ""
            let foodName = foodNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let foodCategory = foodCategoryButton.title(for: .normal) ?? ""
            let portionSize = portionSizeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let feedingFrequency = feedingFrequencyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            // Validate required fields
            if mealType == "Select" || foodName.isEmpty || portionSize.isEmpty || feedingFrequency.isEmpty {
                let alert = UIAlertController(title: "Incomplete Details",
                                              message: "Please fill in all required fields before saving.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            
            // Format the serving time (only time portion)
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            let servingTime = timeFormatter.string(from: servingTimePicker.date)
            
            // Create a PetDietDetails object
            let diet = PetDietDetails(
                mealType: mealType,
                foodName: foodName,
                foodCategory: foodCategory,
                portionSize: portionSize,
                feedingFrequency: feedingFrequency,
                servingTime: servingTime
            )
            
            // Save to Firestore
            FirebaseManager.shared.savePetDietData(petId: petId, diet: diet) { error in
                if let error = error {
                    print("Failed to save pet diet: \(error.localizedDescription)")
                } else {
                    print("Pet diet saved successfully!")
                    let alertController = UIAlertController(title: nil,
                                                            message: "Pet Diet Data Added",
                                                            preferredStyle: .alert)
                    self.present(alertController, animated: true, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        alertController.dismiss(animated: true) {
                            // Post notification to refresh list
                            NotificationCenter.default.post(name: NSNotification.Name("PetDietDataAdded"), object: nil)
                            // Dismiss the modal sheet
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        
    
    // MARK: - Cancel
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        // Make sure this IBAction is connected to the Cancel button in the storyboard
        self.dismiss(animated: true, completion: nil)
    }
}
