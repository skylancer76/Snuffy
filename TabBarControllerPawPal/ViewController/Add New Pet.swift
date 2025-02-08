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
    @IBOutlet weak var petBreedTextField: UITextField!
    @IBOutlet weak var petAgeTextField: UITextField!
    @IBOutlet weak var petGenderTextField: UITextField!
    @IBOutlet weak var petWeightTextField: UITextField!
    @IBOutlet weak var imageSelectButton: UIButton!  // Changed from UIImageView to UIButton
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    weak var delegate: AddNewPetDelegate?
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        // Set default button title
        imageSelectButton.setTitle("Select Image", for: .normal)
        imageSelectButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
    }

    @objc func selectImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            // Update button title instead of setting an image
            imageSelectButton.setTitle("Image Selected", for: .normal)
            imageSelectButton.setTitleColor(.purple, for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func AddButtonTapped(_ sender: Any) {
        guard let petName = petNameTextField.text, !petName.isEmpty,
              let petBreed = petBreedTextField.text, !petBreed.isEmpty,
              let petGender = petGenderTextField.text, !petGender.isEmpty,
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
        petBreedTextField.text = ""
        petGenderTextField.text = ""
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
