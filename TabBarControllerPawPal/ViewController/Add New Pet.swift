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
    @IBOutlet weak var petBreedButton: UIButton!
    @IBOutlet weak var petAgeButton: UIButton!
    @IBOutlet weak var petGenderButton: UIButton!
    @IBOutlet weak var petWeightButton: UIButton!
    @IBOutlet weak var imageSelectButton: UIButton!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    weak var delegate: AddNewPetDelegate?
    var selectedImage: UIImage?
    var selectedGender: String?
    var selectedBreed: String?
    
    // If you already have a FirebaseManager & PetData, those remain unchanged
    
    // MARK: - Data Arrays
    private let ageData = (1...30).map { "\($0) Year" }
    private let weightData = (1...100).map { "\($0) kg" }
    
    // MARK: - Pickers
    private lazy var agePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        // Tag 1 = age
        picker.tag = 1
        return picker
    }()
    
    private lazy var weightPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        // Tag 2 = weight
        picker.tag = 2
        return picker
    }()
    
    // We’ll use a hidden text field to present the pickers
    private let hiddenTextField = UITextField(frame: .zero)
    
    let genderOptions = ["Male", "Female"]
    var breedOptions = ["Labrador", "German Shepherd", "Golden Retriever", "Poodle", "Bulldog", "Rottweiler", "Other"]
    
    // MARK: - Activity Indicator
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActivityIndicator()
        setupDropDownMenus()
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - UI Setup
    func setupUI() {
        // --- Select Gender Button ---
        petGenderButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        petGenderButton.setTitle("Select", for: .normal)
        petGenderButton.setTitleColor(.tertiaryLabel, for: .normal)
        
        // --- Select Breed Button ---
        petBreedButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        petBreedButton.setTitle("Select", for: .normal)
        petBreedButton.setTitleColor(.tertiaryLabel, for: .normal)
        
        // --- Age Button ---
        petAgeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        petAgeButton.setTitle("Value", for: .normal)
        petAgeButton.setTitleColor(.tertiaryLabel, for: .normal)
        petAgeButton.addTarget(self, action: #selector(showAgePicker), for: .touchUpInside)
        
        // --- Weight Button ---
        petWeightButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        petWeightButton.setTitle("Value", for: .normal)
        petWeightButton.setTitleColor(.tertiaryLabel, for: .normal)
        petWeightButton.addTarget(self, action: #selector(showWeightPicker), for: .touchUpInside)
        
        // --- Select Image Button ---
        imageSelectButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        imageSelectButton.setTitle("Upload", for: .normal)
        imageSelectButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        
        // Add the hidden text field for pickers
        hiddenTextField.isHidden = true
        view.addSubview(hiddenTextField)
    }
    
    // MARK: - Breed & Gender Drop-Downs
    func setupDropDownMenus() {
        // Breed Selection Menu
        let breedActions = breedOptions.map { breed in
            UIAction(title: breed, handler: { [weak self] _ in
                guard let self = self else { return }
                
                if breed == "Other" {
                    self.promptForCustomBreed()
                } else {
                    self.selectedBreed = breed
                    self.petBreedButton.setTitle(breed, for: .normal)
                    self.petBreedButton.setTitleColor(.label, for: .normal)
                }
            })
        }
        petBreedButton.menu = UIMenu(title: "Select Breed", children: breedActions)
        petBreedButton.showsMenuAsPrimaryAction = true
        
        // Gender Selection Menu
        let genderActions = genderOptions.map { gender in
            UIAction(title: gender, handler: { [weak self] _ in
                guard let self = self else { return }
                self.selectedGender = gender
                self.petGenderButton.setTitle(gender, for: .normal)
                self.petGenderButton.setTitleColor(.label, for: .normal)
            })
        }
        petGenderButton.menu = UIMenu(title: "Select Gender", children: genderActions)
        petGenderButton.showsMenuAsPrimaryAction = true
    }
    
    func promptForCustomBreed() {
        let alert = UIAlertController(title: "Enter Breed",
                                      message: "Please enter your pet's breed.",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Breed Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            if let customBreed = alert.textFields?.first?.text, !customBreed.isEmpty {
                self.selectedBreed = customBreed
                self.petBreedButton.setTitle(customBreed, for: .normal)
                self.petBreedButton.setTitleColor(.label, for: .normal)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    // MARK: - Age Picker
    @objc private func showAgePicker() {
        hiddenTextField.inputView = agePicker
        hiddenTextField.inputAccessoryView = createToolbar(doneSelector: #selector(didTapDoneAge))
        hiddenTextField.becomeFirstResponder()
    }
    
    @objc private func didTapDoneAge() {
        let row = agePicker.selectedRow(inComponent: 0)
        let selectedValue = ageData[row]  // e.g. "15 Year"
        petAgeButton.setTitle(selectedValue, for: .normal)
        petAgeButton.setTitleColor(.label, for: .normal)
        
        hiddenTextField.resignFirstResponder()
    }
    
    // MARK: - Weight Picker
    @objc private func showWeightPicker() {
        hiddenTextField.inputView = weightPicker
        hiddenTextField.inputAccessoryView = createToolbar(doneSelector: #selector(didTapDoneWeight))
        hiddenTextField.becomeFirstResponder()
    }
    
    @objc private func didTapDoneWeight() {
        let row = weightPicker.selectedRow(inComponent: 0)
        let selectedValue = weightData[row]  // e.g. "50 kg"
        petWeightButton.setTitle(selectedValue, for: .normal)
        petWeightButton.setTitleColor(.label, for: .normal)
        
        hiddenTextField.resignFirstResponder()
    }
    
    // MARK: - Toolbar for Pickers
    private func createToolbar(doneSelector: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancel))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: doneSelector)
        
        toolbar.setItems([cancelButton, flexSpace, doneButton], animated: false)
        return toolbar
    }
    
    @objc private func didTapCancel() {
        hiddenTextField.resignFirstResponder()
    }
    
    // MARK: - Image Picker
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
            imageSelectButton.setTitle("Image Uploaded", for: .normal)
            imageSelectButton.setTitleColor(.systemGreen, for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Add Pet Action
    @IBAction func AddButtonTapped(_ sender: Any) {
        // Retrieve age/weight from the buttons instead of text fields
        guard let petName = petNameTextField.text, !petName.isEmpty,
              let petBreed = selectedBreed, !petBreed.isEmpty,
              let petGender = selectedGender,
              let petAge = petAgeButton.title(for: .normal), petAge != "Value",
              let petWeight = petWeightButton.title(for: .normal), petWeight != "Value",
              let image = selectedImage else {
            showAlert(title: "Error", message: "Please fill in all fields and select an image.")
            return
        }

        // Disable the Add button to prevent double taps
        addButton.isEnabled = false
        // Show loading indicator
        showLoadingIndicator()
        
        // Get the current user
        guard let currentUser = Auth.auth().currentUser else {
            hideLoadingIndicator()
            addButton.isEnabled = true
            showAlert(title: "Error", message: "Please log in first.")
            return
        }

        let ownerId = currentUser.uid
        let petId = UUID().uuidString

        // Upload image and save pet data
        uploadImageToFirebase(image: image) { [weak self] imageURL, error in
            guard let self = self else { return }
            
            if let error = error {
                self.hideLoadingIndicator()
                self.addButton.isEnabled = true
                self.showAlert(title: "Error", message: "Failed to upload image: \(error.localizedDescription)")
                return
            }

            guard let imageURL = imageURL else {
                self.hideLoadingIndicator()
                self.addButton.isEnabled = true
                self.showAlert(title: "Error", message: "Failed to get image URL.")
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
                self.hideLoadingIndicator()
                
                if let error = error {
                    self.addButton.isEnabled = true
                    self.showAlert(title: "Error", message: "Failed to save pet data: \(error.localizedDescription)")
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
                    
                    self.showAlert(title: "Success", message: "Pet data saved successfully!") {
                        let newPet = PetData(
                            petId: petId,
                            petImage: imageURL,
                            petName: petName,
                            petBreed: petBreed
                        )
                        self.delegate?.didAddNewPet(newPet)
                        self.clearFields()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Upload Image
    func uploadImageToFirebase(image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil, NSError(domain: "ImageError",
                                    code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: "Invalid image data"]))
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

    // MARK: - Clear Fields
    func clearFields() {
        petNameTextField.text = ""
        selectedBreed = nil
        selectedGender = nil
        
        petBreedButton.setTitle("Select Breed", for: .normal)
        petBreedButton.setTitleColor(.tertiaryLabel, for: .normal)
        
        petGenderButton.setTitle("Select Gender", for: .normal)
        petGenderButton.setTitleColor(.tertiaryLabel, for: .normal)
        
        // Reset Age & Weight buttons to defaults
        petAgeButton.setTitle("Value", for: .normal)
        petAgeButton.setTitleColor(.tertiaryLabel, for: .normal)
        
        petWeightButton.setTitle("Value", for: .normal)
        petWeightButton.setTitleColor(.tertiaryLabel, for: .normal)
        
        imageSelectButton.setTitle("Select Image", for: .normal)
        imageSelectButton.setTitleColor(.systemBlue, for: .normal)
        
        selectedImage = nil
    }
    
    // MARK: - Loading Indicator Helpers
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }

    // MARK: - Alerts
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIPickerView DataSource & Delegate
extension Add_New_Pet: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1  // Single-column
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 1 ? ageData.count : weightData.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return ageData[row]
        } else {
            return weightData[row]
        }
    }
}
