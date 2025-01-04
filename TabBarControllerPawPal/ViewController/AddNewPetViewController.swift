//
//  AddNewPetViewController.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 02/01/25.
//

import UIKit
import FirebaseStorage

class AddNewPetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var petNameTextField: UITextField!
    @IBOutlet weak var petBreedTextField: UITextField!
    @IBOutlet weak var petGenderTextField: UITextField!
    @IBOutlet weak var petAgeTextField: UITextField!
    @IBOutlet weak var petWeightTextField: UITextField!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        // Enable user interaction for the pet image view
        petImageView.isUserInteractionEnabled = true
        petImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectImage)))
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
            petImageView.image = editedImage
            selectedImage = editedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard let petName = petNameTextField.text, !petName.isEmpty,
              let petBreed = petBreedTextField.text, !petBreed.isEmpty,
              let petGender = petGenderTextField.text, !petGender.isEmpty,
              let petAge = petAgeTextField.text, !petAge.isEmpty,
              let petWeight = petWeightTextField.text, !petWeight.isEmpty,
              let image = selectedImage else {
            showAlert(title: "Error", message: "Please fill in all fields and select an image.")
            return
        }
        
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
            
            // Prepare pet data
            let petData: [String: Any] = [
                "petName": petName,
                "petBreed": petBreed,
                "petGender": petGender,
                "petAge": petAge,
                "petWeight": petWeight,
                "petImage": imageURL
            ]
            
            // Save pet data to Firestore
            FirebaseManager.shared.savePetDataToFirebase(data: petData) { error in
                if let error = error {
                    self?.showAlert(title: "Error", message: "Failed to save pet data: \(error.localizedDescription)")
                } else {
                    self?.showAlert(title: "Success", message: "Pet data saved successfully!") {
                        self?.clearFields()
                        self?.dismiss(animated: true, completion: nil)
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
        petImageView.image = UIImage(named: "placeholder_image")
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
