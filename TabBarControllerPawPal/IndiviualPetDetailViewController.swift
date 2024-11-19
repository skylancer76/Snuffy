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

            
            if let pet = petData {
               
                print("Displaying details for \(pet.petName)")
            }
        }

        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "EditPetDetailSegue",
               let destinationVC = segue.destination as? PetDetailsViewController {
                
                destinationVC.petData = petData
            } else if segue.identifier == "EditHealthSegue",
                      let destinationVC = segue.destination as? PetDetailsViewController {
                
                destinationVC.petData = petData 
            }
        }
    }
