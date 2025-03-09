//
//  Add New Pet.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 27/01/25.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

protocol AddNewPetDelegate: AnyObject {
    func didAddNewPet(_ pet: PetData)
}

class Add_New_Pet: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var petNameTextField: UITextField!
//    @IBOutlet weak var petBreedTextField: UITextField!
    @IBOutlet weak var petBreedButton: UIButton!
    @IBOutlet weak var petAgeTextField: UITextField!
//    @IBOutlet weak var petGenderTextField: UITextField!
    @IBOutlet weak var petGenderButton: UIButton!
    @IBOutlet weak var petWeightTextField: UITextField!
    @IBOutlet weak var imageSelectButton: UIButton!  // Changed from UIImageView to UIButton
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    weak var delegate: AddNewPetDelegate?
    var selectedImage: UIImage?
    var selectedGender: String?
    var selectedBreed: String?
    
    let genderOptions = ["Male", "Female"]
    var breedOptions = ["Labrador", "German Shepherd", "Golden Retriever", "Poodle", "Bulldog", "Other"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDropDownMenus()
    }

    func setupUI() {
        
        petGenderButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        petBreedButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        petGenderButton.setTitle("Select Gender", for: .normal)
        petBreedButton.setTitle("Select Breed", for: .normal)
                
        petGenderButton.addTarget(self, action: #selector(showGenderPicker), for: .touchUpInside)


        // Set the button's title label font to system font with size 15
        imageSelectButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        // Set default button title
        imageSelectButton.setTitle("Select Image", for: .normal)
        imageSelectButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
    }
    
    @objc func showGenderPicker() {
            let alert = UIAlertController(title: "Select Gender", message: nil, preferredStyle: .actionSheet)
            
            for gender in genderOptions {
                alert.addAction(UIAlertAction(title: gender, style: .default, handler: { _ in
                    self.selectedGender = gender
                    self.petGenderButton.setTitle(gender, for: .normal)
                }))
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    
    
    func setupDropDownMenus() {
            // Breed Selection Menu
            let breedActions = breedOptions.map { breed in
                UIAction(title: breed, handler: { [weak self] _ in
                    if breed == "Other" {
                        self?.promptForCustomBreed()
                    } else {
                        self?.selectedBreed = breed
                        self?.petBreedButton.setTitle(breed, for: .normal)
                    }
                })
            }
            petBreedButton.menu = UIMenu(title: "Select Breed", children: breedActions)
            petBreedButton.showsMenuAsPrimaryAction = true  // Enables drop-down
            
            // Gender Selection Menu
            let genderActions = genderOptions.map { gender in
                UIAction(title: gender, handler: { [weak self] _ in
                    self?.selectedGender = gender
                    self?.petGenderButton.setTitle(gender, for: .normal)
                })
            }
            petGenderButton.menu = UIMenu(title: "Select Gender", children: genderActions)
            petGenderButton.showsMenuAsPrimaryAction = true  // Enables drop-down
        }
    func promptForCustomBreed() {
            let alert = UIAlertController(title: "Enter Breed", message: "Please enter your pet's breed.", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Breed Name"
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                if let customBreed = alert.textFields?.first?.text, !customBreed.isEmpty {
                    self?.selectedBreed = customBreed
                    self?.petBreedButton.setTitle(customBreed, for: .normal)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    

    @objc func selectImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            // Update button title instead of setting an image
            imageSelectButton.setTitle("Image Selected", for: .normal)
            imageSelectButton.setTitleColor(.systemGreen, for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func AddButtonTapped(_ sender: Any) {
        guard let petName = petNameTextField.text, !petName.isEmpty,
              let petBreed = selectedBreed, !petBreed.isEmpty,
              let petGender = selectedGender,
              let petAge = petAgeTextField.text, !petAge.isEmpty,
              let petWeight = petWeightTextField.text, !petWeight.isEmpty,
              let image = selectedImage else {
            showAlert(title: "Error", message: "Please fill in all fields and select an image.")
            return
        }

        // Get the current user logged in
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "Please log in first.")
            return
        }

        let ownerId = currentUser.uid
        let petId = UUID().uuidString

        // Upload image and save pet data
        uploadImageToFirebase(image: image) { [weak self] imageURL, error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Failed to upload image: \(error.localizedDescription)")
                return
            }

            guard let imageURL = imageURL else {
                self?.showAlert(title: "Error", message: "Failed to get image URL.")
                return
            }

            let petData: [String: Any] = [
                "petId": petId,
                "ownerID": ownerId,
                "petName": petName,
                "petBreed": petBreed,
                "petGender": petGender,
                "petAge": petAge,
                "petWeight": petWeight,
                "petImage": imageURL
            ]

            // Save pet data to Firestore
            FirebaseManager.shared.savePetDataToFirebase(data: petData, petId: petId) { error in
                if let error = error {
                    self?.showAlert(title: "Error", message: "Failed to save pet data: \(error.localizedDescription)")
                } else {
                    Firestore.firestore().collection("users").document(ownerId).updateData([
                        "petIds": FieldValue.arrayUnion([petId])
                    ]) { updateError in
                        if let updateError = updateError {
                            print("Error updating user's petIds: \(updateError.localizedDescription)")
                        } else {
                            print("User document updated with new pet ID successfully.")
                        }
                    }
                    self?.showAlert(title: "Success", message: "Pet data saved successfully!") {
                        guard let self = self else { return }
                        let newPet = PetData(petId: petId, petImage: imageURL, petName: petName, petBreed: petBreed)
                        self.delegate?.didAddNewPet(newPet)
                        self.clearFields()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func uploadImageToFirebase(image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil, NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"]))
            return
        }

        let storageRef = Storage.storage().reference().child("pet_images/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(nil, error)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    completion(url?.absoluteString, nil)
                }
            }
        }
    }

    func clearFields() {
        petNameTextField.text = ""
        selectedBreed = nil
        selectedGender = nil
        petBreedButton.setTitle("Select Breed", for: .normal)
        petGenderButton.setTitle("Select Gender", for: .normal)
        petAgeTextField.text = ""
        petWeightTextField.text = ""
        imageSelectButton.setTitle("Select Image", for: .normal)
        selectedImage = nil
    }

    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
}
