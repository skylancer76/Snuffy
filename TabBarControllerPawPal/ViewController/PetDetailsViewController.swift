//
//  PetDetailsViewController.swift
//  PawPal_MyPets_TrackPet
//
//  Created by admin19 on 18/11/24.
//

import UIKit


class PetDetailsViewController: UIViewController {
    var petData: PetData?
    var isEditMode: Bool = false
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var petNameTextField: UITextField!
    
    @IBOutlet weak var petBreedTextField: UITextField!
    
    @IBOutlet weak var petGenderTextField: UITextField!
    
    @IBOutlet weak var petAgeTextField: UITextField!
    
    @IBOutlet weak var petWeightTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pet = petData {
            petNameTextField.text = pet.petName
            petBreedTextField.text = pet.petBreed
            petGenderTextField.text = pet.petGender
            petAgeTextField.text = pet.petAge
            petWeightTextField.text = pet.petWeight
            
        }
        toggleTextFields(isEditable: false)
        
        
        
        
        
    }
    
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
            if isEditMode {
                // Save changes and switch to view mode
                savePetDetails()
                toggleTextFields(isEditable: false)
                editButton.title = "Edit"
            } else {
                // Enable text fields for editing
                toggleTextFields(isEditable: true)
                editButton.title = "Save"
            }
            
            // Toggle edit mode state
            isEditMode.toggle()
        }
    private func toggleTextFields(isEditable: Bool) {
            petNameTextField.isUserInteractionEnabled = isEditable
            petBreedTextField.isUserInteractionEnabled = isEditable
            petGenderTextField.isUserInteractionEnabled = isEditable
            petAgeTextField.isUserInteractionEnabled = isEditable
            petWeightTextField.isUserInteractionEnabled = isEditable
        }
        
        // Function to save pet details (updates the `petData` object)
        private func savePetDetails() {
            petData?.petName = petNameTextField.text ?? ""
            petData?.petBreed = petBreedTextField.text ?? ""
            petData?.petGender = petGenderTextField.text ?? ""
            petData?.petAge = petAgeTextField.text ?? ""
            petData?.petWeight = petWeightTextField.text ?? ""
            
            // Optionally notify the previous view controller of changes using a delegate or closure
            print("Pet details updated: \(String(describing: petData))")
        }

    
}
