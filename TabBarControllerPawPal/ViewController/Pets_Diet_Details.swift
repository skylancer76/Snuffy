//
//  Pets_Diet_Details.swift
//  TabBarControllerPawPal
//
//  Created by user@61 on 24/03/25.
//

import UIKit

class Pets_Diet_Details: UITableViewController {

    // You’ll pass these from Pet_Diet
    var petId: String?
    var selectedDiet: PetDietDetails?
    
    // Outlets for your static cells
    @IBOutlet weak var mealTypeLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodCategoryLabel: UILabel!
    @IBOutlet weak var portionSizeLabel: UILabel!
    @IBOutlet weak var feedingFrequencyLabel: UILabel!
    @IBOutlet weak var servingTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Populate the labels with the selected diet
        if let diet = selectedDiet {
            mealTypeLabel.text = diet.mealType
            foodNameLabel.text = diet.foodName
            foodCategoryLabel.text = diet.foodCategory
            portionSizeLabel.text = diet.portionSize
            feedingFrequencyLabel.text = diet.feedingFrequency
            servingTimeLabel.text = diet.servingTime
        }
    }
    
    // IBAction for the Delete button
    @IBAction func deleteDietTapped(_ sender: UIBarButtonItem) {
        guard let petId = petId,
              let dietId = selectedDiet?.dietId else {
            return
        }

        // Perform the deletion in Firestore
        FirebaseManager.shared.deletePetDietData(petId: petId, dietId: dietId) { error in
            if let error = error {
                print("Error deleting diet: \(error.localizedDescription)")
            } else {
                print("Diet deleted successfully")
                
                // Optionally notify the Pet_Diet list to refresh
                NotificationCenter.default.post(name: NSNotification.Name("PetDietDataAdded"), object: nil)
                
                // Pop or dismiss
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
