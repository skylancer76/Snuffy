//
//  BuzzoViewController.swift
//  PawPal_MyPets_TrackPet
//
//  Created by admin19 on 17/11/24.
//

import UIKit

class IndiviualPetDetailViewController: UIViewController {

    var petData: PetData?
    override func viewDidLoad() {
            super.viewDidLoad()

            // Display the pet's data (set up your UI with this data)
            if let pet = petData {
                // Example: Set labels or images
                print("Displaying details for \(pet.petName)")
            }
        }

        // Prepare for navigation to editable pages
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "EditPetDetailSegue",
               let destinationVC = segue.destination as? PetDetailsViewController {
                // Pass pet data to the pet detail editor
                destinationVC.petData = petData
            } else if segue.identifier == "EditHealthSegue",
                      let destinationVC = segue.destination as? PetDetailsViewController {
                // Pass pet health data to the health editor
                destinationVC.petData = petData // Or health-specific data if applicable
            }
        }
    }
