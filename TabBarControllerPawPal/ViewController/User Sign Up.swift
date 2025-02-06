//
//  User Sign Up.swift
//  TabBarControllerPawPal
//
//  Created by admin19 on 14/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class User_Sign_Up: UIViewController {

    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    
    let db = Firestore.firestore()
    var hasAgreedToTerms: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.masksToBounds = true
        passwordTextField.isSecureTextEntry = true
    }
    
    
    @IBAction func passwordViewTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSelected ? "eye.slash.fill" : "eye.fill"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    
    @IBAction func termsButtonTapped(_ sender: Any) {
        hasAgreedToTerms.toggle() // Toggle agreement state
        updateTermsButtonAppearance()
    }
    
    
    func updateTermsButtonAppearance() {
        let checkboxImage = hasAgreedToTerms ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
        termsButton.setImage(checkboxImage, for: .normal)
        termsButton.tintColor = .systemPurple
    }
    
    
    @IBAction func signUpClicked(_ sender: Any) {
        
        guard let name = nameTextField.text, !name.isEmpty,
        let email = emailTextField.text, !email.isEmpty,
        let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        if !hasAgreedToTerms {
            showAlert(title: "Error", message: "You must agree to the terms and conditions.")
            return
        }
        
        let selectedIndex = roleSegmentedControl.selectedSegmentIndex
        
        
        // MARK: - Create User with Firebase Auth
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            // Save user data to Firestore
            guard let user = authResult?.user else { return }
            
            if selectedIndex == 0 {
                self.saveUserDataToFirestore(uid: user.uid, name: name, email: email, role: "Pet Owner")
            } else {
                self.saveCaretakerDataToFirestore(uid: user.uid, name: name, email: email, password : password)
            }
        }
    }
    
    
    // MARK: - Save User Data to Firestore
    func saveUserDataToFirestore(uid: String, name: String, email: String, role: String) {
        let userData: [String: Any] = [
            "uid": uid,
            "name": name,
            "email": email,
            "role": role,
            "createdAt": Timestamp()
        ]
           
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to save user data: \(error.localizedDescription)")
            } else {
                // Show success message and navigate back to Login Page
                self.navigateToHomeScreen()
            }
        }
    }
    
    func saveCaretakerDataToFirestore(uid: String, name: String, email: String, password: String) {
        
        let caretakerData: [String: Any] = [
                    "caretakerId": uid,
                    "name": name,
                    "email": email,
                    "password": password,
                    "profilePic": "",
                    "bio": "",
                    "experience": 0,
                    "address": "",
                    "location": [0.0, 0.0],
                    "distanceAway": 0.0,
                    "status": "available",
                    "pendingRequests": [],
                    "completedRequests": 0,
                    "createdAt": Timestamp()
                ]
        db.collection("caretakers").document(uid).setData(caretakerData) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Error saving caretaker data to Firestore: \(error.localizedDescription)")
                
            }else {
                self.navigateToHomeScreen()
            }
        }
    }
    
    func navigateToHomeScreen() {
          // Create an instance of the Home screen (Main 3)
          let storyboard = UIStoryboard(name: "Main", bundle: nil) // Ensure this storyboard name is correct
          if let homeVC = storyboard.instantiateInitialViewController() {
              homeVC.modalPresentationStyle = .fullScreen
              self.present(homeVC, animated: true, completion: nil)
          } else {
              self.showAlert(title: "Error", message: "Home screen could not be loaded.")
          }
      }
       
    // MARK: - Helper: Show Alert
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }

}
