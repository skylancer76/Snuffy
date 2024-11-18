//
//  AddPetViewController.swift
//  PawPal_MyPets_TrackPet
//
//  Created by admin19 on 17/11/24.
//

import UIKit
protocol AddPetDelegate: AnyObject {
    func didAddPet(pet: PetData)
}

class AddPetViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    weak var delegate: AddPetDelegate?

    @IBOutlet weak var petImageView: UIImageView!
    
    @IBOutlet weak var petNameTextField: UITextField!
    
    @IBOutlet weak var petBreedTextField: UITextField!
    
    @IBOutlet weak var petGenderTextField: UITextField!
    
    @IBOutlet weak var petAgeTextField: UITextField!
    
    @IBOutlet weak var petWeightTextField: UITextField!
    var defaultPetImageName = "Image1"
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func uploadImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                petImageView.image = selectedImage
            }
            dismiss(animated: true, completion: nil)
        }
    
    @IBAction func SaveButtonTapped2(_ sender: UIBarButtonItem) {
        guard let name = petNameTextField.text, !name.isEmpty,
                      let breed = petBreedTextField.text, !breed.isEmpty,
              let age = petAgeTextField.text , !age.isEmpty,
              let weight = petWeightTextField.text, !weight.isEmpty,
              let gender = petGenderTextField.text, !gender.isEmpty else {
            print("Please fill in all required fields.")
            return
        }
        let petImageName = petImageView.image == nil ? defaultPetImageName : "Image1"

              
        let newPet = PetData(petImage: petImageName, petName: name, petBreed: breed, petGender: gender , petAge: age, petWeight: weight)

              
                delegate?.didAddPet(pet: newPet)

             
                navigationController?.popViewController(animated: true)
            }

    }
    
